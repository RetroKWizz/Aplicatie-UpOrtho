import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_exception.dart';
import '../../api/models/home_response.dart';
import '../../api/same_origin.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/banner_card.dart';
import '../../design_system/widgets/category_chip.dart';
import '../../design_system/widgets/product_card.dart';
import '../../design_system/widgets/section_header.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
import '../favorites/favorites_controller.dart';
import '../product_badge_palette.dart';
import '../product_rating_label.dart';
import 'banner_link.dart';
import 'home_controller.dart';

/// Ecranul Acasa: banner hero, categorii rapide, grila de oferte. Un singur apel /home.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final api = ref.watch(apiClientProvider);
    // Cat timp sesiunea inca nu s-a citit (sau citirea a picat), imaginile nu au
    // cookie si server-ul le va respinge - widget-urile trateaza asta ca "fara imagine".
    final imageHeaders = ref.watch(imageHeadersProvider).value;
    // Cookie-ul de sesiune Odoo se trimite doar catre imagini de pe originea proprie
    // a API-ului - `absoluteUrl` are un ram pass-through pentru URL-uri deja absolute
    // (raspunsuri viitoare de la backend), iar un URL absolut catre alta origine
    // (ex. un CDN extern) nu trebuie sa primeasca vreodata acest cookie.
    Map<String, String>? headersFor(String url) =>
        imageHeadersFor(url, apiBaseUrl: api.baseUrl, headers: imageHeaders);

    return Scaffold(
      appBar: AppBar(
        title: Text('UpOrtho', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Iesire',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: home.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : 'Nu s-a putut incarca pagina.',
          onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
          child: _HomeContent(data: data, absoluteUrl: api.absoluteUrl, headersFor: headersFor),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data, required this.absoluteUrl, required this.headersFor});
  final HomeResponse data;
  final String Function(String) absoluteUrl;
  /// Headerele de imagine (cookie de sesiune) pentru un URL absolut dat, sau null
  /// daca URL-ul nu tinteste originea proprie a API-ului - vezi `headersFor` din HomeScreen.
  final Map<String, String>? Function(String url) headersFor;

  @override
  Widget build(BuildContext context) {
    final heroes = data.banners.where((b) => b.placement == BannerPlacement.hero).toList();
    final promos = data.banners.where((b) => b.placement == BannerPlacement.promo).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (heroes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: _HeroCarousel(
              banners: heroes,
              buildCard: (banner) => _bannerCard(context, banner, hero: true),
            ),
          ),
        if (data.quickCategories.isNotEmpty) ...[
          const SectionHeader('Categorii'),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.quickCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = data.quickCategories[index];
                final iconUrl = category.iconUrl == null ? null : absoluteUrl(category.iconUrl!);
                return CategoryChip(
                  name: category.name,
                  iconUrl: iconUrl,
                  httpHeaders: iconUrl == null ? null : headersFor(iconUrl),
                  onTap: () => context.go('/catalog?category_id=${category.id}'),
                );
              },
            ),
          ),
        ],
        if (promos.isNotEmpty) ...[
          const SectionHeader('Oferte'),
          // Un rand care se trage lateral, nu o grila: ofertele sunt putine si rare
          // (pe instanta reala, una singura), iar o grila de doua coloane cu un singur
          // card lasa jumatate de ecran gol.
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: promos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) => SizedBox(
                width: 240,
                child: _bannerCard(context, promos[index]),
              ),
            ),
          ),
        ],
        // Randurile de produse, in ordinea pusa in Odoo. Serverul nu trimite un rand
        // ramas fara produse, deci aici nu exista titlu peste gol.
        for (final section in data.sections)
          _ProductRow(
            section: section,
            absoluteUrl: absoluteUrl,
            headersFor: headersFor,
          ),
        if (data.banners.isEmpty && data.quickCategories.isEmpty && data.sections.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Nu exista continut inca. Adauga bannere si categorii din Odoo.')),
          ),
      ],
    );
  }

  Widget _bannerCard(BuildContext context, AppBanner banner, {bool hero = false}) {
    final imageUrl = banner.imageUrl == null ? null : absoluteUrl(banner.imageUrl!);
    return BannerCard(
      banner: banner,
      hero: hero,
      imageUrl: imageUrl,
      httpHeaders: imageUrl == null ? null : headersFor(imageUrl),
      onTap: () => _openBanner(context, banner),
    );
  }

  Future<void> _openBanner(BuildContext context, AppBanner banner) async {
    switch (banner.link.type) {
      case BannerLinkType.url:
        // Doar http/https, si niciodata o exceptie de platforma scapata dintr-un
        // handler de tap fire-and-forget (nimeni nu asteapta acest Future).
        final uri = externalBannerUri(banner.link.url);
        if (uri == null) return;
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (error) {
          debugPrint('Nu s-a putut deschide link-ul bannerului: $error');
        }
      case BannerLinkType.category:
        final categoryId = banner.link.categoryId;
        if (categoryId != null && context.mounted) {
          context.go('/catalog?category_id=$categoryId');
        }
      case BannerLinkType.none:
        break;
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Reincearca')),
        ],
      ),
    );
  }
}

/// Caruselul de bannere mari: cate unul pe ecran, cu puncte dedesubt.
///
/// Un singur banner nu primeste puncte - un rand de un punct nu spune nimic. Pagina
/// urmatoare se vede cu marginea afara (`viewportFraction` sub 1), ca sa se stie din
/// prima privire ca mai e ceva de tras; fara asta, al doilea banner e invizibil si
/// nimeni nu-l deschide.
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.banners, required this.buildCard});

  final List<AppBanner> banners;
  final Widget Function(AppBanner banner) buildCard;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.banners.length > 1 ? 0.9 : 1.0,
  );
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final single = widget.banners.length == 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (_, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: single ? 16 : 6),
              child: widget.buildCard(widget.banners[index]),
            ),
          ),
        ),
        if (!single) ...[
          const SizedBox(height: 10),
          Row(
            key: const Key('hero-dots'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < widget.banners.length; index++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _page ? AppColors.primary : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Un rand de produse de pe Acasa: titlul pus in Odoo, apoi cardurile, care se trag
/// lateral. Acelasi card ca in catalog - un produs nu are voie sa arate altfel aici
/// decat acolo.
class _ProductRow extends ConsumerWidget {
  const _ProductRow({
    required this.section,
    required this.absoluteUrl,
    required this.headersFor,
  });

  final HomeSection section;
  final String Function(String) absoluteUrl;
  final Map<String, String>? Function(String url) headersFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesControllerProvider).value?.ids ?? const <int>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(child: SectionHeader(section.title)),
              // "Vezi toate" are unde duce doar cand randul e facut dintr-o categorie;
              // la produse alese de mana nu exista o lista care sa le cuprinda.
              if (section.categoryId case final int categoryId)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => context.go('/catalog?category_id=$categoryId'),
                    child: const Text('Vezi toate'),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 268,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            itemCount: section.products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final product = section.products[index];
              final imageUrl =
                  product.imageUrl == null ? null : absoluteUrl(product.imageUrl!);
              return SizedBox(
                width: 168,
                child: ProductCard(
                  title: product.name,
                  code: product.defaultCode,
                  imageUrl: imageUrl,
                  httpHeaders: imageUrl == null ? null : headersFor(imageUrl),
                  priceFormatted: product.price.formatted,
                  listAmountFormatted: product.price.listFormatted,
                  discountLabel: product.price.discountPct == null
                      ? null
                      : '-${product.price.discountPct}%',
                  badgeText: product.badge?.text,
                  badgeColor:
                      product.badge == null ? null : productBadgeBackground(product.badge!),
                  badgeTextColor:
                      product.badge == null ? null : productBadgeForeground(product.badge!),
                  ratingLabel: productRatingLabel(product.rating),
                  isFavorite: favorites.contains(product.id),
                  onToggleFavorite: () =>
                      ref.read(favoritesControllerProvider.notifier).toggle(product.id),
                  onTap: () => context.push('/catalog/${product.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

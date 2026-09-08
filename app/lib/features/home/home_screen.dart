import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_exception.dart';
import '../../api/models/home_response.dart';
import '../../api/same_origin.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/banner_card.dart';
import '../../design_system/widgets/category_chip.dart';
import '../../design_system/widgets/section_header.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
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
        title: const Text('UpOrtho', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
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
        for (final banner in heroes)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _bannerCard(context, banner, hero: true),
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
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Catalogul vine in Faza 2: ${category.name}')),
                  ),
                );
              },
            ),
          ),
        ],
        if (promos.isNotEmpty) ...[
          const SectionHeader('Oferte'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 4 / 3,
              children: [
                for (final banner in promos) _bannerCard(context, banner),
              ],
            ),
          ),
        ],
        if (data.banners.isEmpty && data.quickCategories.isEmpty)
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
        final uri = Uri.tryParse(banner.link.url ?? '');
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      case BannerLinkType.category:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalogul vine in Faza 2.')));
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

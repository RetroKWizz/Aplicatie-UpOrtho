import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/catalog_category.dart';
import '../../api/models/product.dart';
import '../../api/same_origin.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/product_card.dart';
import '../../providers.dart';
import 'catalog_controller.dart';

/// Culorile de badge din contract (`orange`/`green`/`blue`/`purple`/`red`) traduse
/// in `Color` din paleta de brand - `ProductCard` nu stie de `ProductBadgeColor`
/// (nu importa modele API), asa ca traducerea se face aici, la marginea ecranului.
Color _badgeColor(ProductBadgeColor color) => switch (color) {
      ProductBadgeColor.orange => AppColors.accent,
      ProductBadgeColor.green => AppColors.success,
      ProductBadgeColor.blue => const Color(0xFF2E75D9),
      ProductBadgeColor.purple => AppColors.primary,
      ProductBadgeColor.red => AppColors.danger,
    };

/// Ecranul de catalog: cautare, filtrare pe categorie, grila de produse cu
/// paginare (scroll infinit - vezi comentariul de pe `_onScroll`).
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.initialCategoryId});

  /// Categoria cu care se deschide ecranul (ex. tap pe un chip de pe Acasa sau pe
  /// un banner de tip categorie). `null` = toate categoriile.
  final int? initialCategoryId;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Prima incarcare porneste dupa acest frame, nu direct in initState: la acel
    // moment widget-ul inca nu e complet montat, iar `ensureLoaded` scrie stare
    // (AsyncLoading) - Riverpod interzice modificarea unui provider in timp ce
    // arborele de widget-uri e inca in constructie.
    Future.microtask(() => ref.read(catalogControllerProvider.notifier).ensureLoaded(categoryId: widget.initialCategoryId));
  }

  @override
  void didUpdateWidget(covariant CatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ecranul ramane montat permanent (tab in StatefulShellRoute.indexedStack) -
    // o a doua navigare catre catalog cu alta categorie (ex. alt banner de pe
    // Acasa) reconstruieste acelasi widget cu alt `initialCategoryId`, nu unul nou.
    if (widget.initialCategoryId != oldWidget.initialCategoryId) {
      ref.read(catalogControllerProvider.notifier).setCategory(widget.initialCategoryId);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Prag de 300px inainte de finalul listei, ca urmatoarea pagina sa fie deja
    // pe ecran (sau aproape) cand utilizatorul ajunge jos, nu dupa.
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(catalogControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(catalogControllerProvider.notifier).setQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogControllerProvider);
    final categories = ref.watch(catalogCategoriesProvider);
    final selectedCategoryId = ref.watch(catalogCategoryFilterProvider);
    final api = ref.watch(apiClientProvider);
    final imageHeaders = ref.watch(imageHeadersProvider).value;
    Map<String, String>? headersFor(String url) =>
        imageHeadersFor(url, apiBaseUrl: api.baseUrl, headers: imageHeaders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cauta dupa nume sau cod produs',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          categories.when(
            loading: () => const SizedBox(height: 44),
            // Categoriile sunt un filtru secundar - daca /categories pica, grila de
            // produse (fara filtru pe categorie) tot merita afisata.
            error: (_, _) => const SizedBox.shrink(),
            data: (list) => _CategoryChips(categories: list, selectedId: selectedCategoryId),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorView(
                message: error is ApiException ? error.message : 'Nu s-a putut incarca catalogul.',
                onRetry: () => ref.read(catalogControllerProvider.notifier).retry(),
              ),
              data: (state) {
                if (state.products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Niciun produs gasit. Incearca alt termen sau alta categorie.', textAlign: TextAlign.center),
                    ),
                  );
                }
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: state.products.length + (state.isLoadingMore || state.loadMoreError != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.products.length) {
                      return state.loadMoreError != null
                          ? _LoadMoreError(
                              message: state.loadMoreError!,
                              onRetry: () => ref.read(catalogControllerProvider.notifier).loadMore(),
                            )
                          : const Center(child: CircularProgressIndicator());
                    }
                    final product = state.products[index];
                    final imageUrl = product.imageUrl == null ? null : api.absoluteUrl(product.imageUrl!);
                    return ProductCard(
                      title: product.name,
                      code: product.defaultCode,
                      imageUrl: imageUrl,
                      httpHeaders: imageUrl == null ? null : headersFor(imageUrl),
                      priceFormatted: product.price.formatted,
                      listAmountFormatted: product.price.listAmount == null ? null : _formatListAmount(product),
                      discountLabel: product.price.discountPct == null ? null : '-${product.price.discountPct}%',
                      clubPriceFormatted: product.clubPrice?.formatted,
                      badgeText: product.badge?.text,
                      badgeColor: product.badge == null ? null : _badgeColor(product.badge!.color),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Detaliile pentru "${product.name}" vin in etapa urmatoare.')),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Serverul trimite `list_amount` ca numar brut (pentru comparatii), nu ca text
  // formatat - contractul nu are un `list_amount_formatted`. Cardul afiseaza totusi
  // doar text (nicio aritmetica): acesta e singurul loc unde un numar de pret e citit
  // direct, doar ca sa fie randat ca sir, niciodata calculat.
  String _formatListAmount(Product product) {
    final currency = product.price.currency;
    final amount = product.price.listAmount!;
    final isRon = currency.toUpperCase() == 'RON';
    final text = amount.toStringAsFixed(2).replaceAll('.', ',');
    return isRon ? '$text lei' : '$text $currency';
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.categories, required this.selectedId});
  final List<CatalogCategory> categories;
  final int? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Toate'),
              selected: selectedId == null,
              onSelected: (_) => ref.read(catalogControllerProvider.notifier).setCategory(null),
            ),
          ),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${category.name} (${category.productCount})'),
                selected: selectedId == category.id,
                onSelected: (_) => ref.read(catalogControllerProvider.notifier).setCategory(category.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reincearca')),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreError extends StatelessWidget {
  const _LoadMoreError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          TextButton(onPressed: onRetry, child: const Text('Reincearca')),
        ],
      ),
    );
  }
}

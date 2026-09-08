import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/catalog_category.dart';
import '../../api/models/product.dart';
import '../../providers.dart';
import 'catalog_repository.dart';

/// Numarul de produse cerute pe pagina. Catalogul real are ~925 de produse -
/// ecranul pagineaza (scroll infinit), nu aduce niciodata totul dintr-o cerere.
const catalogPageSize = 20;

final catalogRepositoryProvider =
    Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiClientProvider)));

/// Filtrul curent (categorie + text de cautare). Stare simpla (`Notifier` plan,
/// nu `StateProvider` - mutat in `flutter_riverpod/legacy.dart` in Riverpod 3),
/// separata de fetch-ul de produse: ecranul reflecta imediat selectia (ex.
/// chip-ul apasat), fara sa astepte raspunsul retelei.
class _CategoryFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;
}

class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
}

final catalogCategoryFilterProvider = NotifierProvider<_CategoryFilterNotifier, int?>(_CategoryFilterNotifier.new);
final catalogSearchQueryProvider = NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);

final catalogCategoriesProvider = FutureProvider<List<CatalogCategory>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchCategories(),
  // retry: null - vezi CLAUDE.md, gotcha 3: fara asta un /categories picat ar
  // arata eroarea abia dupa ~38s de reincercare automata in fundal.
  retry: (retryCount, error) => null,
);

/// Starea grilei de produse pentru pagina curenta de filtre.
class CatalogState {
  const CatalogState({
    required this.products,
    required this.total,
    required this.limit,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Product> products;
  final int total;
  final int limit;
  /// A doua pagina (si urmatoarele) se incarca in fundal, sub grila deja afisata -
  /// nu inlocuieste starea intreaga cu AsyncLoading (ar goli ecranul).
  final bool isLoadingMore;
  /// Mesaj de eroare doar pentru un `loadMore` esuat: produsele deja incarcate
  /// raman pe ecran, nu sunt inlocuite de un ecran de eroare.
  final String? loadMoreError;

  bool get hasMore => products.length < total;

  static const empty = CatalogState(products: [], total: 0, limit: catalogPageSize);
}

final catalogControllerProvider = AsyncNotifierProvider<CatalogController, CatalogState>(
  CatalogController.new,
  // retry: null - vezi CLAUDE.md, gotcha 3.
  retry: (retryCount, error) => null,
);

/// Controller pentru ecranul de catalog. `build()` e sincron si nu porneste nicio
/// cerere: prima incarcare reala e explicita, din `ensureLoaded`, apelata de ecran
/// dupa ce afla categoria ceruta la navigare (ex. chip de pe Acasa sau banner).
class CatalogController extends AsyncNotifier<CatalogState> {
  bool _initialized = false;

  @override
  FutureOr<CatalogState> build() => CatalogState.empty;

  /// Prima incarcare a ecranului, cu categoria initiala dedusa din navigare
  /// (poate fi null = "toate categoriile"). Idempotenta: un `initState` reexecutat
  /// (ex. hot reload) nu porneste a doua cerere.
  Future<void> ensureLoaded({int? categoryId}) async {
    if (_initialized) return;
    _initialized = true;
    ref.read(catalogCategoryFilterProvider.notifier).state = categoryId;
    await _reload();
  }

  /// Schimba categoria si reincarca de la prima pagina. `null` = "toate".
  Future<void> setCategory(int? categoryId) async {
    if (ref.read(catalogCategoryFilterProvider) == categoryId) return;
    ref.read(catalogCategoryFilterProvider.notifier).state = categoryId;
    await _reload();
  }

  /// Schimba textul de cautare (nume sau cod) si reincarca de la prima pagina.
  Future<void> setQuery(String query) async {
    final normalized = query.trim();
    if (ref.read(catalogSearchQueryProvider) == normalized) return;
    ref.read(catalogSearchQueryProvider.notifier).state = normalized;
    await _reload();
  }

  /// Reincearca acelasi filtru curent (buton "Reincearca" din ecranul de eroare).
  Future<void> retry() => _reload();

  Future<void> _reload() async {
    state = const AsyncLoading<CatalogState>();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(catalogRepositoryProvider).fetchProducts(
            categoryId: ref.read(catalogCategoryFilterProvider),
            query: ref.read(catalogSearchQueryProvider),
            offset: 0,
            limit: catalogPageSize,
          );
      return CatalogState(products: response.products, total: response.total, limit: response.limit);
    });
  }

  /// Aduce pagina urmatoare si o adauga la lista deja afisata (nu o inlocuieste).
  /// No-op daca deja se incarca sau nu mai exista pagini.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(CatalogState(
      products: current.products,
      total: current.total,
      limit: current.limit,
      isLoadingMore: true,
    ));
    try {
      final response = await ref.read(catalogRepositoryProvider).fetchProducts(
            categoryId: ref.read(catalogCategoryFilterProvider),
            query: ref.read(catalogSearchQueryProvider),
            offset: current.products.length,
            limit: current.limit,
          );
      state = AsyncData(CatalogState(
        products: [...current.products, ...response.products],
        total: response.total,
        limit: response.limit,
      ));
    } catch (error) {
      final message = error is ApiException ? error.message : 'Nu s-au putut incarca mai multe produse.';
      state = AsyncData(CatalogState(
        products: current.products,
        total: current.total,
        limit: current.limit,
        loadMoreError: message,
      ));
    }
  }
}

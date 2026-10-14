import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/catalog_category.dart';
import '../../api/models/product.dart';
import '../../api/models/product_filters.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
import 'catalog_repository.dart';
import 'product_filter_selection.dart';

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

/// Ce filtre a ales clientul. Separat de raspunsul serverului (`CatalogState.filters`,
/// care spune ce SE POATE alege): ecranul bifeaza imediat valoarea apasata, fara sa
/// astepte reteaua.
class _FilterSelectionNotifier extends Notifier<ProductFilterSelection> {
  @override
  ProductFilterSelection build() => ProductFilterSelection.empty;
}

final catalogCategoryFilterProvider = NotifierProvider<_CategoryFilterNotifier, int?>(_CategoryFilterNotifier.new);
final catalogSearchQueryProvider = NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);
final catalogFilterSelectionProvider =
    NotifierProvider<_FilterSelectionNotifier, ProductFilterSelection>(_FilterSelectionNotifier.new);

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
    this.filters = const ProductFilters(),
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Product> products;
  final int total;
  final int limit;

  /// Ce filtre se pot alege pentru cererea curenta, asa cum le-a calculat serverul din
  /// rezultat. Se schimba de la o categorie la alta; aplicatia nu le deduce singura.
  final ProductFilters filters;
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
  FutureOr<CatalogState> build() {
    // Preturile din grila sunt ale CONTULUI (fiecare client are lista lui), deci
    // produsele deja incarcate nu mai sunt valabile cand se schimba utilizatorul.
    // Ecranul ramane montat permanent (StatefulShellRoute.indexedStack) si isi cere
    // datele o singura data, din `initState`, asa ca reactia trebuie sa fie aici.
    //
    // `ref.listen`, nu `ref.watch`: un watch ar reconstrui notifierul si ar goli
    // grila la fiecare tranzitie de autentificare, inclusiv la restaurarea sesiunii
    // de la pornire. Aici vrem doar sa reincarcam ce era incarcat.
    // `_initialized` NU se reseteaza la deconectare: el pazeste doar `ensureLoaded`,
    // iar ecranul si-l cheama o singura data, din `initState`. Resetat aici, login-ul
    // care urmeaza ar cadea pe `!_initialized` si grila ar ramane goala - exact
    // greseala facuta la prima incercare de reparatie.
    ref.listen(authControllerProvider, (previous, next) {
      if (previous == null || !_initialized) return;
      if (next.value is SignedIn) {
        _reload();
      } else if (next.value is SignedOut) {
        state = const AsyncData(CatalogState.empty);
      }
    });
    return CatalogState.empty;
  }

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
  ///
  /// Filtrele pe atribute si pe pret se sterg la schimbarea categoriei: ele sunt
  /// calculate din rezultat, deci un brand ales in Bracketi poate sa nu existe deloc
  /// in Adezivi, iar clientul ar vedea o grila goala fara sa inteleaga de ce. Sortarea
  /// ramane - e o preferinta, nu un filtru.
  Future<void> setCategory(int? categoryId) async {
    if (ref.read(catalogCategoryFilterProvider) == categoryId) return;
    ref.read(catalogCategoryFilterProvider.notifier).state = categoryId;
    final selection = ref.read(catalogFilterSelectionProvider);
    if (!selection.cleared().isEmpty || selection.activeCount > 0) {
      ref.read(catalogFilterSelectionProvider.notifier).state = selection.cleared();
    }
    await _reload();
  }

  /// Aplica o selectie noua de filtre si reincarca de la prima pagina.
  Future<void> setFilters(ProductFilterSelection selection) async {
    if (ref.read(catalogFilterSelectionProvider) == selection) return;
    ref.read(catalogFilterSelectionProvider.notifier).state = selection;
    await _reload();
  }

  /// Deschide catalogul filtrat pe un brand, apasat de pe Acasa.
  ///
  /// Scoate categoria si cautarea si lasa doar brandul: altfel, apasat din Acasa, un
  /// brand ar fi cautat in categoria la care ramasese ecranul si ar fi parut ca
  /// magazinul nu are nimic de la el. O singura reincarcare, nu trei.
  Future<void> showBrand({required int attributeId, required int valueId}) async {
    ref.read(catalogCategoryFilterProvider.notifier).state = null;
    ref.read(catalogSearchQueryProvider.notifier).state = '';
    ref.read(catalogFilterSelectionProvider.notifier).state =
        ProductFilterSelection.empty.toggleValue(attributeId, valueId);
    _initialized = true;
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
            filters: ref.read(catalogFilterSelectionProvider),
            offset: 0,
            limit: catalogPageSize,
          );
      return CatalogState(
        products: response.products,
        total: response.total,
        limit: response.limit,
        filters: response.filters,
      );
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
      filters: current.filters,
      isLoadingMore: true,
    ));
    try {
      final response = await ref.read(catalogRepositoryProvider).fetchProducts(
            categoryId: ref.read(catalogCategoryFilterProvider),
            query: ref.read(catalogSearchQueryProvider),
            filters: ref.read(catalogFilterSelectionProvider),
            offset: current.products.length,
            limit: current.limit,
          );
      state = AsyncData(CatalogState(
        products: [...current.products, ...response.products],
        total: response.total,
        limit: response.limit,
        filters: response.filters,
      ));
    } catch (error) {
      final message = error is ApiException ? error.message : 'Nu s-au putut incarca mai multe produse.';
      state = AsyncData(CatalogState(
        products: current.products,
        total: current.total,
        limit: current.limit,
        filters: current.filters,
        loadMoreError: message,
      ));
    }
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/product_detail.dart';
import '../../providers.dart';
import 'product_repository.dart';

final productRepositoryProvider =
    Provider<ProductRepository>((ref) => ProductRepository(ref.watch(apiClientProvider)));

/// Cat asteapta controllerul dupa ultima apasare pe +/− inainte sa ceara preturile.
/// Fara el, tinut apasat pe plus ar trimite cate o cerere per apasare.
const quantityDebounce = Duration(milliseconds: 300);

/// Starea paginii de produs: detaliul curent, starea schimbarii de varianta si
/// tabelul de comanda pe variante (cantitati + preturile primite de la server).
///
/// Schimbarea variantei NU trece prin `AsyncLoading`: ar goli ecranul si l-ar
/// reconstrui de la zero (galerie derulata inapoi la prima poza, pozitia de scroll
/// pierduta) pentru o schimbare care atinge doar pretul, codul si galeria. In loc
/// de asta, detaliul vechi ramane pe ecran cu `isSwitchingVariant` pana vine
/// raspunsul. Aceeasi regula si pentru preturile tabelului: cifrele vechi raman pe
/// ecran cat timp cererea noua e in aer.
class ProductState {
  const ProductState({
    required this.detail,
    this.isSwitchingVariant = false,
    this.variantError,
    this.quantities = const {},
    this.prices,
    this.isPricing = false,
    this.pricesError,
  });

  final ProductDetail detail;

  /// True cat timp se asteapta raspunsul pentru varianta nou aleasa.
  final bool isSwitchingVariant;

  /// Mesaj pentru o schimbare de varianta esuata. Detaliul ramane cel dinainte —
  /// un esec pe o varianta nu are voie sa arunce tot ecranul pe pagina de eroare.
  final String? variantError;

  /// Cantitatea aleasa pentru fiecare varianta din tabel, in ordinea randurilor.
  /// Porneste cu zero pe toate.
  final Map<int, int> quantities;

  /// Ultimul raspuns al rutei de preturi: subtotaluri si total, gata formatate.
  /// `null` inainte de prima schimbare de cantitate — pana atunci nu exista niciun
  /// sir de bani de aratat, iar aplicatia nu are voie sa inventeze unul.
  final VariantPrices? prices;

  /// True cat timp o cerere de preturi e in aer. Cifrele din `prices` raman cele
  /// dinainte, ca tabelul sa nu clipeasca la fiecare apasare pe plus.
  final bool isPricing;

  /// Mesaj pentru o cerere de preturi esuata; `prices` ramane ce era.
  final String? pricesError;

  /// Atentie: cele doua mesaje de eroare (`variantError`, `pricesError`) **nu** se
  /// mostenesc — se pastreaza doar daca sunt date explicit. Sunt mesaje despre
  /// ultima actiune, nu stare permanenta: altfel un esec de acum ar ramane sub
  /// tabel si dupa ce urmatoarea cerere a reusit.
  ProductState copyWith({
    ProductDetail? detail,
    bool? isSwitchingVariant,
    String? variantError,
    Map<int, int>? quantities,
    VariantPrices? prices,
    bool? isPricing,
    String? pricesError,
  }) =>
      ProductState(
        detail: detail ?? this.detail,
        isSwitchingVariant: isSwitchingVariant ?? this.isSwitchingVariant,
        variantError: variantError,
        quantities: quantities ?? this.quantities,
        prices: prices ?? this.prices,
        isPricing: isPricing ?? this.isPricing,
        pricesError: pricesError,
      );
}

/// Cate un controller per produs (`family` pe id): deschiderea unui produs similar
/// din pagina curenta nu are voie sa suprascrie starea produsului de dedesubt, ca
/// sa functioneze butonul de inapoi. `autoDispose`: starea dispare cand ecranul se
/// inchide, altfel fiecare produs vizitat ar ramane in memorie pana la relansare.
final productControllerProvider =
    AsyncNotifierProvider.autoDispose.family<ProductController, ProductState, int>(
  ProductController.new,
  // retry: null - vezi CLAUDE.md, gotcha 3: fara asta o eroare din build() ar fi
  // reincercata automat cu backoff pana la ~38s, iar ecranul de eroare ar aparea
  // abia atunci.
  retry: (retryCount, error) => null,
);

class ProductController extends AsyncNotifier<ProductState> {
  ProductController(this.productId);

  final int productId;

  Timer? _debounce;

  /// Numarul cererii de preturi. Raspunsurile pot veni in alta ordine decat au
  /// plecat (o cerere lenta la 3 bucati poate ajunge dupa una rapida la 8): doar
  /// raspunsul ultimei cereri are voie sa scrie in stare.
  int _pricingRequest = 0;

  @override
  Future<ProductState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final detail = await ref.watch(productRepositoryProvider).getProduct(productId);
    // Cate o cantitate per rand de varianta, toate zero. Ordinea randurilor e cea
    // primita de la server si se pastreaza pana in corpul cererii de preturi.
    return ProductState(
      detail: detail,
      quantities: {for (final row in detail.variantRows) row.variantId: 0},
    );
  }

  /// Reincarca produsul de la zero (butonul "Reincearca" din ecranul de eroare).
  void retry() => ref.invalidateSelf();

  /// Alegerea unei valori de atribut din selectorul de variante. Serverul
  /// recalculeaza pretul, codul si galeria pentru combinatia ceruta — aplicatia nu
  /// deduce nimic local.
  ///
  /// Ecranul stie doar id-ul valorii apasate; combinatia completa de trimis vine de
  /// la server, pe fiecare valoare din selector (`combination`). Un esec nu arunca
  /// tot ecranul pe pagina de eroare: detaliul vechi ramane si apare un mesaj.
  Future<void> selectVariantValue(int valueId) async {
    final current = state.value;
    if (current == null || current.isSwitchingVariant) return;
    state = AsyncData(current.copyWith(isSwitchingVariant: true));
    try {
      final detail = await ref
          .read(productRepositoryProvider)
          .getProduct(productId, values: _combinationFor(valueId, current.detail));
      // Detaliu nou = tabel nou: cantitatile si preturile de dinainte erau ale altei
      // combinatii. (In practica selectorul si tabelul nu apar impreuna — un produs
      // cu doua valori pe un atribut are doua variante, deci are randuri.)
      state = AsyncData(ProductState(
        detail: detail,
        quantities: {for (final row in detail.variantRows) row.variantId: 0},
      ));
    } catch (error) {
      state = AsyncData(current.copyWith(
        isSwitchingVariant: false,
        variantError: error is ApiException ? error.message : 'Nu s-a putut schimba varianta.',
      ));
    }
  }

  /// Cantitatea unui rand din tabelul de variante. Steperul raspunde pe loc (starea
  /// se schimba imediat), dar preturile se cer de la server abia dupa
  /// [quantityDebounce] de la ultima apasare: tinut apasat pe plus, pleaca o singura
  /// cerere, cu ultima cantitate.
  ///
  /// Cantitatile negative nu exista: se opresc la zero, deci serverul nu primeste
  /// niciodata una (unde ar fi oricum 422). O cantitate care nu se schimba nu
  /// declanseaza nicio cerere.
  void setQuantity(int variantId, int quantity) {
    final current = state.value;
    if (current == null || !current.quantities.containsKey(variantId)) return;
    final wanted = quantity < 0 ? 0 : quantity;
    if (current.quantities[variantId] == wanted) return;

    state = AsyncData(current.copyWith(
      quantities: {...current.quantities, variantId: wanted},
      // Mesajul de eroare de la incercarea anterioara dispare odata cu apasarea.
      pricesError: null,
    ));

    _debounce?.cancel();
    _debounce = Timer(quantityDebounce, _requestPrices);
  }

  /// Cere serverului preturile pentru cantitatile curente. Cifrele vechi raman in
  /// stare cat timp cererea e in aer (`isPricing`), iar un esec nu arunca ecranul pe
  /// pagina de eroare: pastreaza ultimele preturi si arata un mesaj.
  Future<void> _requestPrices() async {
    final current = state.value;
    if (current == null) return;
    final request = ++_pricingRequest;
    final quantities = Map<int, int>.from(current.quantities);
    state = AsyncData(current.copyWith(isPricing: true));

    try {
      final prices = await ref.read(productRepositoryProvider).priceVariants(productId, quantities);
      final latest = state.value;
      if (latest == null || request != _pricingRequest) return;
      state = AsyncData(latest.copyWith(prices: prices, isPricing: false));
    } catch (error) {
      final latest = state.value;
      if (latest == null || request != _pricingRequest) return;
      state = AsyncData(latest.copyWith(
        isPricing: false,
        pricesError:
            error is ApiException ? error.message : 'Nu s-au putut calcula preturile.',
      ));
    }
  }

  /// Combinatia trimisa de server pentru valoarea apasata. Daca lipseste (server mai
  /// vechi, sau produs cu un singur atribut), se cere valoarea singura: serverul
  /// completeaza combinatiile partiale.
  List<int> _combinationFor(int valueId, ProductDetail detail) {
    for (final attribute in detail.variants?.attributes ?? const <VariantAttribute>[]) {
      for (final value in attribute.values) {
        if (value.id == valueId) {
          return value.combination.isEmpty ? [valueId] : value.combination;
        }
      }
    }
    return [valueId];
  }
}

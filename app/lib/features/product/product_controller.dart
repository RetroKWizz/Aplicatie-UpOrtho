import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/product_detail.dart';
import '../../providers.dart';
import 'product_repository.dart';

final productRepositoryProvider =
    Provider<ProductRepository>((ref) => ProductRepository(ref.watch(apiClientProvider)));

/// Starea paginii de produs: detaliul curent, plus starea schimbarii de varianta.
///
/// Schimbarea variantei NU trece prin `AsyncLoading`: ar goli ecranul si l-ar
/// reconstrui de la zero (galerie derulata inapoi la prima poza, pozitia de scroll
/// pierduta) pentru o schimbare care atinge doar pretul, codul si galeria. In loc
/// de asta, detaliul vechi ramane pe ecran cu `isSwitchingVariant` pana vine
/// raspunsul.
class ProductState {
  const ProductState({
    required this.detail,
    this.isSwitchingVariant = false,
    this.variantError,
  });

  final ProductDetail detail;

  /// True cat timp se asteapta raspunsul pentru varianta nou aleasa.
  final bool isSwitchingVariant;

  /// Mesaj pentru o schimbare de varianta esuata. Detaliul ramane cel dinainte —
  /// un esec pe o varianta nu are voie sa arunce tot ecranul pe pagina de eroare.
  final String? variantError;
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

  @override
  Future<ProductState> build() async {
    final detail = await ref.watch(productRepositoryProvider).getProduct(productId);
    return ProductState(detail: detail);
  }

  /// Reincarca produsul de la zero (butonul "Reincearca" din ecranul de eroare).
  void retry() => ref.invalidateSelf();

  /// Alegerea unei valori de atribut din selectorul de variante. Serverul
  /// recalculeaza pretul, codul si galeria pentru varianta ceruta — aplicatia nu
  /// deduce nimic local.
  ///
  /// ATENTIE (limitare de contract cunoscuta): selectorul emite id-uri de
  /// `product.template.attribute.value`, iar ruta serverului valideaza `variant_id`
  /// contra lui `product.product`. Pana cand ruta accepta si id-ul de valoare (sau
  /// pana cand contractul trimite un `variant_id` per valoare), cererea de mai jos
  /// intoarce 422 pe date reale; de aceea esecul e tratat ca mai jos — detaliul
  /// vechi ramane pe ecran si utilizatorul primeste un mesaj, nu o pagina de
  /// eroare. Vezi raportul Task 6.
  Future<void> selectVariantValue(int valueId) async {
    final current = state.value;
    if (current == null || current.isSwitchingVariant) return;
    state = AsyncData(ProductState(detail: current.detail, isSwitchingVariant: true));
    try {
      final detail =
          await ref.read(productRepositoryProvider).getProduct(productId, variantId: valueId);
      state = AsyncData(ProductState(detail: detail));
    } catch (error) {
      state = AsyncData(ProductState(
        detail: current.detail,
        variantError: error is ApiException ? error.message : 'Nu s-a putut schimba varianta.',
      ));
    }
  }
}

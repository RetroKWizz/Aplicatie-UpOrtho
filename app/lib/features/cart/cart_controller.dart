import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/cart.dart';
import '../../providers.dart';
import 'cart_repository.dart';

final cartRepositoryProvider =
    Provider<CartRepository>((ref) => CartRepository(ref.watch(apiClientProvider)));

final cartControllerProvider = AsyncNotifierProvider<CartController, Cart>(
  CartController.new,
  // retry: null - vezi CLAUDE.md, gotcha 3: fara asta un /cart picat ar arata eroarea
  // abia dupa ~38s de reincercari automate in fundal.
  retry: (retryCount, error) => null,
);

/// Starea cosului, comuna intregii aplicatii: badge-ul din tab bar, ecranul de cos si
/// checkout-ul citesc acelasi provider. Orice modificare inlocuieste starea cu cosul
/// intreg intors de server.
class CartController extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() => ref.watch(cartRepositoryProvider).fetchCart();

  /// Adauga in cos randurile alese in tabelul de variante (sau un singur produs).
  /// Intoarce avertismentele serverului, ca ecranul care a cerut adaugarea sa le
  /// poata arata imediat - ele nu se mai repeta la urmatorul `GET /cart`.
  Future<List<String>> add(Map<int, int> quantities) async {
    final cart = await ref.read(cartRepositoryProvider).addLines(quantities);
    state = AsyncData(cart);
    return cart.warnings;
  }

  Future<void> setQuantity({required int variantId, required int quantity, int? lineId}) async {
    state = AsyncData(await ref
        .read(cartRepositoryProvider)
        .setQuantity(variantId: variantId, quantity: quantity, lineId: lineId));
  }

  Future<void> remove({required int variantId, int? lineId}) async {
    state = AsyncData(
        await ref.read(cartRepositoryProvider).removeLine(variantId: variantId, lineId: lineId));
  }

  /// Preia cosul venit in raspunsul altui ecran (checkout-ul intoarce cosul intreg
  /// la fiecare pas). Fara asta, badge-ul si ecranul de cos ar ramane cu totalurile
  /// de dinainte de alegerea transportului, pana la urmatoarea recitire.
  void adopt(Cart cart) => state = AsyncData(cart);

  /// Reciteste cosul de la server. Se cheama dupa o comanda trimisa (cosul devine
  /// gol) si de butonul "Reincearca" al ecranului de eroare.
  Future<void> refresh() async {
    state = const AsyncLoading<Cart>();
    state = await AsyncValue.guard(() => ref.read(cartRepositoryProvider).fetchCart());
  }
}

/// Cate bucati sunt in cos, pentru pastila de pe tabul "Cos". Zero cat timp cosul se
/// incarca sau a picat: un badge nu merita un ecran de eroare.
final cartQuantityProvider = Provider<int>(
    (ref) => ref.watch(cartControllerProvider).maybeWhen(data: (cart) => cart.quantity, orElse: () => 0));

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/checkout.dart';
import '../../providers.dart';
import '../cart/cart_controller.dart';
import 'checkout_repository.dart';

final checkoutRepositoryProvider =
    Provider<CheckoutRepository>((ref) => CheckoutRepository(ref.watch(apiClientProvider)));

final checkoutControllerProvider = AsyncNotifierProvider<CheckoutController, Checkout>(
  CheckoutController.new,
  // retry: null - vezi CLAUDE.md, gotcha 3.
  retry: (retryCount, error) => null,
);

/// Controllerul ecranului de checkout. Fiecare pas inlocuieste starea cu checkout-ul
/// intreg recalculat de server; nimic nu se deduce local.
class CheckoutController extends AsyncNotifier<Checkout> {
  @override
  Future<Checkout> build() => ref.watch(checkoutRepositoryProvider).fetchCheckout();

  Future<void> chooseDeliveryAddress(int partnerId) =>
      _apply(() => ref.read(checkoutRepositoryProvider).setAddress(deliveryId: partnerId));

  Future<void> chooseInvoiceAddress(int partnerId) =>
      _apply(() => ref.read(checkoutRepositoryProvider).setAddress(invoiceId: partnerId));

  Future<void> chooseDeliveryMethod(int carrierId) =>
      _apply(() => ref.read(checkoutRepositoryProvider).setDeliveryMethod(carrierId));

  Future<void> reload() => _apply(() => ref.read(checkoutRepositoryProvider).fetchCheckout());

  /// Trimite comanda. Dupa un raspuns reusit, cosul e recitit: la plata offline el a
  /// devenit deja o comanda, deci badge-ul si ecranul de cos trebuie sa arate zero.
  ///
  /// Erorile NU se inghit: ecranul le arata (409 cos gol sau deja trimis, 422 metoda
  /// de plata indisponibila), iar starea checkout-ului ramane cea de dinainte.
  Future<CheckoutConfirmation> confirm(PaymentOption option) async {
    final confirmation = await ref.read(checkoutRepositoryProvider).confirm(option);
    await ref.read(cartControllerProvider.notifier).refresh();
    return confirmation;
  }

  Future<void> _apply(Future<Checkout> Function() action) async {
    state = const AsyncLoading<Checkout>();
    state = await AsyncValue.guard(action);
    // Totalurile cosului se schimba odata cu transportul: ecranul de cos si badge-ul
    // citesc alt provider, deci trebuie anuntate.
    final checkout = state.value;
    if (checkout != null) {
      ref.read(cartControllerProvider.notifier).adopt(checkout.cart);
    }
  }
}

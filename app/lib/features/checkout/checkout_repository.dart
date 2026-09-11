import '../../api/api_client.dart';
import '../../api/models/checkout.dart';

/// Repository pentru checkout. Fiecare pas intoarce checkout-ul intreg, recalculat de
/// server: alegerea altei adrese poate scoate curierul ales (alt judet, alt tarif),
/// iar alegerea altui curier schimba totalul si poate schimba metodele de plata
/// permise (magazinul leaga providerii de curier). Un raspuns partial ar lasa ecranul
/// cu cifre vechi langa cifre noi.
class CheckoutRepository {
  CheckoutRepository(this._api);
  final ApiClient _api;

  Future<Checkout> fetchCheckout() async => Checkout.fromJson(await _api.get('/checkout'));

  Future<Checkout> setAddress({int? deliveryId, int? invoiceId}) async =>
      Checkout.fromJson(await _api.post('/checkout/address', body: {
        if (deliveryId case final int id) 'delivery_id': id,
        if (invoiceId case final int id) 'invoice_id': id,
      }));

  Future<Checkout> setDeliveryMethod(int carrierId) async =>
      Checkout.fromJson(await _api.post('/checkout/delivery', body: {'carrier_id': carrierId}));

  Future<CheckoutConfirmation> confirm(PaymentOption option) async =>
      CheckoutConfirmation.fromJson(await _api.post('/checkout/confirm', body: {
        'payment_method_id': option.paymentMethodId,
        'provider_id': option.providerId,
        // Cardul salvat se identifica si prin token: aceeasi metoda si acelasi
        // provider pot avea mai multe carduri.
        if (option.tokenId case final int id) 'token_id': id,
      }));
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'cart.dart';
import 'description_block.dart';

export 'cart.dart';
export 'description_block.dart';

part 'checkout.freezed.dart';
part 'checkout.g.dart';

/// O adresa a contului. Aplicatia alege dintre adresele existente; adaugarea unei
/// adrese noi ramane pe site, unde traiesc validarile clientului (CUI, oras din
/// lista) - doua validari paralele s-ar putea contrazice.
@freezed
abstract class Address with _$Address {
  const factory Address({
    required int id,
    required String name,
    String? street,
    String? street2,
    String? city,
    String? zip,
    String? state,
    String? country,
    String? phone,
    String? email,
    String? vat,
    String? type,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  const Address._();

  /// Adresa pe un singur rand, pentru cardurile de selectie.
  String get oneLine => [
        street,
        street2,
        city,
        state,
        zip,
      ].where((part) => part != null && part.isNotEmpty).join(', ');
}

/// Adresele alese si cele disponibile.
@freezed
abstract class CheckoutAddresses with _$CheckoutAddresses {
  const factory CheckoutAddresses({
    @JsonKey(name: 'delivery_id') int? deliveryId,
    @JsonKey(name: 'invoice_id') int? invoiceId,
    @Default([]) List<Address> available,
  }) = _CheckoutAddresses;

  factory CheckoutAddresses.fromJson(Map<String, dynamic> json) =>
      _$CheckoutAddressesFromJson(json);
}

/// Un curier, cu tariful lui pentru cosul curent (cu TVA, ca tot restul API-ului).
///
/// `available: false` inseamna ca tariful nu s-a putut calcula pentru adresa aleasa;
/// randul ramane vizibil, cu motivul in `error`, exact ca pe site - scos din lista,
/// clientul n-ar afla de ce lipseste.
@freezed
abstract class DeliveryMethod with _$DeliveryMethod {
  const factory DeliveryMethod({
    required int id,
    required String name,
    String? description,
    required Price price,
    @Default(false) bool free,
    @Default(true) bool available,
    String? error,
    @JsonKey(name: 'logo_url') String? logoUrl,
  }) = _DeliveryMethod;

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) => _$DeliveryMethodFromJson(json);
}

/// O metoda de plata oferita de magazin pentru aceasta comanda.
///
/// `kind` spune ce face aplicatia mai departe:
/// - `offline` (transfer bancar, plata la livrare) - comanda se trimite direct din
///   aplicatie, iar `instructions` e textul configurat de magazin;
/// - `webview` (card) - aplicatia deschide pagina de plata a magazinului intr-un
///   WebView, cu aceeasi sesiune. Datele cardului nu trec niciodata prin aplicatie.
@freezed
abstract class PaymentOption with _$PaymentOption {
  const factory PaymentOption({
    @JsonKey(name: 'payment_method_id') required int paymentMethodId,
    @JsonKey(name: 'provider_id') required int providerId,
    required String name,
    @JsonKey(name: 'provider_name') required String providerName,
    required String code,
    required String kind,
    /// Textul configurat de magazin, deja convertit din HTML in blocuri de catre
    /// server (aplicatia nu are motor HTML).
    @Default([]) List<DescriptionBlock> instructions,
    @JsonKey(name: 'is_test') @Default(false) bool isTest,
  }) = _PaymentOption;

  factory PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);

  const PaymentOption._();

  bool get isOffline => kind == 'offline';
}

/// De ce nu se poate trimite inca comanda. Textul vine de la server, tradus acolo.
@freezed
abstract class CheckoutBlocker with _$CheckoutBlocker {
  const factory CheckoutBlocker({required String code, required String message}) =
      _CheckoutBlocker;

  factory CheckoutBlocker.fromJson(Map<String, dynamic> json) => _$CheckoutBlockerFromJson(json);
}

@freezed
abstract class Checkout with _$Checkout {
  const factory Checkout({
    @JsonKey(name: 'order_id') required int orderId,
    required Cart cart,
    required CheckoutAddresses addresses,
    @JsonKey(name: 'delivery_methods') @Default([]) List<DeliveryMethod> deliveryMethods,
    @JsonKey(name: 'selected_delivery_method_id') int? selectedDeliveryMethodId,
    @JsonKey(name: 'delivery_required') @Default(true) bool deliveryRequired,
    @JsonKey(name: 'payment_options') @Default([]) List<PaymentOption> paymentOptions,
    @Default([]) List<CheckoutBlocker> blockers,
  }) = _Checkout;

  factory Checkout.fromJson(Map<String, dynamic> json) => _$CheckoutFromJson(json);

  const Checkout._();

  bool get canConfirm => blockers.isEmpty && paymentOptions.isNotEmpty;
}

/// Ce trebuie facut dupa `POST /checkout/confirm`.
@freezed
abstract class PaymentOutcome with _$PaymentOutcome {
  const factory PaymentOutcome({
    required String kind,
    String? method,
    @Default([]) List<DescriptionBlock> instructions,
    String? reference,
    String? url,
    @JsonKey(name: 'return_url_prefix') String? returnUrlPrefix,
  }) = _PaymentOutcome;

  factory PaymentOutcome.fromJson(Map<String, dynamic> json) => _$PaymentOutcomeFromJson(json);

  const PaymentOutcome._();

  bool get isOffline => kind == 'offline';
}

@freezed
abstract class CheckoutConfirmation with _$CheckoutConfirmation {
  const factory CheckoutConfirmation({
    @JsonKey(name: 'order_id') required int orderId,
    @JsonKey(name: 'order_ref') required String orderRef,
    required PaymentOutcome payment,
  }) = _CheckoutConfirmation;

  factory CheckoutConfirmation.fromJson(Map<String, dynamic> json) =>
      _$CheckoutConfirmationFromJson(json);
}

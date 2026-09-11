// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  street: json['street'] as String?,
  street2: json['street2'] as String?,
  city: json['city'] as String?,
  zip: json['zip'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  vat: json['vat'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'street': instance.street,
  'street2': instance.street2,
  'city': instance.city,
  'zip': instance.zip,
  'state': instance.state,
  'country': instance.country,
  'phone': instance.phone,
  'email': instance.email,
  'vat': instance.vat,
  'type': instance.type,
};

_CheckoutAddresses _$CheckoutAddressesFromJson(Map<String, dynamic> json) =>
    _CheckoutAddresses(
      deliveryId: (json['delivery_id'] as num?)?.toInt(),
      invoiceId: (json['invoice_id'] as num?)?.toInt(),
      available:
          (json['available'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CheckoutAddressesToJson(_CheckoutAddresses instance) =>
    <String, dynamic>{
      'delivery_id': instance.deliveryId,
      'invoice_id': instance.invoiceId,
      'available': instance.available,
    };

_DeliveryMethod _$DeliveryMethodFromJson(Map<String, dynamic> json) =>
    _DeliveryMethod(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: Price.fromJson(json['price'] as Map<String, dynamic>),
      free: json['free'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
      error: json['error'] as String?,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$DeliveryMethodToJson(_DeliveryMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'free': instance.free,
      'available': instance.available,
      'error': instance.error,
      'logo_url': instance.logoUrl,
    };

_PaymentOption _$PaymentOptionFromJson(Map<String, dynamic> json) =>
    _PaymentOption(
      paymentMethodId: (json['payment_method_id'] as num).toInt(),
      providerId: (json['provider_id'] as num).toInt(),
      tokenId: (json['token_id'] as num?)?.toInt(),
      name: json['name'] as String,
      providerName: json['provider_name'] as String,
      code: json['code'] as String,
      kind: json['kind'] as String,
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => DescriptionBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isTest: json['is_test'] as bool? ?? false,
    );

Map<String, dynamic> _$PaymentOptionToJson(_PaymentOption instance) =>
    <String, dynamic>{
      'payment_method_id': instance.paymentMethodId,
      'provider_id': instance.providerId,
      'token_id': instance.tokenId,
      'name': instance.name,
      'provider_name': instance.providerName,
      'code': instance.code,
      'kind': instance.kind,
      'instructions': instance.instructions,
      'is_test': instance.isTest,
    };

_CheckoutBlocker _$CheckoutBlockerFromJson(Map<String, dynamic> json) =>
    _CheckoutBlocker(
      code: json['code'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$CheckoutBlockerToJson(_CheckoutBlocker instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

_Checkout _$CheckoutFromJson(Map<String, dynamic> json) => _Checkout(
  orderId: (json['order_id'] as num).toInt(),
  cart: Cart.fromJson(json['cart'] as Map<String, dynamic>),
  addresses: CheckoutAddresses.fromJson(
    json['addresses'] as Map<String, dynamic>,
  ),
  deliveryMethods:
      (json['delivery_methods'] as List<dynamic>?)
          ?.map((e) => DeliveryMethod.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  selectedDeliveryMethodId: (json['selected_delivery_method_id'] as num?)
      ?.toInt(),
  deliveryRequired: json['delivery_required'] as bool? ?? true,
  paymentOptions:
      (json['payment_options'] as List<dynamic>?)
          ?.map((e) => PaymentOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  blockers:
      (json['blockers'] as List<dynamic>?)
          ?.map((e) => CheckoutBlocker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CheckoutToJson(_Checkout instance) => <String, dynamic>{
  'order_id': instance.orderId,
  'cart': instance.cart,
  'addresses': instance.addresses,
  'delivery_methods': instance.deliveryMethods,
  'selected_delivery_method_id': instance.selectedDeliveryMethodId,
  'delivery_required': instance.deliveryRequired,
  'payment_options': instance.paymentOptions,
  'blockers': instance.blockers,
};

_PaymentOutcome _$PaymentOutcomeFromJson(Map<String, dynamic> json) =>
    _PaymentOutcome(
      kind: json['kind'] as String,
      method: json['method'] as String?,
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => DescriptionBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reference: json['reference'] as String?,
      state: json['state'] as String?,
      message: json['message'] as String?,
      url: json['url'] as String?,
      returnUrlPrefix: json['return_url_prefix'] as String?,
    );

Map<String, dynamic> _$PaymentOutcomeToJson(_PaymentOutcome instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'method': instance.method,
      'instructions': instance.instructions,
      'reference': instance.reference,
      'state': instance.state,
      'message': instance.message,
      'url': instance.url,
      'return_url_prefix': instance.returnUrlPrefix,
    };

_CheckoutConfirmation _$CheckoutConfirmationFromJson(
  Map<String, dynamic> json,
) => _CheckoutConfirmation(
  orderId: (json['order_id'] as num).toInt(),
  orderRef: json['order_ref'] as String,
  payment: PaymentOutcome.fromJson(json['payment'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CheckoutConfirmationToJson(
  _CheckoutConfirmation instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'order_ref': instance.orderRef,
  'payment': instance.payment,
};

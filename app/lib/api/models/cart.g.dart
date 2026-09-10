// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartLine _$CartLineFromJson(Map<String, dynamic> json) => _CartLine(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  variantId: (json['variant_id'] as num).toInt(),
  name: json['name'] as String,
  variantName: json['variant_name'] as String?,
  defaultCode: json['default_code'] as String?,
  imageUrl: json['image_url'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: Price.fromJson(json['unit_price'] as Map<String, dynamic>),
  subtotal: Price.fromJson(json['subtotal'] as Map<String, dynamic>),
  warning: json['warning'] as String?,
);

Map<String, dynamic> _$CartLineToJson(_CartLine instance) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'variant_id': instance.variantId,
  'name': instance.name,
  'variant_name': instance.variantName,
  'default_code': instance.defaultCode,
  'image_url': instance.imageUrl,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'subtotal': instance.subtotal,
  'warning': instance.warning,
};

_CartAmounts _$CartAmountsFromJson(Map<String, dynamic> json) => _CartAmounts(
  untaxed: Price.fromJson(json['untaxed'] as Map<String, dynamic>),
  tax: Price.fromJson(json['tax'] as Map<String, dynamic>),
  delivery: Price.fromJson(json['delivery'] as Map<String, dynamic>),
  total: Price.fromJson(json['total'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CartAmountsToJson(_CartAmounts instance) =>
    <String, dynamic>{
      'untaxed': instance.untaxed,
      'tax': instance.tax,
      'delivery': instance.delivery,
      'total': instance.total,
    };

_FreeDeliveryProgress _$FreeDeliveryProgressFromJson(
  Map<String, dynamic> json,
) => _FreeDeliveryProgress(
  freeOver: Price.fromJson(json['free_over'] as Map<String, dynamic>),
  orderAmount: Price.fromJson(json['order_amount'] as Map<String, dynamic>),
  remaining: Price.fromJson(json['remaining'] as Map<String, dynamic>),
  reached: json['reached'] as bool,
);

Map<String, dynamic> _$FreeDeliveryProgressToJson(
  _FreeDeliveryProgress instance,
) => <String, dynamic>{
  'free_over': instance.freeOver,
  'order_amount': instance.orderAmount,
  'remaining': instance.remaining,
  'reached': instance.reached,
};

_Cart _$CartFromJson(Map<String, dynamic> json) => _Cart(
  orderId: (json['order_id'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  amounts: CartAmounts.fromJson(json['amounts'] as Map<String, dynamic>),
  freeDelivery: json['free_delivery'] == null
      ? null
      : FreeDeliveryProgress.fromJson(
          json['free_delivery'] as Map<String, dynamic>,
        ),
  warning: json['warning'] as String?,
  warnings:
      (json['warnings'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$CartToJson(_Cart instance) => <String, dynamic>{
  'order_id': instance.orderId,
  'quantity': instance.quantity,
  'lines': instance.lines,
  'amounts': instance.amounts,
  'free_delivery': instance.freeDelivery,
  'warning': instance.warning,
  'warnings': instance.warnings,
};

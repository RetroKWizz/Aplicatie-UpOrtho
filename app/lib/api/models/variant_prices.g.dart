// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_prices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VariantPriceLine _$VariantPriceLineFromJson(Map<String, dynamic> json) =>
    _VariantPriceLine(
      variantId: (json['variant_id'] as num).toInt(),
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      price: Price.fromJson(json['price'] as Map<String, dynamic>),
      subtotal: Price.fromJson(json['subtotal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VariantPriceLineToJson(_VariantPriceLine instance) =>
    <String, dynamic>{
      'variant_id': instance.variantId,
      'qty': instance.qty,
      'price': instance.price,
      'subtotal': instance.subtotal,
    };

_VariantPrices _$VariantPricesFromJson(Map<String, dynamic> json) =>
    _VariantPrices(
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((e) => VariantPriceLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: Price.fromJson(json['total'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VariantPricesToJson(_VariantPrices instance) =>
    <String, dynamic>{'lines': instance.lines, 'total': instance.total};

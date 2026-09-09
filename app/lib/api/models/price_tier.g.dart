// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceTier _$PriceTierFromJson(Map<String, dynamic> json) => _PriceTier(
  minQty: (json['min_qty'] as num).toInt(),
  label: json['label'] as String,
  price: Price.fromJson(json['price'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PriceTierToJson(_PriceTier instance) =>
    <String, dynamic>{
      'min_qty': instance.minQty,
      'label': instance.label,
      'price': instance.price,
    };

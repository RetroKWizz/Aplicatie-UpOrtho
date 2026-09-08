// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Price _$PriceFromJson(Map<String, dynamic> json) => _Price(
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  formatted: json['formatted'] as String,
  withVat: json['with_vat'] as bool? ?? true,
  listAmount: (json['list_amount'] as num?)?.toDouble(),
  listFormatted: json['list_formatted'] as String?,
  discountPct: (json['discount_pct'] as num?)?.toInt(),
);

Map<String, dynamic> _$PriceToJson(_Price instance) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
  'formatted': instance.formatted,
  'with_vat': instance.withVat,
  'list_amount': instance.listAmount,
  'list_formatted': instance.listFormatted,
  'discount_pct': instance.discountPct,
};

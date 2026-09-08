// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductBadge _$ProductBadgeFromJson(Map<String, dynamic> json) =>
    _ProductBadge(
      text: json['text'] as String,
      color: $enumDecode(
        _$ProductBadgeColorEnumMap,
        json['color'],
        unknownValue: ProductBadgeColor.orange,
      ),
    );

Map<String, dynamic> _$ProductBadgeToJson(_ProductBadge instance) =>
    <String, dynamic>{
      'text': instance.text,
      'color': _$ProductBadgeColorEnumMap[instance.color]!,
    };

const _$ProductBadgeColorEnumMap = {
  ProductBadgeColor.orange: 'orange',
  ProductBadgeColor.green: 'green',
  ProductBadgeColor.blue: 'blue',
  ProductBadgeColor.purple: 'purple',
  ProductBadgeColor.red: 'red',
};

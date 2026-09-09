// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceTable _$PriceTableFromJson(Map<String, dynamic> json) => _PriceTable(
  title: json['title'] as String?,
  note:
      (json['note'] as List<dynamic>?)
          ?.map((e) => DescriptionBlock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => PriceTier.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PriceTableToJson(_PriceTable instance) =>
    <String, dynamic>{
      'title': instance.title,
      'note': instance.note,
      'entries': instance.entries,
    };

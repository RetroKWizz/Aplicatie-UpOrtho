// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VariantValue _$VariantValueFromJson(Map<String, dynamic> json) =>
    _VariantValue(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      selected: json['selected'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
      combination:
          (json['combination'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$VariantValueToJson(_VariantValue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'selected': instance.selected,
      'available': instance.available,
      'combination': instance.combination,
    };

_VariantAttribute _$VariantAttributeFromJson(Map<String, dynamic> json) =>
    _VariantAttribute(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      values:
          (json['values'] as List<dynamic>?)
              ?.map((e) => VariantValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$VariantAttributeToJson(_VariantAttribute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'values': instance.values,
    };

_VariantOptions _$VariantOptionsFromJson(Map<String, dynamic> json) =>
    _VariantOptions(
      selected:
          (json['selected'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map((e) => VariantAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$VariantOptionsToJson(_VariantOptions instance) =>
    <String, dynamic>{
      'selected': instance.selected,
      'attributes': instance.attributes,
    };

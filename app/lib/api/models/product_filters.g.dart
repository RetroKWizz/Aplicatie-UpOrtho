// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttributeFilterValue _$AttributeFilterValueFromJson(
  Map<String, dynamic> json,
) => _AttributeFilterValue(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String?,
  count: (json['count'] as num?)?.toInt() ?? 0,
  selected: json['selected'] as bool? ?? false,
);

Map<String, dynamic> _$AttributeFilterValueToJson(
  _AttributeFilterValue instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'count': instance.count,
  'selected': instance.selected,
};

_AttributeFilter _$AttributeFilterFromJson(Map<String, dynamic> json) =>
    _AttributeFilter(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      displayType: json['display_type'] as String?,
      values:
          (json['values'] as List<dynamic>?)
              ?.map(
                (e) => AttributeFilterValue.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AttributeFilterToJson(_AttributeFilter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'display_type': instance.displayType,
      'values': instance.values,
    };

_PriceFilter _$PriceFilterFromJson(Map<String, dynamic> json) => _PriceFilter(
  min: (json['min'] as num?)?.toDouble() ?? 0,
  max: (json['max'] as num?)?.toDouble() ?? 0,
  selectedMin: (json['selected_min'] as num?)?.toDouble(),
  selectedMax: (json['selected_max'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PriceFilterToJson(_PriceFilter instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'selected_min': instance.selectedMin,
      'selected_max': instance.selectedMax,
    };

_SortOption _$SortOptionFromJson(Map<String, dynamic> json) => _SortOption(
  key: json['key'] as String,
  name: json['name'] as String,
  selected: json['selected'] as bool? ?? false,
);

Map<String, dynamic> _$SortOptionToJson(_SortOption instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'selected': instance.selected,
    };

_ProductFilters _$ProductFiltersFromJson(Map<String, dynamic> json) =>
    _ProductFilters(
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map((e) => AttributeFilter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      price: json['price'] == null
          ? const PriceFilter()
          : PriceFilter.fromJson(json['price'] as Map<String, dynamic>),
      sorts:
          (json['sorts'] as List<dynamic>?)
              ?.map((e) => SortOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductFiltersToJson(_ProductFilters instance) =>
    <String, dynamic>{
      'attributes': instance.attributes,
      'price': instance.price,
      'sorts': instance.sorts,
    };

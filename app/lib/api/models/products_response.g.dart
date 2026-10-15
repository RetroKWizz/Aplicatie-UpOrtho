// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductsResponse _$ProductsResponseFromJson(Map<String, dynamic> json) =>
    _ProductsResponse(
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pricing: json['pricing'] == null
          ? const Pricing()
          : Pricing.fromJson(json['pricing'] as Map<String, dynamic>),
      total: (json['total'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      filters: json['filters'] == null
          ? const ProductFilters()
          : ProductFilters.fromJson(json['filters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductsResponseToJson(_ProductsResponse instance) =>
    <String, dynamic>{
      'products': instance.products,
      'pricing': instance.pricing,
      'total': instance.total,
      'offset': instance.offset,
      'limit': instance.limit,
      'filters': instance.filters,
    };

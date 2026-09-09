// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductBrand _$ProductBrandFromJson(Map<String, dynamic> json) =>
    _ProductBrand(
      name: json['name'] as String,
      description:
          (json['description'] as List<dynamic>?)
              ?.map((e) => DescriptionBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$ProductBrandToJson(_ProductBrand instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'logo_url': instance.logoUrl,
    };

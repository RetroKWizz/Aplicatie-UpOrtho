// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeBrand _$HomeBrandFromJson(Map<String, dynamic> json) => _HomeBrand(
  id: (json['id'] as num).toInt(),
  attributeId: (json['attribute_id'] as num).toInt(),
  name: json['name'] as String,
  productCount: (json['product_count'] as num?)?.toInt() ?? 0,
  logoUrl: json['logo_url'] as String?,
);

Map<String, dynamic> _$HomeBrandToJson(_HomeBrand instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attribute_id': instance.attributeId,
      'name': instance.name,
      'product_count': instance.productCount,
      'logo_url': instance.logoUrl,
    };

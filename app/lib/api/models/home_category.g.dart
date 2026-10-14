// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeCategory _$HomeCategoryFromJson(Map<String, dynamic> json) =>
    _HomeCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      iconUrl: json['icon_url'] as String?,
    );

Map<String, dynamic> _$HomeCategoryToJson(_HomeCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'product_count': instance.productCount,
      'icon_url': instance.iconUrl,
    };

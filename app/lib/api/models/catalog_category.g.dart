// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogCategory _$CatalogCategoryFromJson(Map<String, dynamic> json) =>
    _CatalogCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      parentId: (json['parent_id'] as num?)?.toInt(),
      iconUrl: json['icon_url'] as String?,
      productCount: (json['product_count'] as num).toInt(),
    );

Map<String, dynamic> _$CatalogCategoryToJson(_CatalogCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent_id': instance.parentId,
      'icon_url': instance.iconUrl,
      'product_count': instance.productCount,
    };

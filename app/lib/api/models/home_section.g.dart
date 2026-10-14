// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeSection _$HomeSectionFromJson(Map<String, dynamic> json) => _HomeSection(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  categoryId: (json['category_id'] as num?)?.toInt(),
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HomeSectionToJson(_HomeSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category_id': instance.categoryId,
      'products': instance.products,
    };

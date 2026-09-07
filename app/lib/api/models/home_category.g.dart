// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeCategory _$HomeCategoryFromJson(Map<String, dynamic> json) =>
    _HomeCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
    );

Map<String, dynamic> _$HomeCategoryToJson(_HomeCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_url': instance.iconUrl,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeResponse _$HomeResponseFromJson(Map<String, dynamic> json) =>
    _HomeResponse(
      banners:
          (json['banners'] as List<dynamic>?)
              ?.map((e) => AppBanner.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      quickCategories:
          (json['quick_categories'] as List<dynamic>?)
              ?.map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      brands:
          (json['brands'] as List<dynamic>?)
              ?.map((e) => HomeBrand.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HomeResponseToJson(_HomeResponse instance) =>
    <String, dynamic>{
      'banners': instance.banners,
      'quick_categories': instance.quickCategories,
      'brands': instance.brands,
      'sections': instance.sections,
    };

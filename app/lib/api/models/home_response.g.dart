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
      pricing: json['pricing'] == null
          ? const Pricing()
          : Pricing.fromJson(json['pricing'] as Map<String, dynamic>),
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
      social:
          (json['social'] as List<dynamic>?)
              ?.map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      instagram: json['instagram'] == null
          ? null
          : InstagramFeed.fromJson(json['instagram'] as Map<String, dynamic>),
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HomeResponseToJson(_HomeResponse instance) =>
    <String, dynamic>{
      'banners': instance.banners,
      'pricing': instance.pricing,
      'quick_categories': instance.quickCategories,
      'brands': instance.brands,
      'social': instance.social,
      'instagram': instance.instagram,
      'sections': instance.sections,
    };

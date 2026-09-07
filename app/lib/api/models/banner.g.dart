// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BannerLink _$BannerLinkFromJson(Map<String, dynamic> json) => _BannerLink(
  type: $enumDecode(
    _$BannerLinkTypeEnumMap,
    json['type'],
    unknownValue: BannerLinkType.none,
  ),
  categoryId: (json['category_id'] as num?)?.toInt(),
  url: json['url'] as String?,
);

Map<String, dynamic> _$BannerLinkToJson(_BannerLink instance) =>
    <String, dynamic>{
      'type': _$BannerLinkTypeEnumMap[instance.type]!,
      'category_id': instance.categoryId,
      'url': instance.url,
    };

const _$BannerLinkTypeEnumMap = {
  BannerLinkType.category: 'category',
  BannerLinkType.url: 'url',
  BannerLinkType.none: 'none',
};

_AppBanner _$AppBannerFromJson(Map<String, dynamic> json) => _AppBanner(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
  ctaText: json['cta_text'] as String?,
  placement: $enumDecode(
    _$BannerPlacementEnumMap,
    json['placement'],
    unknownValue: BannerPlacement.promo,
  ),
  imageUrl: json['image_url'] as String?,
  link: BannerLink.fromJson(json['link'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppBannerToJson(_AppBanner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'cta_text': instance.ctaText,
      'placement': _$BannerPlacementEnumMap[instance.placement]!,
      'image_url': instance.imageUrl,
      'link': instance.link,
    };

const _$BannerPlacementEnumMap = {
  BannerPlacement.hero: 'hero',
  BannerPlacement.promo: 'promo',
};

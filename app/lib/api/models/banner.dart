import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

/// Valorile necunoscute cad pe `promo` (afisare in grila, niciodata ca hero).
@JsonEnum(valueField: 'value')
enum BannerPlacement {
  hero('hero'),
  promo('promo');

  const BannerPlacement(this.value);
  final String value;
}

/// Valorile necunoscute cad pe `none` (banner fara actiune, nu link gresit).
@JsonEnum(valueField: 'value')
enum BannerLinkType {
  category('category'),
  url('url'),
  none('none');

  const BannerLinkType(this.value);
  final String value;
}

@freezed
abstract class BannerLink with _$BannerLink {
  const factory BannerLink({
    @JsonKey(unknownEnumValue: BannerLinkType.none) required BannerLinkType type,
    @JsonKey(name: 'category_id') int? categoryId,
    String? url,
  }) = _BannerLink;

  factory BannerLink.fromJson(Map<String, dynamic> json) => _$BannerLinkFromJson(json);
}

@freezed
abstract class AppBanner with _$AppBanner {
  const factory AppBanner({
    required int id,
    required String title,
    String? subtitle,
    @JsonKey(name: 'cta_text') String? ctaText,
    @JsonKey(unknownEnumValue: BannerPlacement.promo) required BannerPlacement placement,
    @JsonKey(name: 'image_url') String? imageUrl,
    required BannerLink link,
  }) = _AppBanner;

  factory AppBanner.fromJson(Map<String, dynamic> json) => _$AppBannerFromJson(json);
}

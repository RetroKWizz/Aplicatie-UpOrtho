import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

/// Valorile necunoscute cad pe `promo` (afisare in grila, niciodata ca hero).
@JsonEnum(valueField: 'value')
enum BannerPlacement {
  hero('hero'),
  promo('promo'),

  /// Banda lata de pe pagina de start a site-ului: poza produsului intr-o parte,
  /// textul si butonul in cealalta, pe fundal deschis.
  feature('feature');

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
    /// Imaginea poarta deja titlul si subtitlul (facuta in afara, in Canva sau
    /// Photoshop). Atunci cardul arata doar poza: scris peste, textul aplicatiei se
    /// suprapunea peste cel din imagine. Titlul ramane eticheta pentru cititoarele
    /// de ecran.
    @JsonKey(name: 'image_only') @Default(false) bool imageOnly,
    @JsonKey(name: 'image_url') String? imageUrl,
    required BannerLink link,
  }) = _AppBanner;

  factory AppBanner.fromJson(Map<String, dynamic> json) => _$AppBannerFromJson(json);
}

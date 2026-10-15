import 'package:freezed_annotation/freezed_annotation.dart';

import 'banner.dart';
import 'home_brand.dart';
import 'home_category.dart';
import 'home_section.dart';
import 'instagram_feed.dart';
import 'pricing.dart';
import 'social_link.dart';

export 'banner.dart';
export 'home_brand.dart';
export 'home_category.dart';
export 'home_section.dart';
export 'instagram_feed.dart';
export 'pricing.dart';
export 'social_link.dart';

part 'home_response.freezed.dart';
part 'home_response.g.dart';

@freezed
abstract class HomeResponse with _$HomeResponse {
  const factory HomeResponse({
    @Default([]) List<AppBanner> banners,

    /// Daca preturile din randurile de produse se vad si, altfel, de ce nu.
    @Default(Pricing()) Pricing pricing,
    @JsonKey(name: 'quick_categories') @Default([]) List<HomeCategory> quickCategories,
    @Default([]) List<HomeBrand> brands,
    @Default([]) List<SocialLink> social,
    InstagramFeed? instagram,
    @Default([]) List<HomeSection> sections,
  }) = _HomeResponse;

  factory HomeResponse.fromJson(Map<String, dynamic> json) => _$HomeResponseFromJson(json);
}

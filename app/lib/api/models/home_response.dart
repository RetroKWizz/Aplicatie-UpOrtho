import 'package:freezed_annotation/freezed_annotation.dart';

import 'banner.dart';
import 'home_brand.dart';
import 'home_category.dart';
import 'home_section.dart';
import 'social_link.dart';

export 'banner.dart';
export 'home_brand.dart';
export 'home_category.dart';
export 'home_section.dart';
export 'social_link.dart';

part 'home_response.freezed.dart';
part 'home_response.g.dart';

@freezed
abstract class HomeResponse with _$HomeResponse {
  const factory HomeResponse({
    @Default([]) List<AppBanner> banners,
    @JsonKey(name: 'quick_categories') @Default([]) List<HomeCategory> quickCategories,
    @Default([]) List<HomeBrand> brands,
    @Default([]) List<SocialLink> social,
    @Default([]) List<HomeSection> sections,
  }) = _HomeResponse;

  factory HomeResponse.fromJson(Map<String, dynamic> json) => _$HomeResponseFromJson(json);
}

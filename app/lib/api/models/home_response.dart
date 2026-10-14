import 'package:freezed_annotation/freezed_annotation.dart';

import 'banner.dart';
import 'home_category.dart';
import 'home_section.dart';

export 'banner.dart';
export 'home_category.dart';
export 'home_section.dart';

part 'home_response.freezed.dart';
part 'home_response.g.dart';

@freezed
abstract class HomeResponse with _$HomeResponse {
  const factory HomeResponse({
    @Default([]) List<AppBanner> banners,
    @JsonKey(name: 'quick_categories') @Default([]) List<HomeCategory> quickCategories,
    @Default([]) List<HomeSection> sections,
  }) = _HomeResponse;

  factory HomeResponse.fromJson(Map<String, dynamic> json) => _$HomeResponseFromJson(json);
}

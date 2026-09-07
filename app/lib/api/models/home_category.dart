import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_category.freezed.dart';
part 'home_category.g.dart';

@freezed
abstract class HomeCategory with _$HomeCategory {
  const factory HomeCategory({
    required int id,
    required String name,
    @JsonKey(name: 'icon_url') String? iconUrl,
  }) = _HomeCategory;

  factory HomeCategory.fromJson(Map<String, dynamic> json) => _$HomeCategoryFromJson(json);
}

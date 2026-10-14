import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_category.freezed.dart';
part 'home_category.g.dart';

@freezed
abstract class HomeCategory with _$HomeCategory {
  const factory HomeCategory({
    required int id,
    required String name,
    /// Cate produse are categoria, recursiv - acelasi numar ca in catalog.
    @JsonKey(name: 'product_count') @Default(0) int productCount,
    @JsonKey(name: 'icon_url') String? iconUrl,
  }) = _HomeCategory;

  factory HomeCategory.fromJson(Map<String, dynamic> json) => _$HomeCategoryFromJson(json);
}

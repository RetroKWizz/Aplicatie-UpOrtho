import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_category.freezed.dart';
part 'catalog_category.g.dart';

/// Categorie de catalog (`GET /categories`), diferita de `HomeCategory` (folosita
/// doar pentru sectiunea rapida de pe Acasa): are `parent_id` (arbore) si
/// `product_count`, necesare in ecranul de catalog.
@freezed
abstract class CatalogCategory with _$CatalogCategory {
  const factory CatalogCategory({
    required int id,
    required String name,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'product_count') required int productCount,
  }) = _CatalogCategory;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) => _$CatalogCategoryFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_brand.freezed.dart';
part 'home_brand.g.dart';

/// Un brand de pe Acasa.
///
/// Nu e o lista configurata undeva: e chiar valoarea de atribut dupa care filtreaza si
/// catalogul, de aceea vine cu `attributeId` - apasarea pe un brand cere exact filtrul
/// magazinului, nu o cautare dupa nume.
@freezed
abstract class HomeBrand with _$HomeBrand {
  const factory HomeBrand({
    required int id,
    @JsonKey(name: 'attribute_id') required int attributeId,
    required String name,
    @JsonKey(name: 'product_count') @Default(0) int productCount,
    @JsonKey(name: 'logo_url') String? logoUrl,
  }) = _HomeBrand;

  factory HomeBrand.fromJson(Map<String, dynamic> json) => _$HomeBrandFromJson(json);
}

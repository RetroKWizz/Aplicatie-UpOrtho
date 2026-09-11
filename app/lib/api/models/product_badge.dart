import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_badge.freezed.dart';
part 'product_badge.g.dart';

/// Valorile necunoscute cad pe `orange` (rolul functional existent pentru
/// etichete/oferte in `AppColors.accent` — vezi design_system/colors.dart), niciodata
/// pe o eroare de decodare pentru un camp pur decorativ.
@JsonEnum(valueField: 'value')
enum ProductBadgeColor {
  orange('orange'),
  green('green'),
  blue('blue'),
  purple('purple'),
  red('red');

  const ProductBadgeColor(this.value);
  final String value;
}

/// Eticheta unui produs.
///
/// Pe instanta reala textul si culorile vin de la eticheta magazinului
/// (`dr_label_id` din tema), deci `backgroundColor` si `textColor` sunt culori
/// exacte, in hexazecimal, iar `color` lipseste. Pe o baza fara tema eticheta e a
/// noastra si vine doar cu un nume de culoare din paleta de brand.
@freezed
abstract class ProductBadge with _$ProductBadge {
  const factory ProductBadge({
    required String text,
    @JsonKey(unknownEnumValue: ProductBadgeColor.orange)
    @Default(ProductBadgeColor.orange)
    ProductBadgeColor color,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
  }) = _ProductBadge;

  factory ProductBadge.fromJson(Map<String, dynamic> json) => _$ProductBadgeFromJson(json);
}

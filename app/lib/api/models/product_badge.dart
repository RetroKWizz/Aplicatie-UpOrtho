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

@freezed
abstract class ProductBadge with _$ProductBadge {
  const factory ProductBadge({
    required String text,
    @JsonKey(unknownEnumValue: ProductBadgeColor.orange) required ProductBadgeColor color,
  }) = _ProductBadge;

  factory ProductBadge.fromJson(Map<String, dynamic> json) => _$ProductBadgeFromJson(json);
}

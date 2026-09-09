import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit.freezed.dart';
part 'benefit.g.dart';

/// Iconitele de beneficiu din `uportho.app.benefit`. Valoarea de contract `return`
/// e cuvant rezervat in Dart, de aceea constanta se numeste `returns` si isi
/// pastreaza valoarea din JSON prin `valueField` (acelasi tipar ca
/// `ProductBadgeColor`). Necunoscutele cad pe `info`: o iconita adaugata in Odoo
/// dupa un release nu are voie sa rupa decodarea intregii pagini de produs.
@JsonEnum(valueField: 'value')
enum BenefitIcon {
  club('club'),
  delivery('delivery'),
  returns('return'),
  payment('payment'),
  info('info');

  const BenefitIcon(this.value);
  final String value;
}

/// Un bloc de beneficii de magazin (livrare gratuita, retur, plata sigura),
/// editabil din Odoo. `text` e optional — in Odoo doar titlul e obligatoriu.
@freezed
abstract class Benefit with _$Benefit {
  const factory Benefit({
    @JsonKey(unknownEnumValue: BenefitIcon.info) required BenefitIcon icon,
    required String title,
    String? text,
  }) = _Benefit;

  factory Benefit.fromJson(Map<String, dynamic> json) => _$BenefitFromJson(json);
}

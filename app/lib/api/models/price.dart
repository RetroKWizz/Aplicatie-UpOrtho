import 'package:freezed_annotation/freezed_annotation.dart';

part 'price.freezed.dart';
part 'price.g.dart';

/// Pret gata calculat de server. Aplicatia afiseaza DOAR `formatted`; `amount` exista
/// pentru comparatii (ex. "e reducere?"), niciodata pentru calcule.
@freezed
abstract class Price with _$Price {
  const factory Price({
    required double amount,
    required String currency,
    required String formatted,
    @JsonKey(name: 'with_vat') @Default(true) bool withVat,
    @JsonKey(name: 'list_amount') double? listAmount,
    @JsonKey(name: 'discount_pct') int? discountPct,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}

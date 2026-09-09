import 'package:freezed_annotation/freezed_annotation.dart';

import 'price.dart';

export 'price.dart';

part 'variant_prices.freezed.dart';
part 'variant_prices.g.dart';

/// O linie din raspunsul lui `POST /products/<id>/prices`: varianta, cantitatea
/// ceruta, pretul unitar **la acea cantitate** si subtotalul liniei.
///
/// De ce nu se calculeaza in aplicatie: o cantitate mai mare poate trece un prag
/// de pret al listei clientului, deci `subtotal` nu e `price` inmultit cu `qty`.
/// Un subtotal calculat local ar contrazice tacut comanda reala (CLAUDE.md:
/// aplicatia nu face niciodata aritmetica pe bani).
@freezed
abstract class VariantPriceLine with _$VariantPriceLine {
  const factory VariantPriceLine({
    @JsonKey(name: 'variant_id') required int variantId,
    @Default(0) int qty,
    required Price price,
    required Price subtotal,
  }) = _VariantPriceLine;

  factory VariantPriceLine.fromJson(Map<String, dynamic> json) =>
      _$VariantPriceLineFromJson(json);
}

/// Raspunsul complet al rutei de preturi: cate o linie per varianta ceruta si
/// totalul, toate ca siruri gata formatate de server.
@freezed
abstract class VariantPrices with _$VariantPrices {
  const factory VariantPrices({
    @Default([]) List<VariantPriceLine> lines,
    required Price total,
  }) = _VariantPrices;

  factory VariantPrices.fromJson(Map<String, dynamic> json) => _$VariantPricesFromJson(json);
}

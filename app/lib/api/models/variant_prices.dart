import 'package:freezed_annotation/freezed_annotation.dart';

import 'price.dart';

export 'price.dart';

part 'variant_prices.freezed.dart';
part 'variant_prices.g.dart';

/// O linie din raspunsul lui `POST /products/<id>/prices`: varianta, cantitatea
/// ceruta, pretul unitar si subtotalul liniei.
///
/// Pretul unitar e cel de la **cantitatea cumulata a tuturor liniilor**, nu de la
/// cantitatea acestei linii: pragurile listei de pret se aplica pe totalul din tabel,
/// exact ca pe site (4 pe o varianta si 7 pe alta inseamna 11 bucati, deci pretul de
/// la pragul de 10). De aceea o apasare pe plus pe un rand poate schimba pretul
/// tuturor randurilor — ecranul le redeseneaza pe toate din ultimul raspuns.
///
/// De ce nu se calculeaza in aplicatie: pragul face ca `subtotal` sa nu fie pretul
/// afisat inainte inmultit cu `qty`. Un subtotal calculat local ar contrazice tacut
/// comanda reala (CLAUDE.md: aplicatia nu face niciodata aritmetica pe bani).
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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_filters.freezed.dart';
part 'product_filters.g.dart';

/// O valoare dintr-un filtru pe atribut, cu numarul de produse de langa ea — exact
/// ce arata si bara de filtre a magazinului.
///
/// `count` e numarul de produse ramase daca alegi valoarea, calculat de server pe
/// restul filtrelor active. Aplicatia nu-l recalculeaza niciodata: ar fi aceeasi
/// greseala ca aritmetica pe preturi.
@freezed
abstract class AttributeFilterValue with _$AttributeFilterValue {
  const factory AttributeFilterValue({
    required int id,
    required String name,

    /// Culoarea valorii, cand atributul e de tip culoare (hexazecimal, de la server).
    String? color,
    @Default(0) int count,
    @Default(false) bool selected,
  }) = _AttributeFilterValue;

  factory AttributeFilterValue.fromJson(Map<String, dynamic> json) =>
      _$AttributeFilterValueFromJson(json);
}

/// Un atribut dupa care se poate filtra (Brand, Prescriptie, Slot...).
///
/// Lista nu e configurata nicaieri: serverul trimite doar atributele care chiar
/// exista in rezultatul curent, deci in Bracketi vin Prescriptie si Slot, iar in
/// Adezivi alte atribute. Aplicatia deseneaza ce primeste, fara sa stie dinainte ce
/// atribute exista in catalog.
@freezed
abstract class AttributeFilter with _$AttributeFilter {
  const factory AttributeFilter({
    required int id,
    required String name,

    /// Cum il deseneaza magazinul (`radio`, `select`, `color`, `pills`...). Serveste
    /// doar ca indiciu de prezentare; o valoare necunoscuta se deseneaza ca lista.
    @JsonKey(name: 'display_type') String? displayType,
    @Default([]) List<AttributeFilterValue> values,
  }) = _AttributeFilter;

  factory AttributeFilter.fromJson(Map<String, dynamic> json) => _$AttributeFilterFromJson(json);
}

/// Capetele intervalului de pret disponibil si cat e ales acum.
///
/// `min`/`max` sunt capetele rezultatului **fara** filtrul de pret aplicat, ca
/// glisorul sa poata fi largit inapoi dupa ce a fost strans.
@freezed
abstract class PriceFilter with _$PriceFilter {
  const factory PriceFilter({
    @Default(0) double min,
    @Default(0) double max,
    @JsonKey(name: 'selected_min') double? selectedMin,
    @JsonKey(name: 'selected_max') double? selectedMax,
  }) = _PriceFilter;

  factory PriceFilter.fromJson(Map<String, dynamic> json) => _$PriceFilterFromJson(json);

  const PriceFilter._();

  /// Fara capete utile nu are rost sa desenam glisorul (un singur pret in rezultat,
  /// sau niciun produs).
  bool get usable => max > min;
}

/// O optiune de sortare. Eticheta vine de la server, nu din aplicatie, ca o
/// redenumire sa nu ceara release in App Store.
@freezed
abstract class SortOption with _$SortOption {
  const factory SortOption({
    required String key,
    required String name,
    @Default(false) bool selected,
  }) = _SortOption;

  factory SortOption.fromJson(Map<String, dynamic> json) => _$SortOptionFromJson(json);
}

/// Blocul `filters` din raspunsul `/products`: vine odata cu produsele, nu dintr-un
/// apel separat, ca ecranul sa nu arate o grila fara filtre pentru o clipa.
@freezed
abstract class ProductFilters with _$ProductFilters {
  const factory ProductFilters({
    @Default([]) List<AttributeFilter> attributes,
    @Default(PriceFilter()) PriceFilter price,
    @Default([]) List<SortOption> sorts,
  }) = _ProductFilters;

  factory ProductFilters.fromJson(Map<String, dynamic> json) => _$ProductFiltersFromJson(json);
}

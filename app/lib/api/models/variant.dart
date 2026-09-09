import 'package:freezed_annotation/freezed_annotation.dart';

part 'variant.freezed.dart';
part 'variant.g.dart';

/// O valoare de atribut (ex. "Mare"). `available` vine din combinatiile posibile
/// calculate de Odoo — nu se deduce in aplicatie. Valorile indisponibile se arata
/// dezactivate, nu ascunse (spec faza 2).
@freezed
abstract class VariantValue with _$VariantValue {
  const factory VariantValue({
    required int id,
    required String name,
    @Default(false) bool selected,
    @Default(true) bool available,
  }) = _VariantValue;

  factory VariantValue.fromJson(Map<String, dynamic> json) => _$VariantValueFromJson(json);
}

/// Un atribut cu valorile lui (ex. "Marime": Mare / Mic).
@freezed
abstract class VariantAttribute with _$VariantAttribute {
  const factory VariantAttribute({
    required int id,
    required String name,
    @Default([]) List<VariantValue> values,
  }) = _VariantAttribute;

  factory VariantAttribute.fromJson(Map<String, dynamic> json) => _$VariantAttributeFromJson(json);
}

/// Sectiunea de variante a produsului. E `null` in contract cand produsul n-are
/// linii de atribut cu mai multe valori (354 din 619 produse reale) — atunci
/// selectorul nu se deseneaza deloc.
@freezed
abstract class VariantOptions with _$VariantOptions {
  const factory VariantOptions({
    @Default([]) List<VariantAttribute> attributes,
  }) = _VariantOptions;

  factory VariantOptions.fromJson(Map<String, dynamic> json) => _$VariantOptionsFromJson(json);
}

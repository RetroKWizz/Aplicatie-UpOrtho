import 'package:freezed_annotation/freezed_annotation.dart';

part 'spec.freezed.dart';
part 'spec.g.dart';

/// O linie din tabelul de specificatii: perechea nume/valoare a unei linii de
/// atribut din Odoo. Aici apare si brandul — brandul **este** un atribut, nu un
/// camp separat (`dr_brand_id` e gol pe toate produsele reale).
@freezed
abstract class ProductSpec with _$ProductSpec {
  const factory ProductSpec({
    required String name,
    required String value,
  }) = _ProductSpec;

  factory ProductSpec.fromJson(Map<String, dynamic> json) => _$ProductSpecFromJson(json);
}

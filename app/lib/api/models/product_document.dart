import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_document.freezed.dart';
part 'product_document.g.dart';

/// Un document al produsului — ce arata site-ul in tabul "Documente": fise tehnice,
/// certificate, cataloage.
///
/// `url` e ruta standard a Odoo pentru fisier (`/web/content/<id>?download=true`),
/// nu una a modulului nostru: documentul se deschide in afara aplicatiei, unde
/// cookie-ul de sesiune nu ajunge, deci daca fisierul se descarca decid regulile de
/// acces ale Odoo. `id` e id-ul fisierului, acelasi din URL.
///
/// `fileName` poate lipsi; pe documentele standard Odoo e chiar acelasi text ca
/// `name` (modelul isi mosteneste numele din atasament).
@freezed
abstract class ProductDocument with _$ProductDocument {
  const factory ProductDocument({
    required int id,
    required String name,
    @JsonKey(name: 'file_name') String? fileName,
    required String url,
  }) = _ProductDocument;

  factory ProductDocument.fromJson(Map<String, dynamic> json) => _$ProductDocumentFromJson(json);
}

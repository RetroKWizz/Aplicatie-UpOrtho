import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';
import 'product_filters.dart';

export 'product.dart';
export 'product_filters.dart';

part 'products_response.freezed.dart';
part 'products_response.g.dart';

/// Raspunsul unei pagini de `GET /products`. `total` e numarul intreg de rezultate
/// pentru filtrul curent (categorie + cautare), nu numarul incarcat pana acum —
/// controllerul de catalog il foloseste ca sa stie cand mai exista o pagina.
@freezed
abstract class ProductsResponse with _$ProductsResponse {
  const factory ProductsResponse({
    @Default([]) List<Product> products,
    required int total,
    required int offset,
    required int limit,

    /// Filtrele disponibile pentru cererea curenta. Vin odata cu produsele; sunt
    /// calculate din rezultat, deci se schimba de la o categorie la alta.
    @Default(ProductFilters()) ProductFilters filters,
  }) = _ProductsResponse;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => _$ProductsResponseFromJson(json);
}

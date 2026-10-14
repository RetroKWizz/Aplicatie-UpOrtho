import 'package:flutter/foundation.dart';

/// Ce a ales clientul in ecranul de filtre: valori de atribut, interval de pret si
/// sortare.
///
/// Valorile de atribut se tin ca jetoane `"<atribut>-<valoare>"`, acelasi format pe
/// care il foloseste si magazinul in parametrul `attribute_value`. Asa sirul de query
/// se construieste fara conversii, iar un filtru inseamna acelasi lucru in aplicatie
/// si pe site.
///
/// Clasa e imutabila si are egalitate pe valoare: controllerul o compara ca sa stie
/// daca o schimbare chiar cere o cerere noua.
@immutable
class ProductFilterSelection {
  const ProductFilterSelection({
    this.attributeTokens = const <String>{},
    this.minPrice,
    this.maxPrice,
    this.sort,
  });

  final Set<String> attributeTokens;
  final double? minPrice;
  final double? maxPrice;

  /// Cheia de sortare ceruta serverului. `null` inseamna implicitul magazinului —
  /// nu trimitem nimic si ramane ordinea configurata in Odoo.
  final String? sort;

  static const empty = ProductFilterSelection();

  bool get isEmpty =>
      attributeTokens.isEmpty && minPrice == null && maxPrice == null && sort == null;

  /// Cate filtre sunt active, pentru pastila de pe butonul de filtre. Intervalul de
  /// pret conteaza ca unul singur, oricate capete ar avea; sortarea nu se numara, are
  /// butonul ei.
  int get activeCount => attributeTokens.length + ((minPrice != null || maxPrice != null) ? 1 : 0);

  bool isSelected(int attributeId, int valueId) => attributeTokens.contains('$attributeId-$valueId');

  ProductFilterSelection toggleValue(int attributeId, int valueId) {
    final token = '$attributeId-$valueId';
    final next = Set<String>.from(attributeTokens);
    if (!next.remove(token)) next.add(token);
    return copyWith(attributeTokens: next);
  }

  /// Sterge filtrele, dar pastreaza sortarea: "Sterge filtrele" nu inseamna "pune
  /// ordinea la loc".
  ProductFilterSelection cleared() => ProductFilterSelection(sort: sort);

  ProductFilterSelection copyWith({
    Set<String>? attributeTokens,
    double? minPrice,
    double? maxPrice,
    String? sort,
    bool clearPrice = false,
  }) {
    return ProductFilterSelection(
      attributeTokens: attributeTokens ?? this.attributeTokens,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      sort: sort ?? this.sort,
    );
  }

  /// Bucatile de query, in ordine stabila: jetoanele se sorteaza, altfel doua selectii
  /// identice ar produce URL-uri diferite si ar rata cache-ul (si ar face testele sa
  /// depinda de ordinea de iterare a unui Set).
  List<String> queryParts() {
    final parts = <String>[];
    final tokens = attributeTokens.toList()..sort();
    for (final token in tokens) {
      parts.add('attribute_value=$token');
    }
    if (minPrice != null) parts.add('min_price=$minPrice');
    if (maxPrice != null) parts.add('max_price=$maxPrice');
    if (sort != null) parts.add('sort=$sort');
    return parts;
  }

  @override
  bool operator ==(Object other) =>
      other is ProductFilterSelection &&
      setEquals(other.attributeTokens, attributeTokens) &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(attributeTokens), minPrice, maxPrice, sort);

  @override
  String toString() => 'ProductFilterSelection(${queryParts().join('&')})';
}

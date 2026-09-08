import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/catalog_category.dart';
import 'package:uportho_app/api/models/products_response.dart';

List<dynamic> categoriesFixture() =>
    jsonDecode(File('test/contract/categories.json').readAsStringSync()) as List<dynamic>;

Map<String, dynamic> productsFixture() =>
    jsonDecode(File('test/contract/products.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('CatalogCategory decodes categories.json (array la nivelul radacinii)', () {
    final categories = categoriesFixture().map((e) => CatalogCategory.fromJson(e as Map<String, dynamic>)).toList();
    expect(categories, hasLength(2));

    final root = categories[0];
    expect(root.id, 12);
    expect(root.name, 'Bracketi');
    expect(root.parentId, isNull);
    expect(root.iconUrl, '/api/app/v1/categories/12/icon?unique=8be4d17');
    expect(root.productCount, 42);

    final child = categories[1];
    expect(child.parentId, 12);
    expect(child.iconUrl, isNull);
  });

  test('ProductsResponse decodes products.json cu toate campurile nullable', () {
    final response = ProductsResponse.fromJson(productsFixture());
    expect(response.total, 2);
    expect(response.offset, 0);
    expect(response.limit, 20);
    expect(response.products, hasLength(2));

    final full = response.products[0];
    expect(full.id, 101);
    expect(full.defaultCode, 'BR-ROTH-022');
    expect(full.imageUrl, '/api/app/v1/products/101/image?unique=3a1f9c2');
    expect(full.price.formatted, '148,50 lei');
    expect(full.price.listAmount, 330.00);
    expect(full.price.discountPct, 55);
    expect(full.clubPrice?.formatted, '133,65 lei');
    expect(full.clubPrice?.listAmount, isNull);
    expect(full.badge?.text, 'Nou');
    expect(full.badge?.color, ProductBadgeColor.green);

    final bare = response.products[1];
    expect(bare.defaultCode, isNull);
    expect(bare.imageUrl, isNull);
    expect(bare.price.listAmount, isNull);
    expect(bare.price.discountPct, isNull);
    expect(bare.clubPrice, isNull);
    expect(bare.badge, isNull);
  });

  test('culoare de badge necunoscuta cade pe orange, nu arunca eroare', () {
    final json = productsFixture();
    (json['products'] as List)[0]['badge']['color'] = 'magenta';
    final response = ProductsResponse.fromJson(json);
    expect(response.products[0].badge?.color, ProductBadgeColor.orange);
  });
}

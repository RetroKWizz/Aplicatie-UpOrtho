import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/product_detail.dart';

Map<String, dynamic> pricesFixture() =>
    jsonDecode(File('test/contract/product_prices.json').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> detailFixture() =>
    jsonDecode(File('test/contract/product_detail.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('VariantPrices decodeaza product_prices.json', () {
    final prices = VariantPrices.fromJson(pricesFixture());

    expect(prices.lines.length, 2);
    expect(prices.lines.first.variantId, 501);
    expect(prices.lines.first.qty, 5);
    // Pretul unitar de la 5 bucati e cel cu pragul aplicat, nu cel de la 1 bucata:
    // exact motivul pentru care exista ruta.
    expect(prices.lines.first.price.formatted, '1.120,00 lei');
    expect(prices.lines.first.subtotal.formatted, '5.600,00 lei');
    expect(prices.lines.last.qty, 0);
    expect(prices.lines.last.subtotal.formatted, '0,00 lei');
    expect(prices.total.formatted, '5.600,00 lei');
  });

  test('subtotalul si totalul sunt siruri gata formatate, nu numere de compus', () {
    final prices = VariantPrices.fromJson(pricesFixture());

    // Proba regulii din CLAUDE.md: 5 x 1.120,00 = 5.600,00 vine de la server.
    // Aplicatia nu are nicio cale sa ajunga la sirul asta singura.
    expect(prices.total.formatted, isNotEmpty);
    expect(prices.total.currency, 'RON');
  });

  test('un raspuns fara linii decodeaza cu lista goala, nu cu null', () {
    final prices = VariantPrices.fromJson({
      'lines': <dynamic>[],
      'total': (pricesFixture()['total'] as Map).cast<String, dynamic>(),
    });

    expect(prices.lines, isEmpty);
  });

  test('ProductDetail decodeaza randurile de variante din contract', () {
    final detail = ProductDetail.fromJson(detailFixture());

    expect(detail.variantRows.length, 2);
    final first = detail.variantRows.first;
    expect(first.variantId, 501);
    expect(first.attributes.single.name, 'Marime');
    expect(first.attributes.single.value, 'Mare');
    expect(first.defaultCode, 'IX954-M');
    expect(first.availability?.inStock, isTrue);
    expect(first.price.formatted, '1.120,00 lei');
    // Disponibilitatea poate lipsi (produs fara modulul de stoc) - null, nu eroare.
    expect(detail.variantRows.last.availability, isNull);
  });

  test('un produs fara randuri de variante decodeaza cu lista goala', () {
    final detail = ProductDetail.fromJson({...detailFixture()}..remove('variant_rows'));

    expect(detail.variantRows, isEmpty);
  });
}

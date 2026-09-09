import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/product/product_repository.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> detailFixture() =>
    jsonDecode(File('test/contract/product_detail.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  late FakeTransport transport;
  late ProductRepository repository;

  setUp(() {
    transport = FakeTransport();
    repository = ProductRepository(
        ApiClient(transport, InMemorySessionStore(), baseUrl: 'https://example.test'));
  });

  test('getProduct cere /products/<id> si decodeaza raspunsul', () async {
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));

    final detail = await repository.getProduct(101);

    expect(detail.id, 101);
    expect(detail.name, 'Cleste Tie Back mare (.016 - .021x.025) Ixion');
    expect(transport.calls.single.path, '/api/app/v1/products/101');
  });

  test('getProduct cu variantId trimite variant_id in query', () async {
    transport.when('GET', '/api/app/v1/products/101?variant_id=502',
        ApiResponse(status: 200, json: detailFixture()));

    await repository.getProduct(101, variantId: 502);

    expect(transport.calls.single.path, '/api/app/v1/products/101?variant_id=502');
  });

  test('getProduct cu values trimite combinatia in query', () async {
    transport.when('GET', '/api/app/v1/products/101?values=1358,2401',
        ApiResponse(status: 200, json: detailFixture()));

    await repository.getProduct(101, values: const [1358, 2401]);

    expect(transport.calls.single.path, '/api/app/v1/products/101?values=1358,2401');
  });

  test('values bate variantId - serverul rezolva singur varianta din combinatie', () async {
    transport.when('GET', '/api/app/v1/products/101?values=1358',
        ApiResponse(status: 200, json: detailFixture()));

    await repository.getProduct(101, variantId: 502, values: const [1358]);

    expect(transport.calls.single.path, '/api/app/v1/products/101?values=1358');
  });

  test('un 404 se propaga ca ApiException, nu ca eroare de decodare', () async {
    transport.when('GET', '/api/app/v1/products/999', const ApiResponse(status: 404, json: {
      'error': {'code': 'not_found', 'message': 'Produsul nu exista.', 'details': {}}
    }));

    expect(
      () => repository.getProduct(999),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 404)
          .having((e) => e.code, 'code', 'not_found')),
    );
  });
}

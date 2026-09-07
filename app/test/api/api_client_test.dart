import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';

import 'fake_transport.dart';

void main() {
  late FakeTransport transport;
  late InMemorySessionStore store;
  late ApiClient client;

  setUp(() {
    transport = FakeTransport();
    store = InMemorySessionStore();
    client = ApiClient(transport, store, baseUrl: 'https://example.test');
  });

  test('get returns json body on 200', () async {
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 200, json: {'banners': []}));
    final body = await client.get('/home');
    expect(body['banners'], isEmpty);
  });

  test('error response becomes ApiException with code and message', () async {
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 401, json: {
      'error': {'code': 'unauthorized', 'message': 'Trebuie sa te autentifici.', 'details': {}}
    }));
    expect(
      () => client.get('/home'),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 401)
          .having((e) => e.code, 'code', 'unauthorized')
          .having((e) => e.message, 'message', 'Trebuie sa te autentifici.')),
    );
  });

  test('401 clears stored session', () async {
    await store.write('abc');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 401, json: {
      'error': {'code': 'unauthorized', 'message': 'x', 'details': {}}
    }));
    await expectLater(client.get('/me'), throwsA(isA<ApiException>()));
    expect(await store.read(), isNull);
  });

  test('non-json 500 becomes internal_error', () async {
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 500, json: null));
    expect(
      () => client.get('/home'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'internal_error')),
    );
  });

  test('login stores session cookie and returns body', () async {
    transport.when('POST', '/api/app/v1/auth/login', const ApiResponse(
      status: 200,
      json: {'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}},
      sessionCookie: 'sess123',
    ));
    final body = await client.login('a@b.ro', 'pw');
    expect(body['user']['id'], 1);
    expect(await store.read(), 'sess123');
    expect(transport.calls.single.body, {'login': 'a@b.ro', 'password': 'pw'});
  });

  test('logout calls endpoint and clears session even if it fails', () async {
    await store.write('abc');
    transport.when('POST', '/api/app/v1/auth/logout', const ApiResponse(status: 500, json: null));
    await client.logout();
    expect(await store.read(), isNull);
  });

  test('hasSession reflects store', () async {
    expect(await client.hasSession(), isFalse);
    await store.write('abc');
    expect(await client.hasSession(), isTrue);
  });

  test('absoluteUrl joins base and relative path', () {
    expect(client.absoluteUrl('/api/app/v1/banners/1/image'), 'https://example.test/api/app/v1/banners/1/image');
  });
}

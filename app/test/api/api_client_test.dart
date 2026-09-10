import 'dart:io';

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

  test('logout calls endpoint and clears session even on a non-2xx status', () async {
    await store.write('abc');
    transport.when('POST', '/api/app/v1/auth/logout', const ApiResponse(status: 500, json: null));
    await client.logout();
    expect(await store.read(), isNull);
  });

  test('logout clears session even when the transport call throws', () async {
    await store.write('abc');
    transport.whenThrows('POST', '/api/app/v1/auth/logout', const ApiException(
      status: 0,
      code: 'network_error',
      message: 'Nu s-a putut contacta serverul. Verifica conexiunea.',
    ));
    await client.logout();
    expect(await store.read(), isNull);
  });

  test('network failure from transport surfaces as ApiException(network_error)', () async {
    transport.whenThrows('GET', '/api/app/v1/home', const ApiException(
      status: 0,
      code: 'network_error',
      message: 'Nu s-a putut contacta serverul. Verifica conexiunea.',
    ));
    expect(
      () => client.get('/home'),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 0)
          .having((e) => e.code, 'code', 'network_error')),
    );
  });

  test('hasSession reflects store', () async {
    expect(await client.hasSession(), isFalse);
    await store.write('abc');
    expect(await client.hasSession(), isTrue);
  });

  test('absoluteUrl joins base and relative path', () {
    expect(client.absoluteUrl('/api/app/v1/banners/1/image'), 'https://example.test/api/app/v1/banners/1/image');
  });

  group('downloadTo', () {
    const url = 'https://example.test/api/app/v1/products/101/documents/4821';

    test('cere transportului exact URL-ul si fisierul primite', () async {
      transport.whenDownload(url, bytes: const [37, 80, 68, 70]);

      final file = File('${Directory.systemTemp.path}/uportho-test-${DateTime.now().microsecondsSinceEpoch}.pdf');
      addTearDown(() => file.existsSync() ? file.deleteSync() : null);
      await client.downloadTo(url, file.path);

      expect(transport.downloads.single.url, url);
      expect(transport.downloads.single.savePath, file.path);
      // Documentul e pe disc, nu in memoria clientului: downloadTo nu intoarce octeti.
      expect(file.readAsBytesSync(), [37, 80, 68, 70]);
    });

    test('un 401 sterge sesiunea si anunta expirarea, ca orice alta cerere', () async {
      await store.write('abc');
      var expired = false;
      final watched = ApiClient(transport, store,
          baseUrl: 'https://example.test', onUnauthorized: () => expired = true);
      transport.whenDownload(url,
          response: const ApiResponse(status: 401, json: {
            'error': {'code': 'unauthorized', 'message': 'Trebuie sa te autentifici.', 'details': {}}
          }));

      await expectLater(watched.downloadTo(url, '/nu/conteaza'), throwsA(isA<ApiException>()));
      expect(await store.read(), isNull);
      expect(expired, isTrue);
    });

    test('un cod de eroare devine ApiException cu mesajul serverului', () async {
      transport.whenDownload(url,
          response: const ApiResponse(status: 404, json: {
            'error': {'code': 'not_found', 'message': 'Documentul nu exista.', 'details': {}}
          }));

      await expectLater(
        client.downloadTo(url, '/nu/conteaza'),
        throwsA(isA<ApiException>()
            .having((e) => e.status, 'status', 404)
            .having((e) => e.message, 'message', 'Documentul nu exista.')),
      );
    });
  });
}

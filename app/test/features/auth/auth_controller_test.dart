import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

const userJson = {'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}};

void main() {
  late FakeTransport transport;
  late InMemorySessionStore store;
  late ProviderContainer container;

  setUp(() {
    transport = FakeTransport();
    store = InMemorySessionStore();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  test('without stored session starts signedOut', () async {
    final state = await container.read(authControllerProvider.future);
    expect(state, const AuthState.signedOut());
  });

  test('with stored session restores profile via /me', () async {
    await store.write('sess');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: userJson));
    final state = await container.read(authControllerProvider.future);
    expect(state, isA<SignedIn>().having((s) => s.user.email, 'email', 'a@b.ro'));
  });

  test('with expired session (/me 401) starts signedOut', () async {
    await store.write('sess');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 401, json: {
      'error': {'code': 'unauthorized', 'message': 'x', 'details': {}}
    }));
    final state = await container.read(authControllerProvider.future);
    expect(state, const AuthState.signedOut());
  });

  test('login success moves to signedIn', () async {
    await container.read(authControllerProvider.future);
    transport.when('POST', '/api/app/v1/auth/login', const ApiResponse(status: 200, json: userJson, sessionCookie: 's'));
    await container.read(authControllerProvider.notifier).login('a@b.ro', 'pw');
    expect(container.read(authControllerProvider).value, isA<SignedIn>());
  });

  test('login failure exposes error and stays signedOut', () async {
    await container.read(authControllerProvider.future);
    transport.when('POST', '/api/app/v1/auth/login', const ApiResponse(status: 401, json: {
      'error': {'code': 'invalid_credentials', 'message': 'Email sau parola gresite.', 'details': {}}
    }));
    await container.read(authControllerProvider.notifier).login('a@b.ro', 'bad');
    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(container.read(authControllerProvider.notifier).lastErrorMessage, 'Email sau parola gresite.');
  });

  test('non-401 error on /me surfaces imediat, fara reincercare automata', () async {
    await store.write('sess');
    transport.whenThrows('GET', '/api/app/v1/me',
        const ApiException(status: 0, code: 'network_error', message: 'Fara conexiune.'));
    // Riverpod 3 reincearca implicit erorile din build() cu backoff pana la ~38s;
    // daca authControllerProvider nu ar seta retry: null, acest expectLater ar
    // depasi timeout-ul default de test (30s) in loc sa arunce prompt.
    await expectLater(container.read(authControllerProvider.future), throwsA(isA<ApiException>()));
  });

  // Aceste teste NU inlocuiesc apiClientProvider: inlocuiesc doar reteaua
  // (apiTransportProvider) si stocarea sesiunii, ca sa exercite exact cablajul de
  // productie din providers.dart, inclusiv legatura ApiClient.onUnauthorized ->
  // AuthController.onSessionExpired.
  group('sesiune expirata in timpul folosirii aplicatiei (cablaj real)', () {
    late ProviderContainer real;

    setUp(() {
      real = ProviderContainer(overrides: [
        sessionStoreProvider.overrideWithValue(store),
        apiTransportProvider.overrideWithValue(transport),
      ]);
    });

    tearDown(() => real.dispose());

    test('un 401 aparut in timpul sesiunii trece aplicatia in signedOut', () async {
      await store.write('sess');
      transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: userJson));
      expect(await real.read(authControllerProvider.future), isA<SignedIn>());

      // Sesiunea de pe server expira cat timp aplicatia e deschisa.
      transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 401, json: {
        'error': {'code': 'unauthorized', 'message': 'Trebuie sa te autentifici.', 'details': {}}
      }));
      await expectLater(real.read(apiClientProvider).get('/home'), throwsA(isA<ApiException>()));

      expect(real.read(authControllerProvider).value, const AuthState.signedOut());
      expect(await store.read(), isNull);
    });

    test('un 401 la login NU e tratat ca expirare de sesiune', () async {
      await real.read(authControllerProvider.future);
      transport.when('POST', '/api/app/v1/auth/login', const ApiResponse(status: 401, json: {
        'error': {'code': 'invalid_credentials', 'message': 'Email sau parola gresite.', 'details': {}}
      }));
      await real.read(authControllerProvider.notifier).login('a@b.ro', 'bad');

      // Ramane esecul asteptat, cu mesajul lui - nu o tranzitie tacuta de sesiune expirata.
      expect(real.read(authControllerProvider).hasError, isTrue);
      expect(real.read(authControllerProvider.notifier).lastErrorMessage, 'Email sau parola gresite.');
    });

    test('un 401 pe /me la pornire nu scrie state in timpul build()-ului', () async {
      await store.write('sess');
      transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 401, json: {
        'error': {'code': 'unauthorized', 'message': 'x', 'details': {}}
      }));
      expect(await real.read(authControllerProvider.future), const AuthState.signedOut());
    });
  });

  test('logout moves to signedOut and clears session', () async {
    await store.write('sess');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: userJson));
    await container.read(authControllerProvider.future);
    transport.when('POST', '/api/app/v1/auth/logout', const ApiResponse(status: 204));
    await container.read(authControllerProvider.notifier).logout();
    expect(container.read(authControllerProvider).value, const AuthState.signedOut());
    expect(await store.read(), isNull);
  });
}

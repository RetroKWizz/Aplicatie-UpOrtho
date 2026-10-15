import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> signupFixture() =>
    jsonDecode(File('test/contract/signup.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  ProviderContainer containerFor(FakeTransport transport) {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('un cont nou lasa omul inauntru fara al doilea pas', () async {
    // Serverul deschide sesiunea in acelasi raspuns; aplicatia nu mai face login.
    final transport = FakeTransport();
    transport.when('POST', '/api/app/v1/auth/signup',
        ApiResponse(status: 200, json: signupFixture()));
    final container = containerFor(transport);

    await container.read(authControllerProvider.notifier).signUp(
        name: 'Cabinet Test', login: 'cabinet@exemplu.ro',
        password: 'Parola123!', confirmPassword: 'Parola123!');

    expect(container.read(authControllerProvider).value, isA<SignedIn>());
    expect(transport.calls.where((c) => c.path.endsWith('/auth/login')), isEmpty,
        reason: 'inregistrarea deschide ea sesiunea');
  });

  test('inregistrarea trimite exact cele patru campuri ale formularului lor', () async {
    final transport = FakeTransport();
    transport.when('POST', '/api/app/v1/auth/signup',
        ApiResponse(status: 200, json: signupFixture()));
    final container = containerFor(transport);

    await container.read(authControllerProvider.notifier).signUp(
        name: '  Cabinet Test  ', login: '  cabinet@exemplu.ro ',
        password: 'Parola123!', confirmPassword: 'Parola123!');

    final body = transport.calls.last.body!;
    expect(body.keys.toSet(), {'login', 'name', 'password', 'confirm_password'});
    // Spatiile din jur nu ajung la server: un email copiat cu spatiu nu e alt email.
    expect(body['login'], 'cabinet@exemplu.ro');
    expect(body['name'], 'Cabinet Test');
  });

  test('un email cu cont existent lasa mesajul serverului si codul lui', () async {
    final transport = FakeTransport();
    transport.when('POST', '/api/app/v1/auth/signup', const ApiResponse(status: 409, json: {
      'error': {'code': 'email_taken', 'message': 'Exista deja un cont cu acest email.'}
    }));
    final container = containerFor(transport);

    await container.read(authControllerProvider.notifier).signUp(
        name: 'Cabinet', login: 'cabinet@exemplu.ro',
        password: 'Parola123!', confirmPassword: 'Parola123!');

    final auth = container.read(authControllerProvider);
    expect(auth.hasError, isTrue);
    expect((auth.error as ApiException).code, 'email_taken');
    expect(container.read(authControllerProvider.notifier).lastErrorMessage,
        'Exista deja un cont cu acest email.');
  });

  test('cand magazinul cere reCAPTCHA, codul ajunge la ecran', () async {
    // Ecranul deschide atunci pagina de inregistrare a magazinului, unde protectia
    // lor functioneaza; aplicatia nu o ocoleste.
    final transport = FakeTransport();
    transport.when('POST', '/api/app/v1/auth/signup', const ApiResponse(status: 409, json: {
      'error': {'code': 'signup_needs_webview', 'message': 'Inregistrarea se face in pagina magazinului.'}
    }));
    final container = containerFor(transport);

    await container.read(authControllerProvider.notifier).signUp(
        name: 'Cabinet', login: 'cabinet@exemplu.ro',
        password: 'Parola123!', confirmPassword: 'Parola123!');

    expect((container.read(authControllerProvider).error as ApiException).code,
        'signup_needs_webview');
  });
}

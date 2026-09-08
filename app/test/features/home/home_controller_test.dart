import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/banner.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/features/home/home_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  Map<String, dynamic> homeFixture() =>
      jsonDecode(File('test/contract/home.json').readAsStringSync()) as Map<String, dynamic>;

  setUp(() {
    transport = FakeTransport();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  test('loads home from /home and splits hero vs promo', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));
    final home = await container.read(homeControllerProvider.future);
    expect(home.banners.where((b) => b.placement == BannerPlacement.hero), hasLength(1));
    expect(home.banners.where((b) => b.placement == BannerPlacement.promo), hasLength(1));
    expect(home.quickCategories, hasLength(2));
  });

  test('api error surfaces as AsyncError with ApiException', () async {
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 500, json: null));
    await expectLater(container.read(homeControllerProvider.future), throwsA(isA<ApiException>()));
  });

  test('refresh refetches', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));
    await container.read(homeControllerProvider.future);
    await container.read(homeControllerProvider.notifier).refresh();
    expect(transport.calls.where((c) => c.path == '/api/app/v1/home'), hasLength(2));
  });

  Map<String, dynamic> loginBody({required int id, required String name}) => {
        'user': {'id': id, 'name': name, 'email': '$name@test.ro', 'partner_id': id * 10},
      };

  test('un fetch /home esuat inainte de sign-in se reincearca automat dupa autentificare', () async {
    // Simuleaza exact defectul: /home pleaca inainte ca sesiunea sa fie gata (401),
    // iar controllerul ramane in AsyncError pana la un semnal extern.
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 401, json: null));
    await expectLater(container.read(homeControllerProvider.future), throwsA(isA<ApiException>()));

    // Autentificarea reuseste; home trebuie sa se reincarce singur, fara apel manual la refresh().
    transport.when(
      'POST',
      '/api/app/v1/auth/login',
      ApiResponse(status: 200, json: loginBody(id: 1, name: 'Ana'), sessionCookie: 'sess-ana'),
    );
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));

    await container.read(authControllerProvider.notifier).login('ana', 'parola');

    final home = await container.read(homeControllerProvider.future);
    expect(home.quickCategories, hasLength(2));

    // Cererea reusita catre /home a avut loc dupa login-ul reusit, nu doar din cache-ul vechi.
    final loginCallIndex = transport.calls.indexWhere((c) => c.path == '/api/app/v1/auth/login');
    final lastHomeCallIndex = transport.calls.lastIndexWhere((c) => c.path == '/api/app/v1/home');
    expect(loginCallIndex, greaterThanOrEqualTo(0));
    expect(lastHomeCallIndex, greaterThan(loginCallIndex));
  });

  test('datele home nu supravietuiesc unei schimbari de utilizator (fara scurgere intre conturi)', () async {
    transport.when(
      'POST',
      '/api/app/v1/auth/login',
      ApiResponse(status: 200, json: loginBody(id: 1, name: 'Ana'), sessionCookie: 'sess-ana'),
    );
    final fixtureUser1 = homeFixture();
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: fixtureUser1));

    await container.read(authControllerProvider.notifier).login('ana', 'parola');
    final home1 = await container.read(homeControllerProvider.future);
    expect(home1.banners.first.title, 'Alatura-te Ortho Club');

    // Ana se delogheaza; fara sesiune valida, /home ar trebui sa refuze (401) - controllerul
    // nu are voie sa ramana blocat pe datele Anei.
    transport.when('POST', '/api/app/v1/auth/logout', const ApiResponse(status: 200, json: {}));
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 401, json: null));
    await container.read(authControllerProvider.notifier).logout();

    // Fortam asezarea stării invalidate: fara sesiune, noul fetch /home pica cu 401 -
    // ecranul (`home.when`) ar arata eroarea, niciodata datele Anei ramase in cache.
    try {
      await container.read(homeControllerProvider.future);
    } catch (_) {
      // asteptat: fara sesiune valida, /home raspunde 401
    }
    final afterLogout = container.read(homeControllerProvider);
    expect(afterLogout.hasError, isTrue, reason: 'dupa logout, home nu ar trebui sa mai arate datele Anei');

    // Bogdan se autentifica pe acelasi telefon, cu alt continut /home.
    final fixtureUser2 = jsonDecode(jsonEncode(fixtureUser1)) as Map<String, dynamic>;
    (fixtureUser2['banners'] as List)[0]['title'] = 'Reducere Bogdan -20%';
    transport.when(
      'POST',
      '/api/app/v1/auth/login',
      ApiResponse(status: 200, json: loginBody(id: 2, name: 'Bogdan'), sessionCookie: 'sess-bogdan'),
    );
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: fixtureUser2));

    await container.read(authControllerProvider.notifier).login('bogdan', 'parola');
    final home2 = await container.read(homeControllerProvider.future);
    expect(home2.banners.first.title, 'Reducere Bogdan -20%');
  });
}

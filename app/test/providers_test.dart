import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/same_origin.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/providers.dart';

import 'api/fake_transport.dart';

void main() {
  test('imageHeadersProvider builds Cookie header from session id', () async {
    final store = InMemorySessionStore();
    await store.write('abc123');
    final transport = FakeTransport();
    // imageHeadersProvider asteapta acum restaurarea autentificarii (FINDING 1);
    // cu o sesiune deja stocata, restore() cere /me - il stubuim ca sa nu iasa
    // niciun apel de retea real din test.
    transport.when(
      'GET',
      '/api/app/v1/me',
      const ApiResponse(
        status: 200,
        json: {
          'user': {'id': 1, 'name': 'Ana', 'email': 'ana@test.ro', 'partner_id': 10},
        },
      ),
    );
    final container = ProviderContainer(overrides: [
      sessionStoreProvider.overrideWithValue(store),
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);

    final headers = await container.read(imageHeadersProvider.future);
    expect(headers, {'Cookie': 'session_id=abc123'});
  });

  test('imageHeadersProvider returns empty map when no session yet', () async {
    final container = ProviderContainer(overrides: [
      sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
    ]);
    addTearDown(container.dispose);

    final headers = await container.read(imageHeadersProvider.future);
    expect(headers, isEmpty);
  });

  // FINDING 1: fara `await ref.watch(authControllerProvider.future)` in build(),
  // imageHeadersProvider s-ar cache-ui pentru totdeauna cu prima valoare citita
  // (goala, cat timp sesiunea inca nu s-a restaurat) si nu s-ar mai actualiza
  // niciodata dupa un login reusit in acelasi container (= aceeasi rulare a app-ului).
  test('imageHeadersProvider recomputes dupa o tranzitie de autentificare, fara sa recream containerul', () async {
    final store = InMemorySessionStore();
    final transport = FakeTransport();
    final container = ProviderContainer(overrides: [
      sessionStoreProvider.overrideWithValue(store),
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);

    // Restaurarea sesiunii (fara sesiune stocata pe disc) se termina cu "signedOut",
    // deci prima citire a headerelor de imagine e goala.
    final before = await container.read(imageHeadersProvider.future);
    expect(before, isEmpty);

    transport.when(
      'POST',
      '/api/app/v1/auth/login',
      const ApiResponse(
        status: 200,
        json: {
          'user': {'id': 1, 'name': 'Ana', 'email': 'ana@test.ro', 'partner_id': 10},
        },
        sessionCookie: 'sess-ana',
      ),
    );
    await container.read(authControllerProvider.notifier).login('ana', 'parola');

    // Fara alta recreere de container: aceeasi rulare a aplicatiei, doar autentificarea
    // s-a schimbat - headerele de imagine trebuie sa reflecte noua sesiune.
    final after = await container.read(imageHeadersProvider.future);
    expect(after, {'Cookie': 'session_id=sess-ana'});
  });

  // FINDING 2: cookie-ul de sesiune Odoo nu trebuie trimis catre o origine straina,
  // chiar daca URL-ul e "absolut" (ramul pass-through din ApiClient.absoluteUrl).
  group('isSameOrigin / imageHeadersFor', () {
    const apiBaseUrl = 'http://localhost:8069';
    const headers = {'Cookie': 'session_id=abc'};

    test('acelasi schema+host+port -> aceeasi origine', () {
      expect(isSameOrigin('http://localhost:8069/web/image/123', apiBaseUrl), isTrue);
    });

    test('host diferit -> origine diferita, chiar daca prefixul stringului coincide', () {
      // Un url care "incepe la fel" cu apiBaseUrl ca text, dar tinteste alt host -
      // exact cazul pe care o comparatie `startsWith` l-ar rata.
      expect(isSameOrigin('http://localhost.8069.evil.example/img.png', apiBaseUrl), isFalse);
    });

    test('port diferit -> origine diferita', () {
      expect(isSameOrigin('http://localhost:9999/img.png', apiBaseUrl), isFalse);
    });

    test('url invalid -> tratat ca origine diferita, nu ca eroare', () {
      expect(isSameOrigin('not a url', apiBaseUrl), isFalse);
    });

    test('imageHeadersFor ataseaza headerele doar pentru URL de pe originea API-ului', () {
      expect(
        imageHeadersFor('http://localhost:8069/web/image/123', apiBaseUrl: apiBaseUrl, headers: headers),
        headers,
      );
    });

    test('imageHeadersFor NU ataseaza headerele pentru un URL absolut de pe alta origine', () {
      expect(
        imageHeadersFor('https://cdn.extern.example/img.png', apiBaseUrl: apiBaseUrl, headers: headers),
        isNull,
      );
    });

    test('imageHeadersFor returneaza null cand nu exista inca headere de atasat', () {
      expect(
        imageHeadersFor('http://localhost:8069/web/image/123', apiBaseUrl: apiBaseUrl, headers: null),
        isNull,
      );
    });
  });
}

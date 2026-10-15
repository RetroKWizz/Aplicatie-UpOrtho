import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/providers.dart';
import 'package:uportho_app/router.dart';

import 'api/fake_transport.dart';

// Nota de adaptare la go_router 18: `GoRouter.go()` doar actualizeaza
// RouteInformationProvider si notifica listenerii; potrivirea rutei si
// redirectul ruleaza abia cand un widget `Router` (aici din MaterialApp.router)
// asculta acel provider si re-parseaza. In brief testele erau simple `test()`
// fara niciun widget pompat, iar `router.go(...)` nu producea nicio schimbare
// in `currentConfiguration` (ramanea calea goala ''). Adaptarea: teste
// `testWidgets` care pompeaza efectiv `MaterialApp.router(routerConfig: router)`
// intr-un `UncontrolledProviderScope` peste acelasi container, si folosesc
// `pump()` cu durate fixe (nu `pumpAndSettle()`, care ar bloca la spinner-ul
// indeterminat din HomeScreen cat timp asteapta /home).
void main() {
  testWidgets('fara sesiune, aplicatia ramane in magazin', (tester) async {
    // Apple respinge aplicatiile care nu arata nimic pana la autentificare, iar
    // magazinul oricum isi arata catalogul oricui. Acasa ramane Acasa.
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: router)),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    router.go('/');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });

  testWidgets('fara sesiune, cosul si contul cer autentificare', (tester) async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: router)),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    // Rutele reale de cont. Adresele, favoritele si datele contului nu sunt rute: se
    // deschid cu `Navigator.push` din ecranul de cont al unui client.
    for (final path in ['/cart', '/checkout', '/account/orders', '/account/invoices']) {
      router.go(path);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login',
          reason: '$path trebuie sa ceara cont');
    }
  });

  testWidgets('vechiul redirect global nu mai trimite Acasa la /login', (tester) async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: router)),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    router.go('/catalog');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(router.routerDelegate.currentConfiguration.uri.path, '/catalog');
  });

  testWidgets('signed in user on /login is redirected to /', (tester) async {
    final transport = FakeTransport();
    final store = InMemorySessionStore();
    await store.write('s');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: {
      'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}
    }));
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 200, json: {'banners': [], 'quick_categories': []}));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: router)),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    router.go('/login');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });

  testWidgets('tabul Cont ramane deschis unui vizitator', (tester) async {
    // Ecranul de cont are o fata de vizitator (invitatia cu cele doua drumuri). Pazit
    // de router, acea fata n-ar fi vazuta niciodata: omul ar cadea direct in formularul
    // de autentificare, fara sa afle ca isi poate face cont.
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: router)),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    router.go('/account');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(router.routerDelegate.currentConfiguration.uri.path, '/account');
  });
}

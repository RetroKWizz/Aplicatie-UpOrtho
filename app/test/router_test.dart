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
  testWidgets('signed out user is redirected to /login', (tester) async {
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
    router.go('/');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
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
}

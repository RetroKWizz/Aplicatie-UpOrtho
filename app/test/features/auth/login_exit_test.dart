import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/providers.dart';
import 'package:uportho_app/router.dart';

import '../../api/fake_transport.dart';

void main() {
  testWidgets('de pe autentificare se poate intoarce in magazin', (tester) async {
    // Intrarile folosesc `go`, care inlocuieste stiva: fara un drum inapoi scris de
    // noi, cine apasa "Intra" din banda ramane blocat pe ecranul de autentificare
    // (iOS n-are back de sistem). Primul care ar fi patit-o: recenzorul Apple.
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: MaterialApp.router(routerConfig: router)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    router.go('/login');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.tap(find.byTooltip('Inapoi in magazin'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });

  testWidgets('de pe autentificare se ajunge la crearea unui cont', (tester) async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: MaterialApp.router(routerConfig: router)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    router.go('/login');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.tap(find.text('Nu am cont — creeaza unul'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(router.routerDelegate.currentConfiguration.uri.path, '/signup');
  });
}

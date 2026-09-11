import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/favorites_screen.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/features/favorites/favorites_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> productJson(int id, String name) => {
      'id': id,
      'name': name,
      'default_code': null,
      'image_url': null,
      'price': {
        'amount': 30.0,
        'currency': 'RON',
        'formatted': '30,00 lei',
        'with_vat': true,
        'list_amount': null,
        'discount_pct': null,
      },
      'club_price': null,
      'badge': null,
      'rating': null,
    };

void main() {
  FakeTransport transportWith(List<int> ids) {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/favorites',
      ApiResponse(status: 200, json: {
        'products': [for (final id in ids) productJson(id, 'Produs $id')],
        'ids': ids,
      }),
    );
    return transport;
  }

  /// Favoritele sunt date ale contului, deci controllerul asteapta autentificarea -
  /// testul chiar se logheaza, ca sa exerseze acelasi drum ca aplicatia.
  Future<ProviderContainer> signedInContainer(FakeTransport transport) async {
    final store = InMemorySessionStore();
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
    final container = ProviderContainer(overrides: [
      sessionStoreProvider.overrideWithValue(store),
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).login('ana', 'parola');
    return container;
  }

  test('a pune si a scoate de la favorite trece prin server, nu prin ecran', () async {
    final transport = transportWith([]);
    transport.when(
      'POST',
      '/api/app/v1/favorites',
      ApiResponse(status: 200, json: {
        'favorite': true,
        'products': [productJson(7, 'Produs 7')],
        'ids': const [7],
      }),
    );
    transport.when(
      'DELETE',
      '/api/app/v1/favorites/7',
      const ApiResponse(status: 200, json: {'favorite': false, 'products': [], 'ids': []}),
    );
    final container = await signedInContainer(transport);
    await container.read(favoritesControllerProvider.future);

    final controller = container.read(favoritesControllerProvider.notifier);
    await controller.toggle(7);
    expect(controller.isFavorite(7), isTrue);
    expect(transport.calls.last.method, 'POST');
    // Raspunsul aduce lista intreaga, deci ecranul de favorite o are imediat: fara
    // asta, lista aparea goala fix dupa ce apasai inimioara.
    expect(container.read(favoritesControllerProvider).value!.products, hasLength(1));

    await controller.toggle(7);
    expect(controller.isFavorite(7), isFalse);
    expect(transport.calls.last.method, 'DELETE');
    expect(transport.calls.last.path, '/api/app/v1/favorites/7');
  });

  testWidgets('ecranul gol spune ce trebuie facut, nu arata o eroare', (tester) async {
    final container = await signedInContainer(transportWith([]));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: FavoritesScreen()),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.textContaining('Nu ai produse favorite'), findsOneWidget);
  });

  testWidgets('produsele favorite apar cu pretul contului', (tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = await signedInContainer(transportWith([7]));
    await container.read(favoritesControllerProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: FavoritesScreen()),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('Produs 7'), findsOneWidget);
    expect(find.text('30,00 lei'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/catalog/catalog_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

// Smoke test de cablare: verifica ca ecranul chiar porneste fetch-ul la montare
// (prin `ensureLoaded`, apelat din `initState` via un microtask), afiseaza
// rezultatul in grila si categoria initiala e trimisa mai departe controllerului -
// nu doar ca fiecare bucata compileaza izolat. Fara `pumpAndSettle` (grila are un
// `CircularProgressIndicator` indeterminat cat timp incarca, ca in HomeScreen -
// vezi nota din router_test.dart).
void main() {
  Future<ProviderContainer> pumpCatalog(
    WidgetTester tester, {
    int? initialCategoryId,
    required FakeTransport transport,
  }) async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: CatalogScreen(initialCategoryId: initialCategoryId)),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    return container;
  }

  Map<String, dynamic> productJson(int id, String name) => {
        'id': id,
        'name': name,
        'default_code': null,
        'image_url': null,
        'price': {
          'amount': 10.0,
          'currency': 'RON',
          'formatted': '10,00 lei',
          'with_vat': true,
          'list_amount': null,
          'discount_pct': null,
        },
        'club_price': null,
        'badge': null,
      };

  testWidgets('la montare, incarca categoriile si prima pagina de produse si le afiseaza', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/categories', const ApiResponse(status: 200, json: [
      {'id': 12, 'name': 'Bracketi', 'parent_id': null, 'icon_url': null, 'product_count': 42},
    ]));
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20', ApiResponse(status: 200, json: {
      'products': [productJson(1, 'Bracket metalic Roth .022')],
      'total': 1,
      'offset': 0,
      'limit': 20,
    }));

    await pumpCatalog(tester, transport: transport);

    expect(find.text('Bracket metalic Roth .022'), findsOneWidget);
    expect(find.text('10,00 lei'), findsOneWidget);
    expect(find.text('Toate'), findsOneWidget);
    expect(find.text('Bracketi (42)'), findsOneWidget);
  });

  testWidgets('arrives cu o categorie initiala trimite category_id pe cererea de produse', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/categories', const ApiResponse(status: 200, json: []));
    transport.when('GET', '/api/app/v1/products?category_id=12&offset=0&limit=20', ApiResponse(status: 200, json: {
      'products': [productJson(9, 'Produs din categoria 12')],
      'total': 1,
      'offset': 0,
      'limit': 20,
    }));

    await pumpCatalog(tester, initialCategoryId: 12, transport: transport);

    expect(find.text('Produs din categoria 12'), findsOneWidget);
  });

  testWidgets('eroarea serverului arata mesajul si un buton de reincercare', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/categories', const ApiResponse(status: 200, json: []));
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20', const ApiResponse(status: 500, json: {
      'error': {'code': 'internal_error', 'message': 'Serverul nu raspunde. Incearca din nou.', 'details': {}}
    }));

    await pumpCatalog(tester, transport: transport);

    expect(find.text('Serverul nu raspunde. Incearca din nou.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Reincearca'), findsOneWidget);
  });

  testWidgets('lista goala arata un mesaj, nu ecranul de eroare', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/categories', const ApiResponse(status: 200, json: []));
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20', const ApiResponse(status: 200, json: {
      'products': [],
      'total': 0,
      'offset': 0,
      'limit': 20,
    }));

    await pumpCatalog(tester, transport: transport);

    expect(find.textContaining('Niciun produs gasit'), findsOneWidget);
  });
}

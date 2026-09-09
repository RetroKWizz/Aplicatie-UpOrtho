import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/design_system/widgets/product_card.dart';
import 'package:uportho_app/providers.dart';
import 'package:uportho_app/router.dart';

import '../../api/fake_transport.dart';

/// Navigarea catre pagina de produs, pe routerul real: din grila de catalog si
/// dintr-un produs similar. Cablajul asta n-are cum sa fie prins de testele de
/// ecran (care pompeaza ecranul singur, fara GoRouter).
Map<String, dynamic> detailJson(int id, String name, {List<Map<String, dynamic>> similar = const []}) {
  final fixture =
      jsonDecode(File('test/contract/product_detail.json').readAsStringSync()) as Map<String, dynamic>;
  return {...fixture, 'id': id, 'name': name, 'similar': similar};
}

Map<String, dynamic> catalogProductJson(int id, String name) => {
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
        'list_formatted': null,
        'discount_pct': null,
      },
      'club_price': null,
      'badge': null,
    };

void main() {
  Future<(GoRouter, FakeTransport)> pumpApp(WidgetTester tester) async {
    // Ecran inalt: produsele similare stau in josul paginii de produs, iar un
    // ListView lenes nici nu le-ar construi pe 600x800.
    tester.view.physicalSize = const Size(500, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final transport = FakeTransport();
    final store = InMemorySessionStore();
    await store.write('s');
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: {
      'user': {'id': 1, 'name': 'A', 'email': 'a@b.ro', 'partner_id': 2}
    }));
    transport.when('GET', '/api/app/v1/home',
        const ApiResponse(status: 200, json: {'banners': [], 'quick_categories': []}));
    transport.when('GET', '/api/app/v1/categories', const ApiResponse(status: 200, json: []));
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20', ApiResponse(status: 200, json: {
      'products': [catalogProductJson(101, 'Cleste din grila')],
      'total': 1,
      'offset': 0,
      'limit': 20,
    }));
    transport.when(
      'GET',
      '/api/app/v1/products/101',
      ApiResponse(
        status: 200,
        json: detailJson(101, 'Cleste Tie Back mare',
            similar: [catalogProductJson(102, 'Cleste Tie Back mic')]),
      ),
    );
    transport.when('GET', '/api/app/v1/products/102',
        ApiResponse(status: 200, json: detailJson(102, 'Cleste Tie Back mic')));

    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, store, baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: router)),
    );
    // Fara pumpAndSettle: ecranele au spinnere indeterminate cat timp incarca.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    return (router, transport);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('/catalog/<id> deschide pagina produsului', (tester) async {
    final (router, _) = await pumpApp(tester);

    router.go('/catalog/101');
    await settle(tester);

    expect(router.routerDelegate.currentConfiguration.uri.path, '/catalog/101');
    expect(find.text('Cleste Tie Back mare'), findsOneWidget);
  });

  // Nota de comportament go_router 18: un `push` imperativ dintr-o ramura de
  // `StatefulShellRoute` schimba ecranul, dar NU actualizeaza
  // `currentConfiguration` (ramane pe locatia ultimului `go`). De aceea testele de
  // apasare verifica ce e pe ecran si ce s-a cerut de la server, nu URI-ul - iar
  // verificarea e oricum mai apropiata de ce vede utilizatorul.
  testWidgets('apasarea pe un produs din grila deschide detaliul lui', (tester) async {
    final (router, transport) = await pumpApp(tester);

    router.go('/catalog');
    await settle(tester);
    expect(find.text('Cleste din grila'), findsOneWidget);

    await tester.tap(find.byType(ProductCard));
    await settle(tester);

    expect(transport.calls.map((call) => call.path), contains('/api/app/v1/products/101'));
    expect(find.text('Cleste Tie Back mare'), findsOneWidget);
    expect(find.text('Cleste din grila'), findsNothing, reason: 'grila a ramas sub pagina de produs');
  });

  testWidgets('apasarea pe un produs similar deschide detaliul acelui produs', (tester) async {
    final (router, transport) = await pumpApp(tester);

    router.go('/catalog/101');
    await settle(tester);

    await tester.tap(find.widgetWithText(ProductCard, 'Cleste Tie Back mic'));
    await settle(tester);

    expect(transport.calls.map((call) => call.path), contains('/api/app/v1/products/102'));
    // Titlul noii pagini, nu cardul de pe cea veche (pagina precedenta a iesit
    // din arbore, fiind acoperita complet).
    expect(find.text('Cleste Tie Back mare'), findsNothing);
    expect(find.text('Cleste Tie Back mic'), findsOneWidget);
  });

  testWidgets('un id de produs nenumeric duce inapoi la catalog, nu la o exceptie',
      (tester) async {
    final (router, _) = await pumpApp(tester);

    router.go('/catalog/abc');
    await settle(tester);

    expect(router.routerDelegate.currentConfiguration.uri.path, '/catalog');
    expect(tester.takeException(), isNull);
  });
}

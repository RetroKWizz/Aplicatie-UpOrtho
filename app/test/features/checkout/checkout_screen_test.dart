import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/checkout/checkout_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> checkoutFixture() =>
    jsonDecode(File('test/contract/checkout.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  /// Ecranul de checkout e mai inalt decat suprafata implicita de test (800px):
  /// sectiunea de plata si blocajele ar ramane in afara arborelui construit lenes
  /// de `ListView`, iar testul ar pica pentru un motiv care n-are legatura cu ele.
  Future<void> pumpCheckout(WidgetTester tester, FakeTransport transport,
      {Size surface = const Size(500, 2000)}) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CheckoutScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('checkout-ul arata adresa, curierii cu tarif si metodele de plata',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);

    expect(find.text('Cabinet Dentar Exemplu SRL'), findsOneWidget);
    expect(find.text('Fan Courier'), findsOneWidget);
    expect(find.text('24,99 lei'), findsOneWidget);
    // Curierul fara cost e etichetat, nu scris cu "0,00 lei".
    expect(find.text('Gratuit'), findsOneWidget);
    expect(find.text('Transfer bancar'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
  });

  testWidgets('alegerea unui curier trimite carrier_id serverului', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when('POST', '/api/app/v1/checkout/delivery',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);
    await tester.tap(find.text('Ridicare din sediu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final call = transport.calls.firstWhere((c) => c.path == '/api/app/v1/checkout/delivery');
    expect(call.body, {'carrier_id': 4});
  });

  testWidgets('un curier indisponibil ramane vizibil, cu motivul, dar nu se poate alege',
      (tester) async {
    final json = checkoutFixture();
    final methods = json['delivery_methods'] as List;
    (methods.first as Map<String, dynamic>)
      ..['available'] = false
      ..['error'] = 'Nu livram in aceasta localitate.';
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout', ApiResponse(status: 200, json: json));

    await pumpCheckout(tester, transport);

    expect(find.text('Fan Courier'), findsOneWidget);
    expect(find.text('Nu livram in aceasta localitate.'), findsOneWidget);
    await tester.tap(find.text('Fan Courier'));
    await tester.pump();
    expect(transport.calls.where((c) => c.path == '/api/app/v1/checkout/delivery'), isEmpty);
  });

  testWidgets('un blocaj il spune si tine butonul de trimitere inchis', (tester) async {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/checkout',
      ApiResponse(status: 200, json: {
        ...checkoutFixture(),
        'selected_delivery_method_id': null,
        'blockers': [
          {'code': 'no_carrier_selected', 'message': 'Alege metoda de livrare.'}
        ],
      }),
    );

    await pumpCheckout(tester, transport);

    expect(find.text('Alege metoda de livrare.'), findsOneWidget);
    final button =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNull);
  });

  testWidgets('cu o singura metoda de plata, ea e deja aleasa', (tester) async {
    final json = checkoutFixture();
    json['payment_options'] = [(json['payment_options'] as List).first];
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout', ApiResponse(status: 200, json: json));

    await pumpCheckout(tester, transport);

    final button =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('cu mai multe metode, butonul asteapta o alegere', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);

    var button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNull);

    await tester.tap(find.text('Transfer bancar'));
    await tester.pump();

    button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('cosul gol da 409 si ecranul arata mesajul serverului', (tester) async {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/checkout',
      const ApiResponse(status: 409, json: {
        'error': {'code': 'empty_cart', 'message': 'Cosul este gol.', 'details': {}}
      }),
    );

    await pumpCheckout(tester, transport);

    expect(find.text('Cosul este gol.'), findsOneWidget);
    expect(find.text('Reincearca'), findsOneWidget);
  });

  testWidgets('totalul de plata e cel al cosului, adus de server', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);

    expect(find.text('Total de plata'), findsOneWidget);
    expect(find.text('280,00 lei'), findsOneWidget);
  });
}

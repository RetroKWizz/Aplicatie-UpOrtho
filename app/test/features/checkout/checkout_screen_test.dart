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


  /// Finalizarea merge pe pasi: Adrese -> Livrare -> Plata. Testele care se uita la
  /// un pas mai departe apasa "Continua" pana acolo, exact ca un client.
  Future<void> continua(WidgetTester tester, {int ori = 1}) async {
    for (var i = 0; i < ori; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Continua'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('checkout-ul arata adresa, curierii cu tarif si metodele de plata',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);

    // Pasul 1: adresele. Adresa principala a contului intra in amandoua listele, ca pe site.
    expect(find.text('Adresa de livrare'), findsOneWidget);
    expect(find.text('Adresa de facturare'), findsOneWidget);
    expect(find.text('Cabinet Dentar Exemplu SRL'), findsNWidgets(2));

    await continua(tester);

    // Pasul 2: curierii, cu tariful lor.
    expect(find.text('Fan Courier'), findsOneWidget);
    expect(find.text('24,99 lei'), findsOneWidget);
    // Curierul fara cost e etichetat, nu scris cu "0,00 lei".
    expect(find.text('Gratuit'), findsOneWidget);

    await continua(tester);

    // Pasul 3: platile, cu ce s-a ales deja scris deasupra.
    expect(find.text('Transfer bancar'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('VISA **** 4242'), findsOneWidget, reason: 'cardul salvat');
    expect(find.text('LIVRARE LA'), findsOneWidget, reason: 'rezumatul pasilor dinainte');
  });

  testWidgets('alegerea unui curier trimite carrier_id serverului', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when('POST', '/api/app/v1/checkout/delivery',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);
    await continua(tester);
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
    await continua(tester);

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
    await continua(tester);

    // Pasul de livrare nu e completat, deci nu se merge mai departe si motivul e scris.
    expect(find.text('Alege metoda de livrare.'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continua'));
    expect(button.onPressed, isNull);
  });

  testWidgets('cu o singura metoda de plata, ea e deja aleasa', (tester) async {
    final json = checkoutFixture();
    json['payment_options'] = [(json['payment_options'] as List).first];
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout', ApiResponse(status: 200, json: json));

    await pumpCheckout(tester, transport);
    await continua(tester, ori: 2);

    final button =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('cu mai multe metode, butonul asteapta o alegere', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);
    await continua(tester, ori: 2);

    var button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNull);

    await tester.tap(find.text('Transfer bancar'));
    await tester.pump();

    button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Trimite comanda'));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('cardul salvat se alege si se trimite cu tokenul lui', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when(
      'POST',
      '/api/app/v1/checkout/confirm',
      const ApiResponse(status: 200, json: {
        'order_id': 5001,
        'order_ref': 'S12345',
        'payment': {
          'kind': 'token',
          'method': 'VISA **** 4242',
          'instructions': <dynamic>[],
          'reference': 'S12345-1',
          'state': 'done',
          'message': null,
          'url': null,
          'return_url_prefix': null,
        },
      }),
    );
    transport.when('GET', '/api/app/v1/cart',
        ApiResponse(status: 200, json: (checkoutFixture()['cart'] as Map).cast<String, dynamic>()));

    await pumpCheckout(tester, transport);
    await continua(tester, ori: 2);
    await tester.tap(find.text('VISA **** 4242'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Trimite comanda'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final call = transport.calls.firstWhere((c) => c.path == '/api/app/v1/checkout/confirm');
    expect(call.body!['token_id'], 4501,
        reason: 'fara token, serverul n-ar sti cu care card salvat sa plateasca');
  });

  testWidgets('doua carduri salvate raman optiuni diferite', (tester) async {
    // Cheia de selectie include tokenul: fara el, al doilea card ar parea acelasi
    // lucru cu primul si clientul n-ar putea alege intre ele.
    final json = checkoutFixture();
    final options = json['payment_options'] as List;
    final first = (options.first as Map).cast<String, dynamic>();
    options.insert(1, {...first, 'token_id': 4502, 'name': 'MASTERCARD **** 8888'});
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout', ApiResponse(status: 200, json: json));

    await pumpCheckout(tester, transport);
    await continua(tester, ori: 2);

    expect(find.text('VISA **** 4242'), findsOneWidget);
    expect(find.text('MASTERCARD **** 8888'), findsOneWidget);
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

  testWidgets('pasii se vad in capul paginii, iar inapoi se poate oricand',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);

    expect(find.text('Adrese'), findsOneWidget);
    expect(find.text('Livrare'), findsOneWidget);
    expect(find.text('Plata'), findsOneWidget);

    await continua(tester, ori: 2);
    expect(find.text('Transfer bancar'), findsOneWidget);

    // Un pas completat se poate apasa ca sa te intorci la el.
    await tester.tap(find.text('Adrese'));
    await tester.pump();
    expect(find.text('Adresa de livrare'), findsOneWidget);
  });

  testWidgets('fara livrare ceruta, pasul de livrare nu exista deloc', (tester) async {
    // Magazinul poate sa nu ceara transport (doar ridicare, produse fara livrare):
    // atunci un pas gol intre adrese si plata ar fi doar un tap in plus.
    final json = {...checkoutFixture(), 'delivery_required': false};
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout', ApiResponse(status: 200, json: json));

    await pumpCheckout(tester, transport);

    expect(find.text('Livrare'), findsNothing);
    await continua(tester);
    expect(find.text('Transfer bancar'), findsOneWidget);
  });

  testWidgets('"Schimba" din rezumat duce inapoi la adrese', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));

    await pumpCheckout(tester, transport);
    await continua(tester, ori: 2);

    await tester.tap(find.text('Schimba').first);
    await tester.pump();

    expect(find.text('Adresa de livrare'), findsOneWidget);
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/design_system/widgets/quantity_stepper.dart';
import 'package:uportho_app/features/cart/cart_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> cartFixture() =>
    jsonDecode(File('test/contract/cart.json').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> emptyCart() => {
      ...cartFixture(),
      'order_id': null,
      'quantity': 0,
      'lines': <dynamic>[],
      'free_delivery': null,
    };

void main() {
  Future<void> pumpCart(WidgetTester tester, FakeTransport transport) async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
      imageHeadersProvider.overrideWith((ref) async => const <String, String>{}),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CartScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('cosul arata linia, pretul unitar, subtotalul si totalul, toate de la server',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));

    await pumpCart(tester, transport);

    expect(find.text('Bracket metalic Roth .022'), findsOneWidget);
    expect(find.text('Dinte: 11'), findsOneWidget);
    expect(find.text('70,00 lei / buc'), findsOneWidget);
    expect(find.text('280,00 lei'), findsNWidgets(2), reason: 'subtotalul liniei si totalul');
    expect(find.text('44,71 lei'), findsOneWidget, reason: 'TVA');
  });

  testWidgets('cu reducere pe linie, pretul pe bucata apare cu cel vechi taiat',
      (tester) async {
    // Cosul de pe site taie pretul nereduse si scrie langa el pretul platit. Aplicatia
    // arata amandoua cifrele; fixture-ul de contract poarta o reducere de 20%.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));

    await pumpCart(tester, transport);

    expect(find.text('70,00 lei / buc'), findsOneWidget);
    final struck = tester.widget<Text>(find.text('87,50 lei'));
    expect(struck.style!.decoration, TextDecoration.lineThrough);
  });

  testWidgets('fara reducere, nu apare niciun pret taiat', (tester) async {
    final json = cartFixture();
    ((json['lines'] as List).first as Map<String, dynamic>)['unit_price'] = {
      ...((json['lines'] as List).first as Map<String, dynamic>)['unit_price']
          as Map<String, dynamic>,
      'list_amount': null,
      'list_formatted': null,
      'discount_pct': null,
    };
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: json));

    await pumpCart(tester, transport);

    expect(find.text('87,50 lei'), findsNothing);
  });

  testWidgets('progresul catre livrarea gratuita arata cat mai lipseste', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));

    await pumpCart(tester, transport);

    expect(find.text('Mai ai 220,00 lei pana la livrare gratuita.'), findsOneWidget);
  });

  testWidgets('pragul atins schimba mesajul, nu il ascunde', (tester) async {
    final json = cartFixture();
    (json['free_delivery'] as Map<String, dynamic>)['reached'] = true;
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: json));

    await pumpCart(tester, transport);

    expect(find.text('Ai livrare gratuita.'), findsOneWidget);
  });

  testWidgets('cosul gol arata un mesaj si un drum inapoi la catalog', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: emptyCart()));

    await pumpCart(tester, transport);

    expect(find.text('Cosul este gol.'), findsOneWidget);
    expect(find.text('Vezi catalogul'), findsOneWidget);
    expect(find.text('Continua comanda'), findsNothing);
  });

  testWidgets('plusul cere serverului noua cantitate, cu set_qty', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));
    transport.when('POST', '/api/app/v1/cart/lines',
        ApiResponse(status: 200, json: cartFixture()));

    await pumpCart(tester, transport);
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    expect(call.body, {
      'lines': [
        {'variant_id': 41868, 'set_qty': 5, 'line_id': 9001}
      ]
    });
  });

  testWidgets('la cantitatea 1, minusul devine buton de stergere', (tester) async {
    final json = cartFixture();
    ((json['lines'] as List).first as Map<String, dynamic>)['quantity'] = 1;
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: json));
    transport.when('POST', '/api/app/v1/cart/lines',
        ApiResponse(status: 200, json: emptyCart()));

    await pumpCart(tester, transport);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    expect((call.body!['lines'] as List).single, containsPair('set_qty', 0));
  });

  testWidgets('cat timp cererea e in aer, pasii liniei sunt inactivi', (tester) async {
    // Doua apasari rapide ar trimite doua cereri concurente pe aceeasi linie, iar
    // cea intoarsa a doua ar castiga - cantitatea afisata n-ar mai fi cea comandata.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));
    final gate = Completer<void>();
    transport.whenDelayed('POST', '/api/app/v1/cart/lines',
        ApiResponse(status: 200, json: cartFixture()), gate);

    await pumpCart(tester, transport);
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();

    final stepper = tester.widget<QuantityStepper>(find.byType(QuantityStepper));
    expect(stepper.busy, isTrue);

    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('o eroare la incarcarea cosului lasa un buton de reincercare', (tester) async {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/cart',
      const ApiResponse(status: 500, json: {
        'error': {'code': 'internal_error', 'message': 'A aparut o eroare.', 'details': {}}
      }),
    );

    await pumpCart(tester, transport);

    expect(find.text('A aparut o eroare.'), findsOneWidget);
    expect(find.text('Reincearca'), findsOneWidget);
  });
}

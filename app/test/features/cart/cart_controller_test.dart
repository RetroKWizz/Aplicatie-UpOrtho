import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/cart/cart_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> cartFixture({int quantity = 11}) {
  final json = jsonDecode(File('test/contract/cart.json').readAsStringSync())
      as Map<String, dynamic>;
  return {...json, 'quantity': quantity};
}

void main() {
  ProviderContainer containerFor(FakeTransport transport) {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('cosul se citeste o singura data pentru toata aplicatia', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));
    final container = containerFor(transport);

    final cart = await container.read(cartControllerProvider.future);
    expect(cart.quantity, 11);
    // Badge-ul din tab bar citeste acelasi provider, fara alta cerere.
    expect(container.read(cartQuantityProvider), 11);
    expect(transport.calls.where((c) => c.path == '/api/app/v1/cart').length, 1);
  });

  test('add trimite add_qty si sare peste randurile cu zero', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture(quantity: 0)));
    transport.when('POST', '/api/app/v1/cart/lines',
        ApiResponse(status: 200, json: cartFixture(quantity: 5)));
    final container = containerFor(transport);
    await container.read(cartControllerProvider.future);

    await container.read(cartControllerProvider.notifier).add({11: 2, 12: 0, 13: 3});

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    expect(call.body, {
      'lines': [
        {'variant_id': 11, 'add_qty': 2},
        {'variant_id': 13, 'add_qty': 3},
      ]
    });
    // Starea devine cosul intors de server, nu o versiune calculata local.
    expect(container.read(cartQuantityProvider), 5);
  });

  test('setQuantity trimite set_qty, nu add_qty', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));
    transport.when('POST', '/api/app/v1/cart/lines',
        ApiResponse(status: 200, json: cartFixture(quantity: 3)));
    final container = containerFor(transport);
    await container.read(cartControllerProvider.future);

    await container
        .read(cartControllerProvider.notifier)
        .setQuantity(variantId: 41868, quantity: 3, lineId: 9001);

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    expect(call.body, {
      'lines': [
        {'variant_id': 41868, 'set_qty': 3, 'line_id': 9001}
      ]
    });
  });

  test('stergerea unei linii trimite set_qty zero', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture()));
    transport.when('POST', '/api/app/v1/cart/lines',
        ApiResponse(status: 200, json: cartFixture(quantity: 0)));
    final container = containerFor(transport);
    await container.read(cartControllerProvider.future);

    await container.read(cartControllerProvider.notifier).remove(variantId: 41868, lineId: 9001);

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    expect((call.body!['lines'] as List).single, containsPair('set_qty', 0));
  });

  test('avertismentele serverului se intorc apelantului, ca sa le poata arata', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart', ApiResponse(status: 200, json: cartFixture(quantity: 0)));
    transport.when(
      'POST',
      '/api/app/v1/cart/lines',
      ApiResponse(status: 200, json: {
        ...cartFixture(quantity: 2),
        'warnings': ['Stoc insuficient: cantitatea a fost redusa la 2.'],
      }),
    );
    final container = containerFor(transport);
    await container.read(cartControllerProvider.future);

    final warnings = await container.read(cartControllerProvider.notifier).add({11: 5});

    expect(warnings.single, contains('Stoc insuficient'));
  });

  test('un cos care nu se poate citi devine eroare, nu badge gresit', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/cart',
        const ApiResponse(status: 500, json: {
          'error': {'code': 'internal_error', 'message': 'A aparut o eroare.', 'details': {}}
        }));
    final container = containerFor(transport);

    await expectLater(container.read(cartControllerProvider.future), throwsA(anything));
    // Badge-ul nu arata un numar inventat cand cosul n-a putut fi citit.
    expect(container.read(cartQuantityProvider), 0);
  });
}

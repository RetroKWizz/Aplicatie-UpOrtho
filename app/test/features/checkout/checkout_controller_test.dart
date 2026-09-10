import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/checkout.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/cart/cart_controller.dart';
import 'package:uportho_app/features/checkout/checkout_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> checkoutFixture() =>
    jsonDecode(File('test/contract/checkout.json').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> confirmOfflineFixture() =>
    jsonDecode(File('test/contract/checkout_confirm_offline.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  ProviderContainer containerFor(FakeTransport transport) {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('checkout-ul se citeste de la server, cu totul', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    final container = containerFor(transport);

    final checkout = await container.read(checkoutControllerProvider.future);
    expect(checkout.deliveryMethods.length, 2);
    expect(checkout.paymentOptions.length, 2);
  });

  test('alegerea curierului trimite carrier_id si preia checkout-ul recalculat', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when(
      'POST',
      '/api/app/v1/checkout/delivery',
      ApiResponse(status: 200, json: {...checkoutFixture(), 'selected_delivery_method_id': 4}),
    );
    final container = containerFor(transport);
    await container.read(checkoutControllerProvider.future);

    await container.read(checkoutControllerProvider.notifier).chooseDeliveryMethod(4);

    final call = transport.calls.firstWhere((c) => c.path == '/api/app/v1/checkout/delivery');
    expect(call.body, {'carrier_id': 4});
    expect(container.read(checkoutControllerProvider).value!.selectedDeliveryMethodId, 4);
  });

  test('cosul preia totalurile venite cu checkout-ul, fara alta cerere', () async {
    // Transportul cere ca ecranul de cos si badge-ul sa arate acelasi total ca
    // checkout-ul imediat dupa alegerea transportului.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    final withDelivery = checkoutFixture();
    (withDelivery['cart'] as Map<String, dynamic>)['quantity'] = 7;
    transport.when('POST', '/api/app/v1/checkout/delivery',
        ApiResponse(status: 200, json: withDelivery));
    transport.when('GET', '/api/app/v1/cart',
        ApiResponse(status: 200, json: (checkoutFixture()['cart'] as Map).cast<String, dynamic>()));
    final container = containerFor(transport);
    // Cosul e deja citit in aplicatia reala: badge-ul din tab bar il tine viu.
    await container.read(cartControllerProvider.future);
    await container.read(checkoutControllerProvider.future);

    await container.read(checkoutControllerProvider.notifier).chooseDeliveryMethod(4);

    expect(container.read(cartQuantityProvider), 7);
    // Totalurile au venit cu raspunsul checkout-ului: nicio a doua citire de cos.
    expect(transport.calls.where((c) => c.path == '/api/app/v1/cart').length, 1);
  });

  test('alegerea adresei trimite doar campul cerut', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when('POST', '/api/app/v1/checkout/address',
        ApiResponse(status: 200, json: checkoutFixture()));
    final container = containerFor(transport);
    await container.read(checkoutControllerProvider.future);

    await container.read(checkoutControllerProvider.notifier).chooseDeliveryAddress(7001);

    final call = transport.calls.firstWhere((c) => c.path == '/api/app/v1/checkout/address');
    expect(call.body, {'delivery_id': 7001});
  });

  test('confirmarea trimite metoda si providerul, apoi reciteste cosul', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when('POST', '/api/app/v1/checkout/confirm',
        ApiResponse(status: 200, json: confirmOfflineFixture()));
    transport.when(
      'GET',
      '/api/app/v1/cart',
      ApiResponse(status: 200, json: {
        ...jsonDecode(File('test/contract/cart.json').readAsStringSync()) as Map<String, dynamic>,
        'order_id': null,
        'quantity': 0,
        'lines': <dynamic>[],
      }),
    );
    final container = containerFor(transport);
    final checkout = await container.read(checkoutControllerProvider.future);
    final option = checkout.paymentOptions.firstWhere((o) => o.isOffline);

    final confirmation = await container.read(checkoutControllerProvider.notifier).confirm(option);

    final call = transport.calls.firstWhere((c) => c.path == '/api/app/v1/checkout/confirm');
    expect(call.body, {
      'payment_method_id': option.paymentMethodId,
      'provider_id': option.providerId,
    });
    expect(confirmation.payment.isOffline, isTrue);
    // Dupa o comanda trimisa, cosul e gol: badge-ul trebuie sa arate zero.
    expect(container.read(cartQuantityProvider), 0);
  });

  test('o confirmare respinsa de server nu goleste cosul', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/checkout',
        ApiResponse(status: 200, json: checkoutFixture()));
    transport.when(
      'POST',
      '/api/app/v1/checkout/confirm',
      const ApiResponse(status: 409, json: {
        'error': {'code': 'cart_not_ready', 'message': 'Alege metoda de livrare.', 'details': {}}
      }),
    );
    final container = containerFor(transport);
    final checkout = await container.read(checkoutControllerProvider.future);
    final option = checkout.paymentOptions.first;

    await expectLater(
        container.read(checkoutControllerProvider.notifier).confirm(option), throwsA(anything));
    expect(transport.calls.where((c) => c.path == '/api/app/v1/cart'), isEmpty);
  });

  test('un checkout picat lasa eroarea la vedere, nu o stare goala', () async {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/checkout',
      const ApiResponse(status: 409, json: {
        'error': {'code': 'empty_cart', 'message': 'Cosul este gol.', 'details': {}}
      }),
    );
    final container = containerFor(transport);

    await expectLater(container.read(checkoutControllerProvider.future), throwsA(anything));
    expect(container.read(checkoutControllerProvider).hasError, isTrue);
  });

  test('optiunea de plata cu card poarta adresa paginii de plata', () async {
    final checkout = Checkout.fromJson(checkoutFixture());
    final card = checkout.paymentOptions.firstWhere((o) => !o.isOffline);
    expect(card.kind, 'webview');
  });
}

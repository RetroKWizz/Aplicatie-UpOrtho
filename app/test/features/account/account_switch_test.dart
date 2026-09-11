import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/account_controller.dart';
import 'package:uportho_app/features/auth/auth_controller.dart';
import 'package:uportho_app/features/cart/cart_controller.dart';
import 'package:uportho_app/features/catalog/catalog_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

/// Doua conturi diferite pe acelasi telefon. Al doilea NU are voie sa vada nimic
/// din datele primului.
///
/// Defect real, prins pe staging cu doua conturi adevarate: dupa logout si login cu
/// alt cont, ecranul "Contul meu" arata comenzile si adresele contului dinainte.
/// Cauza: `ordersProvider`, `invoicesProvider` si `addressesProvider` nu depindeau de
/// starea de autentificare, iar Riverpod pastreaza valoarea in cache cat traieste
/// containerul. Profilul se schimba (venea din raspunsul de login), restul nu.
Map<String, dynamic> ordersFor(String name) => {
      'orders': [
        {
          'id': name.hashCode.abs() % 1000,
          'name': name,
          'date': '2026-09-01',
          'state': 'sale',
          'state_label': 'Confirmata',
          'total': {
            'amount': 10.0,
            'currency': 'RON',
            'formatted': '10,00 lei',
            'with_vat': true,
            'list_amount': null,
            'list_formatted': null,
            'discount_pct': null,
          },
          'line_count': 1,
          'delivery_method': null,
          'invoice_count': 0,
        }
      ],
      'total': 1,
      'offset': 0,
      'limit': 20,
    };

List<Map<String, dynamic>> addressesFor(String name) => [
      {
        'id': name.hashCode.abs() % 1000,
        'name': name,
        'street': 'Str. Test 1',
        'street2': null,
        'city': 'Cluj-Napoca',
        'zip': '400001',
        'state': 'Cluj',
        'country': 'Romania',
        'phone': null,
        'email': null,
        'vat': null,
        'type': 'contact',
      }
    ];

Map<String, dynamic> emptyInvoices() =>
    {'invoices': <dynamic>[], 'total': 0, 'offset': 0, 'limit': 20};

Map<String, dynamic> cartFor(int quantity) {
  final json = jsonDecode(File('test/contract/cart.json').readAsStringSync())
      as Map<String, dynamic>;
  return {...json, 'quantity': quantity};
}

Map<String, dynamic> userJson(String name) => {
      'user': {'id': 1, 'name': name, 'email': '$name@test.ro', 'partner_id': 2}
    };

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  /// Schimba ce raspunde serverul, ca si cum ar fi alt cont conectat.
  void serveAccount(String name, {int cartQuantity = 0}) {
    transport
      ..when('GET', '/api/app/v1/orders?offset=0&limit=20',
          ApiResponse(status: 200, json: ordersFor(name)))
      ..when('GET', '/api/app/v1/invoices?offset=0&limit=20',
          ApiResponse(status: 200, json: emptyInvoices()))
      ..when('GET', '/api/app/v1/addresses',
          ApiResponse(status: 200, json: addressesFor(name)))
      ..when('GET', '/api/app/v1/cart',
          ApiResponse(status: 200, json: cartFor(cartQuantity)))
      ..when('POST', '/api/app/v1/auth/login',
          ApiResponse(status: 200, json: userJson(name)));
  }

  setUp(() {
    transport = FakeTransport();
    transport.when('GET', '/api/app/v1/me', ApiResponse(status: 200, json: userJson('primul')));
    serveAccount('PRIMUL', cartQuantity: 3);
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
  });

  /// Logout urmat de login cu alt cont, exact ca pe telefon.
  Future<void> switchTo(String name, {int cartQuantity = 0}) async {
    final auth = container.read(authControllerProvider.notifier);
    await auth.logout();
    serveAccount(name, cartQuantity: cartQuantity);
    await auth.login('$name@test.ro', 'parola');
    await container.read(authControllerProvider.future);
  }

  test('al doilea cont nu vede comenzile primului', () async {
    await container.read(authControllerProvider.future);
    expect((await container.read(ordersProvider.future)).orders.single.name, 'PRIMUL');

    await switchTo('AL_DOILEA');

    expect((await container.read(ordersProvider.future)).orders.single.name, 'AL_DOILEA');
  });

  test('al doilea cont nu vede adresele primului', () async {
    await container.read(authControllerProvider.future);
    expect((await container.read(addressesProvider.future)).single.name, 'PRIMUL');

    await switchTo('AL_DOILEA');

    expect((await container.read(addressesProvider.future)).single.name, 'AL_DOILEA');
  });

  test('al doilea cont nu vede facturile primului', () async {
    await container.read(authControllerProvider.future);
    await container.read(invoicesProvider.future);
    final inainte = transport.calls.where((c) => c.path.startsWith('/api/app/v1/invoices')).length;

    await switchTo('AL_DOILEA');
    await container.read(invoicesProvider.future);

    expect(transport.calls.where((c) => c.path.startsWith('/api/app/v1/invoices')).length,
        greaterThan(inainte),
        reason: 'facturile se cer din nou pentru contul nou, nu se iau din cache');
  });

  test('al doilea cont nu vede cosul primului', () async {
    await container.read(authControllerProvider.future);
    expect(await container.read(cartControllerProvider.future), isNotNull);
    expect(container.read(cartQuantityProvider), 3);

    await switchTo('AL_DOILEA', cartQuantity: 0);
    await container.read(cartControllerProvider.future);

    expect(container.read(cartQuantityProvider), 0,
        reason: 'badge-ul din tab bar ar arata altfel cosul contului dinainte');
  });

  test('grila de catalog se reincarca la schimbarea contului, pentru preturile lui',
      () async {
    transport.when(
      'GET',
      '/api/app/v1/products?offset=0&limit=20',
      const ApiResponse(status: 200, json: {
        'products': <dynamic>[],
        'total': 0,
        'offset': 0,
        'limit': 20,
      }),
    );
    await container.read(authControllerProvider.future);
    await container.read(catalogControllerProvider.notifier).ensureLoaded();
    final inainte = transport.calls.where((c) => c.path.startsWith('/api/app/v1/products')).length;
    expect(inainte, 1);

    await switchTo('AL_DOILEA');
    // Reincarcarea porneste din listener, nu din apelul nostru: ii lasam cateva
    // treceri prin bucla de evenimente ca sa ajunga la transport.
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(transport.calls.where((c) => c.path.startsWith('/api/app/v1/products')).length,
        greaterThan(inainte),
        reason: 'preturile din grila sunt ale contului; cele vechi nu mai sunt valabile');
  });
}

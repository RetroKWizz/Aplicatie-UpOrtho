import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/product/product_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> detailFixture() =>
    jsonDecode(File('test/contract/product_detail.json').readAsStringSync()) as Map<String, dynamic>;

/// Fixture-ul de contract cu cateva campuri inlocuite (varianta ceruta are alt
/// pret si alt cod - exact ce se schimba pe server la trecerea pe alta varianta).
Map<String, dynamic> detailWith(Map<String, dynamic> overrides) => {...detailFixture(), ...overrides};

/// Selector cu doua atribute: acolo combinatia unei valori NU e id-ul ei singur,
/// deci testele pot dovedi ca aplicatia trimite combinatia primita de la server,
/// nu id-ul valorii apasate (singurul lucru pe care il stie ecranul).
Map<String, dynamic> twoAttributeVariantsJson() => {
      'selected': [1357, 2401],
      'attributes': [
        {
          'id': 7,
          'name': 'Marime',
          'values': [
            {'id': 1357, 'name': 'Mare', 'selected': true, 'available': true,
             'combination': [1357, 2401]},
            {'id': 1358, 'name': 'Mic', 'selected': false, 'available': true,
             'combination': [1358, 2401]},
          ],
        },
        {
          'id': 8,
          'name': 'Culoare',
          'values': [
            {'id': 2401, 'name': 'Argintiu', 'selected': true, 'available': true,
             'combination': [1357, 2401]},
            {'id': 2402, 'name': 'Auriu', 'selected': false, 'available': true,
             'combination': [1357, 2402]},
          ],
        },
      ],
    };

/// Transport care tine raspunsul in loc (un `Completer` per apel), ca testul sa
/// poata inspecta starea EXACT in timp ce cererea e in aer - altfel raspunsurile
/// imediate ale lui `FakeTransport` fac starea intermediara imposibil de observat.
class PendingTransport implements ApiTransport {
  final List<String> paths = [];
  final List<Completer<ApiResponse>> pending = [];

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) {
    paths.add(path);
    final completer = Completer<ApiResponse>();
    pending.add(completer);
    return completer.future;
  }
}

void main() {
  ProviderContainer containerWith(ApiTransport transport) {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('build() aduce produsul si il expune ca stare', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    final container = containerWith(transport);

    final state = await container.read(productControllerProvider(101).future);

    expect(state.detail.id, 101);
    expect(state.isSwitchingVariant, isFalse);
    expect(transport.calls.single.path, '/api/app/v1/products/101');
  });

  test('eroarea de la server apare imediat, fara reincercarea automata a Riverpod', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', const ApiResponse(status: 500, json: {
      'error': {'code': 'internal_error', 'message': 'Serverul nu raspunde.', 'details': {}}
    }));
    final container = containerWith(transport);

    // Riverpod 3 reincearca implicit erorile din build() cu backoff pana la ~38s;
    // fara `retry: null` pe provider, acest expectLater ar depasi timeout-ul de
    // 30s al testului in loc sa arunce imediat, iar utilizatorul ar privi un
    // spinner o jumatate de minut inainte sa vada eroarea.
    await expectLater(
      container.read(productControllerProvider(101).future),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 500)),
    );
    // O singura cerere: dovada ca nu s-a reincercat in fundal.
    expect(transport.calls.length, 1);
  });

  test('schimbarea variantei trimite combinatia valorii, nu id-ul ei, si inlocuieste detaliul',
      () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: detailWith({'variants': twoAttributeVariantsJson()})));
    transport.when(
      'GET',
      '/api/app/v1/products/101?values=1358,2401',
      ApiResponse(
        status: 200,
        json: detailWith({
          'variant_id': 502,
          'default_code': 'IX955',
          'price': {
            'amount': 990.0,
            'currency': 'RON',
            'formatted': '990,00 lei',
            'with_vat': true,
            'list_amount': null,
            'list_formatted': null,
            'discount_pct': null,
          },
        }),
      ),
    );
    final container = containerWith(transport);
    await container.read(productControllerProvider(101).future);

    await container.read(productControllerProvider(101).notifier).selectVariantValue(1358);

    final state = container.read(productControllerProvider(101)).value!;
    expect(state.detail.defaultCode, 'IX955');
    expect(state.detail.price.formatted, '990,00 lei');
    expect(state.isSwitchingVariant, isFalse);
    expect(transport.calls.last.path, '/api/app/v1/products/101?values=1358,2401');
  });

  test('o valoare fara combinatie in raspuns se cere ca o combinatie de un singur id',
      () async {
    // Fixture-ul de contract are un singur atribut, deci combinatia unei valori e
    // exact valoarea ei; nici asa aplicatia nu compune id-uri de la sine.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    transport.when('GET', '/api/app/v1/products/101?values=1358',
        ApiResponse(status: 200, json: detailFixture()));
    final container = containerWith(transport);
    await container.read(productControllerProvider(101).future);

    await container.read(productControllerProvider(101).notifier).selectVariantValue(1358);

    expect(transport.calls.last.path, '/api/app/v1/products/101?values=1358');
  });

  test('cat timp se schimba varianta, detaliul vechi ramane in stare (fara AsyncLoading)', () async {
    final transport = PendingTransport();
    final container = containerWith(transport);

    final loading = container.read(productControllerProvider(101).future);
    transport.pending.first.complete(ApiResponse(status: 200, json: detailFixture()));
    await loading;

    final switching = container.read(productControllerProvider(101).notifier).selectVariantValue(1358);

    // Momentul critic: cererea e in aer. Ecranul NU are voie sa cada pe spinner -
    // ar reconstrui galeria si ar pierde pozitia de scroll pentru o schimbare care
    // atinge doar pretul, codul si pozele.
    final during = container.read(productControllerProvider(101));
    expect(during.isLoading, isFalse);
    expect(during.value!.isSwitchingVariant, isTrue);
    expect(during.value!.detail.price.formatted, '1.120,00 lei');

    transport.pending.last.complete(ApiResponse(status: 200, json: detailFixture()));
    await switching;
    expect(container.read(productControllerProvider(101)).value!.isSwitchingVariant, isFalse);
  });

  test('o schimbare de varianta esuata pastreaza detaliul precedent si arata mesajul', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    transport.when('GET', '/api/app/v1/products/101?values=1358', const ApiResponse(status: 422, json: {
      'error': {'code': 'validation_error', 'message': 'values nu apartin acestui produs.', 'details': {}}
    }));
    final container = containerWith(transport);
    await container.read(productControllerProvider(101).future);

    await container.read(productControllerProvider(101).notifier).selectVariantValue(1358);

    final state = container.read(productControllerProvider(101));
    expect(state.hasError, isFalse, reason: 'un esec pe varianta nu arunca tot ecranul pe eroare');
    expect(state.value!.detail.defaultCode, 'IX954');
    expect(state.value!.variantError, 'values nu apartin acestui produs.');
    expect(state.value!.isSwitchingVariant, isFalse);
  });

  test('doua produse deschise au stari separate (family pe id)', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    transport.when('GET', '/api/app/v1/products/102',
        ApiResponse(status: 200, json: detailWith({'id': 102, 'name': 'Alt produs'})));
    final container = containerWith(transport);

    final first = await container.read(productControllerProvider(101).future);
    final second = await container.read(productControllerProvider(102).future);

    expect(first.detail.name, 'Cleste Tie Back mare (.016 - .021x.025) Ixion');
    expect(second.detail.name, 'Alt produs');
  });
}

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

Map<String, dynamic> pricesFixture() =>
    jsonDecode(File('test/contract/product_prices.json').readAsStringSync()) as Map<String, dynamic>;

/// Raspunsul rutei de preturi cu alt total, ca testele sa poata deosebi doua
/// raspunsuri fara sa compuna ele vreo suma.
Map<String, dynamic> pricesWithTotal(String formatted) => {
      ...pricesFixture(),
      'total': {
        ...(pricesFixture()['total'] as Map).cast<String, dynamic>(),
        'formatted': formatted,
      },
    };

/// Tine providerul (autoDispose) in viata cat dureaza asteptarile din test:
/// altfel, in pauza de dupa `read`, Riverpod il arunca si orice `state` de dupa ar
/// exploda cu "Cannot use the Ref ... after it has been disposed" - un artefact de
/// test, nu comportamentul din aplicatie (unde ecranul asculta providerul).
void keepAlive(ProviderContainer container, int productId) {
  container.listen(productControllerProvider(productId), (_, _) {});
}

/// Mai mult decat debounce-ul: dupa asta cererea amanata a plecat deja.
Future<void> afterDebounce() =>
    Future<void>.delayed(quantityDebounce + const Duration(milliseconds: 80));

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

  @override
  Future<ApiResponse> download(String url, String savePath) =>
      throw UnimplementedError('produsul nu descarca fisiere prin acest transport');
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

  // --- tabelul de variante: cantitati, debounce, preturi de la server ---------

  test('cantitatile pornesc de la zero, cate una per rand de varianta', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    final container = containerWith(transport);
    keepAlive(container, 101);

    final state = await container.read(productControllerProvider(101).future);

    expect(state.quantities, {501: 0, 502: 0});
    // Nicio cerere de preturi la incarcare: un tabel gol n-are ce total sa arate,
    // iar aplicatia nu are voie sa scrie ea "0,00 lei".
    expect(transport.calls.length, 1);
    expect(state.prices, isNull);
  });

  test('o cantitate schimbata apare imediat, dar cererea pleaca abia dupa debounce', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    transport.when('POST', '/api/app/v1/products/101/prices',
        ApiResponse(status: 200, json: pricesFixture()));
    final container = containerWith(transport);
    keepAlive(container, 101);
    await container.read(productControllerProvider(101).future);

    container.read(productControllerProvider(101).notifier).setQuantity(501, 3);

    // Steperul raspunde pe loc; reteaua asteapta.
    expect(container.read(productControllerProvider(101)).value!.quantities[501], 3);
    expect(transport.calls.length, 1);

    await afterDebounce();

    expect(transport.calls.last.method, 'POST');
    expect(transport.calls.last.body, {
      'lines': [
        {'variant_id': 501, 'qty': 3},
        {'variant_id': 502, 'qty': 0},
      ],
    });
    expect(container.read(productControllerProvider(101)).value!.prices!.total.formatted,
        '5.600,00 lei');
  });

  test('tinut apasat pe plus, se trimite o singura cerere, cu ultima cantitate', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    transport.when('POST', '/api/app/v1/products/101/prices',
        ApiResponse(status: 200, json: pricesFixture()));
    final container = containerWith(transport);
    keepAlive(container, 101);
    await container.read(productControllerProvider(101).future);
    final notifier = container.read(productControllerProvider(101).notifier);

    for (var qty = 1; qty <= 6; qty++) {
      notifier.setQuantity(501, qty);
    }
    await afterDebounce();

    final posts = transport.calls.where((call) => call.method == 'POST').toList();
    expect(posts.length, 1, reason: 'sase apasari, o singura cerere');
    expect((posts.single.body!['lines'] as List).first, {'variant_id': 501, 'qty': 6});
  });

  test('cat timp preturile se recalculeaza, cele vechi raman pe ecran', () async {
    final transport = PendingTransport();
    final container = containerWith(transport);
    keepAlive(container, 101);

    final loading = container.read(productControllerProvider(101).future);
    transport.pending.first.complete(ApiResponse(status: 200, json: detailFixture()));
    await loading;
    final notifier = container.read(productControllerProvider(101).notifier);

    notifier.setQuantity(501, 5);
    await afterDebounce();
    transport.pending.last.complete(ApiResponse(status: 200, json: pricesWithTotal('5.600,00 lei')));
    await Future<void>.delayed(Duration.zero);

    notifier.setQuantity(501, 6);
    await afterDebounce();

    // Momentul critic: a doua cerere e in aer. Ecranul NU are voie sa ramana fara
    // cifre - ar clipi la fiecare apasare pe plus.
    final during = container.read(productControllerProvider(101)).value!;
    expect(during.isPricing, isTrue);
    expect(during.prices!.total.formatted, '5.600,00 lei');

    transport.pending.last.complete(ApiResponse(status: 200, json: pricesWithTotal('6.720,00 lei')));
    await Future<void>.delayed(Duration.zero);
    final after = container.read(productControllerProvider(101)).value!;
    expect(after.isPricing, isFalse);
    expect(after.prices!.total.formatted, '6.720,00 lei');
  });

  test('o cerere de preturi esuata pastreaza preturile vechi si arata mesajul', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    transport.when('POST', '/api/app/v1/products/101/prices',
        ApiResponse(status: 200, json: pricesWithTotal('5.600,00 lei')));
    final container = containerWith(transport);
    keepAlive(container, 101);
    await container.read(productControllerProvider(101).future);
    final notifier = container.read(productControllerProvider(101).notifier);

    notifier.setQuantity(501, 5);
    await afterDebounce();

    transport.when('POST', '/api/app/v1/products/101/prices', const ApiResponse(status: 500, json: {
      'error': {'code': 'internal_error', 'message': 'Serverul nu raspunde.', 'details': {}}
    }));
    notifier.setQuantity(501, 6);
    await afterDebounce();

    final state = container.read(productControllerProvider(101));
    expect(state.hasError, isFalse, reason: 'un esec pe preturi nu arunca tot ecranul pe eroare');
    expect(state.value!.prices!.total.formatted, '5.600,00 lei');
    expect(state.value!.pricesError, 'Serverul nu raspunde.');
    expect(state.value!.isPricing, isFalse);
  });

  test('o cantitate negativa nu ajunge niciodata la server', () async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: detailFixture()));
    final container = containerWith(transport);
    keepAlive(container, 101);
    await container.read(productControllerProvider(101).future);

    container.read(productControllerProvider(101).notifier).setQuantity(501, -1);
    await afterDebounce();

    expect(container.read(productControllerProvider(101)).value!.quantities[501], 0);
    expect(transport.calls.where((call) => call.method == 'POST'), isEmpty);
  });
}

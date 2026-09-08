import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/catalog/catalog_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  Map<String, dynamic> productJson(int id, {String name = ''}) => {
        'id': id,
        'name': name.isEmpty ? 'Produs $id' : name,
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

  Map<String, dynamic> productsPage({required List<int> ids, required int total, int offset = 0, int limit = 20}) => {
        'products': [for (final id in ids) productJson(id)],
        'total': total,
        'offset': offset,
        'limit': limit,
      };

  setUp(() {
    transport = FakeTransport();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  CatalogController notifier() => container.read(catalogControllerProvider.notifier);

  test('build() e sincron si gol - nicio cerere de retea inainte de ensureLoaded', () {
    final state = container.read(catalogControllerProvider);
    expect(state.value?.products, isEmpty);
    expect(transport.calls, isEmpty);
  });

  test('ensureLoaded incarca prima pagina fara filtre', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1, 2], total: 2)));

    await notifier().ensureLoaded();

    final state = container.read(catalogControllerProvider).value!;
    expect(state.products.map((p) => p.id), [1, 2]);
    expect(state.total, 2);
    expect(state.hasMore, isFalse);
  });

  test('ensureLoaded e idempotent - un al doilea apel nu porneste o a doua cerere', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1], total: 1)));

    await notifier().ensureLoaded();
    await notifier().ensureLoaded(categoryId: 99); // ignorat - deja initializat

    expect(transport.calls.where((c) => c.path.startsWith('/api/app/v1/products')), hasLength(1));
  });

  test('ensureLoaded cu o categorie initiala o trimite pe prima cerere', () async {
    transport.when('GET', '/api/app/v1/products?category_id=12&offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1], total: 1)));

    await notifier().ensureLoaded(categoryId: 12);

    expect(container.read(catalogCategoryFilterProvider), 12);
    expect(container.read(catalogControllerProvider).value!.products, hasLength(1));
  });

  test('loadMore adauga a doua pagina la lista existenta, nu o inlocuieste', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1, 2], total: 3)));
    await notifier().ensureLoaded();
    expect(container.read(catalogControllerProvider).value!.hasMore, isTrue);

    transport.when('GET', '/api/app/v1/products?offset=2&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [3], total: 3, offset: 2)));
    await notifier().loadMore();

    final state = container.read(catalogControllerProvider).value!;
    expect(state.products.map((p) => p.id), [1, 2, 3]);
    expect(state.hasMore, isFalse);
  });

  test('loadMore nu face nimic cand nu mai exista pagini (hasMore == false)', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1], total: 1)));
    await notifier().ensureLoaded();

    await notifier().loadMore();

    expect(transport.calls.where((c) => c.path.startsWith('/api/app/v1/products')), hasLength(1));
  });

  test('setCategory reincarca de la prima pagina cu category_id in query', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1, 2], total: 2)));
    await notifier().ensureLoaded();

    transport.when('GET', '/api/app/v1/products?category_id=15&offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [9], total: 1)));
    await notifier().setCategory(15);

    final state = container.read(catalogControllerProvider).value!;
    // Lista veche (produsele 1,2) e INLOCUITA, nu extinsa - altfel un filtru nou
    // ar amesteca rezultate din doua categorii diferite.
    expect(state.products.map((p) => p.id), [9]);
    expect(container.read(catalogCategoryFilterProvider), 15);
  });

  test('setQuery cauta dupa nume/cod si reincarca de la prima pagina', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1], total: 1)));
    await notifier().ensureLoaded();

    transport.when('GET', '/api/app/v1/products?q=bracket&offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [7], total: 1)));
    await notifier().setQuery('bracket');

    final state = container.read(catalogControllerProvider).value!;
    expect(state.products.map((p) => p.id), [7]);
    expect(container.read(catalogSearchQueryProvider), 'bracket');
  });

  test('categorie si cautare combinate produc query-ul cu ambii parametri', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [], total: 0)));
    await notifier().ensureLoaded();

    transport.when('GET', '/api/app/v1/products?category_id=15&q=bracket&offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [7], total: 1)));
    await notifier().setCategory(15);
    await notifier().setQuery('bracket');

    expect(container.read(catalogControllerProvider).value!.products.map((p) => p.id), [7]);
  });

  test('eroarea serverului ajunge ca AsyncError cu mesajul in romana', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20', const ApiResponse(status: 500, json: {
      'error': {'code': 'internal_error', 'message': 'A aparut o eroare pe server. Incearca din nou.', 'details': {}}
    }));

    await notifier().ensureLoaded();

    final state = container.read(catalogControllerProvider);
    expect(state.hasError, isTrue);
    expect((state.error as ApiException).message, 'A aparut o eroare pe server. Incearca din nou.');
  });

  test('retry() reface exact aceeasi cerere dupa un esec', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20', const ApiResponse(status: 500, json: null));
    await notifier().ensureLoaded();
    expect(container.read(catalogControllerProvider).hasError, isTrue);

    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1], total: 1)));
    await notifier().retry();

    final state = container.read(catalogControllerProvider);
    expect(state.hasError, isFalse);
    expect(state.value!.products, hasLength(1));
  });

  test('un loadMore esuat pastreaza produsele deja incarcate si expune eroarea separat', () async {
    transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(status: 200, json: productsPage(ids: [1, 2], total: 3)));
    await notifier().ensureLoaded();

    transport.when('GET', '/api/app/v1/products?offset=2&limit=20', const ApiResponse(status: 500, json: {
      'error': {'code': 'internal_error', 'message': 'Nu s-au putut incarca mai multe produse.', 'details': {}}
    }));
    await notifier().loadMore();

    final state = container.read(catalogControllerProvider).value!;
    // Produsele bune raman pe ecran - un load-more esuat nu inlocuieste grila cu
    // un ecran de eroare.
    expect(state.products.map((p) => p.id), [1, 2]);
    expect(state.isLoadingMore, isFalse);
    expect(state.loadMoreError, 'Nu s-au putut incarca mai multe produse.');
  });
}

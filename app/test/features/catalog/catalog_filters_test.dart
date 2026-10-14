import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/products_response.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/catalog/catalog_controller.dart';
import 'package:uportho_app/features/catalog/catalog_filter_sheet.dart';
import 'package:uportho_app/features/catalog/product_filter_selection.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  Map<String, dynamic> page({
    List<int> ids = const [1],
    int total = 1,
    Map<String, dynamic>? filters,
  }) =>
      {
        'products': [
          for (final id in ids)
            {
              'id': id,
              'name': 'Produs $id',
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
            },
        ],
        'total': total,
        'offset': 0,
        'limit': 20,
        'filters': ?filters,
      };

  setUp(() {
    transport = FakeTransport();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  CatalogController notifier() => container.read(catalogControllerProvider.notifier);

  group('ProductFilterSelection', () {
    test('jetoanele au formatul magazinului si ies sortate, ca URL-ul sa fie stabil', () {
      const empty = ProductFilterSelection.empty;
      final selection = empty.toggleValue(95, 1202).toggleValue(2, 1310).toggleValue(95, 1201);
      expect(selection.queryParts(), [
        'attribute_value=2-1310',
        'attribute_value=95-1201',
        'attribute_value=95-1202',
      ]);
    });

    test('a doua apasare pe aceeasi valoare o scoate', () {
      final once = ProductFilterSelection.empty.toggleValue(95, 1201);
      expect(once.isSelected(95, 1201), isTrue);
      expect(once.toggleValue(95, 1201).isSelected(95, 1201), isFalse);
    });

    test('numarul de filtre active numara intervalul de pret o singura data', () {
      final selection = ProductFilterSelection.empty
          .toggleValue(95, 1201)
          .copyWith(minPrice: 10, maxPrice: 50);
      expect(selection.activeCount, 2);
    });

    test('sortarea nu se numara ca filtru si supravietuieste stergerii filtrelor', () {
      final selection = ProductFilterSelection.empty
          .toggleValue(95, 1201)
          .copyWith(sort: 'price_asc', minPrice: 5);
      expect(selection.activeCount, 2);
      final cleared = selection.cleared();
      expect(cleared.activeCount, 0);
      expect(cleared.sort, 'price_asc');
    });

    test('egalitate pe valoare, ca o selectie identica sa nu porneasca o cerere noua', () {
      final a = ProductFilterSelection.empty.toggleValue(95, 1201).toggleValue(2, 1310);
      final b = ProductFilterSelection.empty.toggleValue(2, 1310).toggleValue(95, 1201);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });


  group('glisorul de pret', () {
    // Catalogul real merge de la 2 la 322.500 lei: pe scara liniara tot ce cumpara
    // cineva de obicei statea inghesuit in primul milimetru de glisor.
    const min = 2.0;
    const max = 322500.0;

    test('capetele glisorului raman exact preturile trimise de server', () {
      expect(pricePosition(min, min, max), 0);
      expect(pricePosition(max, min, max), 1);
      expect(priceAtPosition(0, min, max), min);
      expect(priceAtPosition(1, min, max), max);
    });

    test('mijlocul glisorului cade in zona in care chiar sunt produse', () {
      final middle = priceAtPosition(0.5, min, max);
      expect(middle, greaterThan(500));
      expect(middle, lessThan(1200));
    });

    test('un sfert de glisor e deja sub o suta de lei', () {
      expect(priceAtPosition(0.25, min, max), lessThan(100));
    });

    test('pozitia si pretul sunt drumuri inverse', () {
      for (final price in [10.0, 150.0, 1500.0, 20000.0]) {
        final back = priceAtPosition(pricePosition(price, min, max), min, max);
        expect((back - price).abs() / price, lessThan(0.05));
      }
    });

    test('suma aleasa se rotunjeste la o treapta pe masura ei', () {
      expect(priceAtPosition(pricePosition(1247, min, max), min, max) % 100, 0);
      expect(priceAtPosition(pricePosition(47, min, max), min, max) % 1, 0);
    });

    test('un interval degenerat nu arunca', () {
      expect(pricePosition(5, 5, 5), 0);
      expect(priceAtPosition(0.5, 5, 5), isNotNaN);
    });
  });

  group('valorile unui atribut lung', () {
    List<AttributeFilterValue> values(int count) => [
          for (var i = 1; i <= count; i++) AttributeFilterValue(id: i, name: 'V$i'),
        ];

    test('o lista scurta se arata intreaga', () {
      final shown = visibleAttributeValues(values(5),
          expanded: false, isSelected: (_) => false);
      expect(shown, hasLength(5));
    });

    test('o lista lunga se taie, pana cere clientul tot', () {
      final all = values(20);
      expect(visibleAttributeValues(all, expanded: false, isSelected: (_) => false),
          hasLength(attributeValuesCollapsed));
      expect(visibleAttributeValues(all, expanded: true, isSelected: (_) => false),
          hasLength(20));
    });

    test('o valoare bifata din coada tine lista deschisa', () {
      // Altfel clientul ar avea un filtru activ pe care nu-l mai poate anula.
      final shown = visibleAttributeValues(values(20),
          expanded: false, isSelected: (id) => id == 17);
      expect(shown, hasLength(20));
    });
  });

  group('contract', () {
    test('fixture-ul de contract decodeaza in modelele de filtre', () {
      final raw = File('test/contract/products.json').readAsStringSync();
      final response = ProductsResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      expect(response.filters.attributes, hasLength(2));
      final brand = response.filters.attributes.first;
      expect(brand.name, 'Brand');
      expect(brand.displayType, 'radio');
      expect(brand.values.first.count, 1);
      expect(response.filters.price.min, 25.0);
      expect(response.filters.price.max, 330.0);
      expect(response.filters.price.usable, isTrue);
      expect(response.filters.sorts.map((s) => s.key),
          ['recommended', 'price_asc', 'price_desc', 'name_asc']);
      expect(response.filters.sorts.first.selected, isTrue);
    });

    test('un raspuns fara blocul filters nu arunca - filtrele raman goale', () {
      final response = ProductsResponse.fromJson(page());
      expect(response.filters.attributes, isEmpty);
      expect(response.filters.price.usable, isFalse);
    });
  });

  group('controller', () {
    test('filtrele ajung in query string, in ordinea asteptata', () async {
      transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
          ApiResponse(status: 200, json: page()));
      await notifier().ensureLoaded();

      transport.when(
        'GET',
        '/api/app/v1/products?attribute_value=95-1201&min_price=10.0&max_price=50.0&sort=price_asc&offset=0&limit=20',
        ApiResponse(status: 200, json: page(ids: [7], total: 1)),
      );
      await notifier().setFilters(ProductFilterSelection.empty
          .toggleValue(95, 1201)
          .copyWith(minPrice: 10, maxPrice: 50, sort: 'price_asc'));

      expect(container.read(catalogControllerProvider).value?.products.single.id, 7);
    });

    test('schimbarea categoriei sterge filtrele, dar pastreaza sortarea', () async {
      transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
          ApiResponse(status: 200, json: page()));
      await notifier().ensureLoaded();

      transport.when(
        'GET',
        '/api/app/v1/products?attribute_value=95-1201&sort=price_asc&offset=0&limit=20',
        ApiResponse(status: 200, json: page()),
      );
      await notifier()
          .setFilters(ProductFilterSelection.empty.toggleValue(95, 1201).copyWith(sort: 'price_asc'));

      // Un brand ales in Bracketi poate sa nu existe deloc in alta categorie; pastrat,
      // ar da o grila goala fara explicatie. Sortarea e o preferinta, nu un filtru.
      transport.when('GET', '/api/app/v1/products?category_id=12&sort=price_asc&offset=0&limit=20',
          ApiResponse(status: 200, json: page(ids: [3], total: 1)));
      await notifier().setCategory(12);

      final selection = container.read(catalogFilterSelectionProvider);
      expect(selection.attributeTokens, isEmpty);
      expect(selection.sort, 'price_asc');
      expect(container.read(catalogControllerProvider).value?.products.single.id, 3);
    });

    test('paginarea pastreaza filtrele active', () async {
      transport.when('GET', '/api/app/v1/products?offset=0&limit=20',
          ApiResponse(status: 200, json: page()));
      await notifier().ensureLoaded();

      transport.when('GET', '/api/app/v1/products?attribute_value=95-1201&offset=0&limit=20',
          ApiResponse(status: 200, json: page(ids: [1], total: 2)));
      await notifier().setFilters(ProductFilterSelection.empty.toggleValue(95, 1201));

      transport.when('GET', '/api/app/v1/products?attribute_value=95-1201&offset=1&limit=20',
          ApiResponse(status: 200, json: page(ids: [2], total: 2)));
      await notifier().loadMore();

      expect(container.read(catalogControllerProvider).value?.products.map((p) => p.id), [1, 2]);
    });

    test('filtrele primite de la server ajung in stare', () async {
      transport.when(
        'GET',
        '/api/app/v1/products?offset=0&limit=20',
        ApiResponse(
          status: 200,
          json: page(filters: {
            'attributes': [
              {
                'id': 95,
                'name': 'Brand',
                'display_type': 'radio',
                'values': [
                  {'id': 1201, 'name': 'Dynaflex', 'color': null, 'count': 3, 'selected': false},
                ],
              }
            ],
            'price': {'min': 10.0, 'max': 30.0, 'selected_min': null, 'selected_max': null},
            'sorts': [
              {'key': 'recommended', 'name': 'Recomandate', 'selected': true},
            ],
          }),
        ),
      );
      await notifier().ensureLoaded();

      final filters = container.read(catalogControllerProvider).value!.filters;
      expect(filters.attributes.single.values.single.count, 3);
      expect(filters.price.usable, isTrue);
      expect(filters.sorts.single.selected, isTrue);
    });
  });
}

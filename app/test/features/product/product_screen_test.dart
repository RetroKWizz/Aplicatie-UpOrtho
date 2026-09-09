import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/design_system/widgets/benefit_list.dart';
import 'package:uportho_app/design_system/widgets/brand_card.dart';
import 'package:uportho_app/design_system/widgets/description_view.dart';
import 'package:uportho_app/design_system/widgets/document_list.dart';
import 'package:uportho_app/design_system/widgets/image_gallery.dart';
import 'package:uportho_app/design_system/widgets/price_tier_table.dart';
import 'package:uportho_app/design_system/widgets/product_card.dart';
import 'package:uportho_app/design_system/widgets/variant_order_table.dart';
import 'package:uportho_app/design_system/widgets/variant_picker.dart';
import 'package:uportho_app/features/product/product_controller.dart';
import 'package:uportho_app/features/product/product_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

/// Transport care tine raspunsul in loc (un `Completer` per apel), ca testul sa
/// poata inspecta ecranul EXACT in timp ce cererea e in aer.
class HeldTransport implements ApiTransport {
  final List<RecordedCall> calls = [];
  final List<Completer<ApiResponse>> pending = [];

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) {
    calls.add(RecordedCall(method, path, body));
    final completer = Completer<ApiResponse>();
    pending.add(completer);
    return completer.future;
  }
}

/// Un pret in forma de contract. Toate sirurile vin de la server - ecranul nu
/// formateaza si nu calculeaza nimic pe bani.
Map<String, dynamic> priceJson({
  double amount = 25.0,
  String formatted = '25,00 lei',
  double? listAmount,
  String? listFormatted,
  int? discountPct,
}) =>
    {
      'amount': amount,
      'currency': 'RON',
      'formatted': formatted,
      'with_vat': true,
      'list_amount': listAmount,
      'list_formatted': listFormatted,
      'discount_pct': discountPct,
    };

/// Produsul "sarac": fara variante, fara praguri, fara descriere - forma in care
/// arata majoritatea catalogului real (354 din 619 produse n-au variante, 214 n-au
/// praguri, 14 n-au descriere).
Map<String, dynamic> bareProductJson() => {
      'id': 101,
      'variant_id': null,
      'name': 'Cleste simplu fara variante',
      'default_code': null,
      'badge': null,
      'images': <Map<String, dynamic>>[],
      'price': priceJson(),
      'club_price': null,
      'price_tables': <Map<String, dynamic>>[],
      'variants': null,
      'specs': <Map<String, dynamic>>[],
      'description': <Map<String, dynamic>>[],
      'availability': null,
      'rating': {'average': 0.0, 'count': 0},
      'reviews': <Map<String, dynamic>>[],
      'similar': <Map<String, dynamic>>[],
      'benefits': <Map<String, dynamic>>[],
    };

/// Produsul "bogat": fixture-ul de contract, cu recenzii numarate (in fixture
/// `rating.count` e 0, iar randul de stele nu se deseneaza fara recenzii).
Map<String, dynamic> fullProductJson() {
  final contract = jsonDecode(File('test/contract/product_detail.json').readAsStringSync())
      as Map<String, dynamic>;
  return {...contract, 'rating': {'average': 4.5, 'count': 22}};
}

/// Un tabel de pret in forma de contract: titlul si nota vin de la server, ca si
/// sumele.
Map<String, dynamic> priceTableJson({
  String? title,
  List<Map<String, dynamic>> note = const [],
  required List<Map<String, dynamic>> entries,
}) =>
    {'title': title, 'note': note, 'entries': entries};

Map<String, dynamic> tierJson(int minQty, String label, Map<String, dynamic> price) =>
    {'min_qty': minQty, 'label': label, 'price': price};

void main() {
  Future<ProviderContainer> pumpProduct(
    WidgetTester tester, {
    required FakeTransport transport,
    int productId = 101,
    Size? surface,
  }) async {
    if (surface != null) {
      // Ecran inalt de test: `ListView` construieste lenes, iar sectiunile de jos
      // (descriere, specificatii, recenzii, similare) nici n-ar exista in arbore
      // pe 600x800. Verificarea ordinii are nevoie de toate deodata.
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: ProductScreen(productId: productId)),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    return container;
  }

  testWidgets('produsul fara variante, fara praguri si fara descriere nu deseneaza sectiuni goale',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: bareProductJson()));

    await pumpProduct(tester, transport: transport);

    // Ce trebuie sa se vada: titlul si pretul, exact ca pe site.
    expect(find.text('Cleste simplu fara variante'), findsOneWidget);
    expect(find.text('25,00 lei'), findsOneWidget);

    // Ce NU are voie sa apara: nici widgetul gol, nici titlul lui de sectiune.
    expect(find.byType(ImageGallery), findsNothing);
    expect(find.byType(PriceTierTable), findsNothing);
    expect(find.byType(VariantPicker), findsNothing);
    expect(find.byType(DescriptionView), findsNothing);
    expect(find.byType(BrandCard), findsNothing);
    expect(find.byType(ProductCard), findsNothing);
    for (final title in const [
      'Pret pe cantitate',
      'Pret Ortho Club',
      'Descriere',
      'Specificatii',
      'Documente',
      'Recenzii',
      'Produse similare',
    ]) {
      expect(find.text(title), findsNothing, reason: 'sectiunea "$title" nu are date');
    }
    expect(find.textContaining('Cod:'), findsNothing);
  });

  testWidgets('tabelele de pret se deseneaza in ordinea si cu titlurile primite de la server',
      (tester) async {
    // Site-ul poate arata unul, doua sau niciun tabel, iar al doilea titlu e un nume
    // de campanie. Ecranul nu stie niciun titlu si nu presupune cate tabele sunt: le
    // deseneaza pe cele primite, in ordinea primita.
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/products/101',
      ApiResponse(status: 200, json: {
        ...bareProductJson(),
        'price_tables': [
          priceTableJson(title: 'Pret public', entries: [
            tierJson(1, '1+', priceJson()),
            tierJson(5, '5+', priceJson(amount: 20.0, formatted: '20,00 lei')),
          ]),
          priceTableJson(title: 'Campanie Toamna 2026', entries: [
            tierJson(1, '1+', priceJson(amount: 18.0, formatted: '18,00 lei')),
          ]),
        ],
      }),
    );

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.byType(PriceTierTable), findsNWidgets(2));
    expect(find.text('Pret public'), findsOneWidget);
    expect(find.text('Campanie Toamna 2026'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Campanie Toamna 2026')).dy,
        greaterThan(tester.getTopLeft(find.text('Pret public')).dy));
    expect(find.text('5+'), findsOneWidget);
    expect(find.text('20,00 lei'), findsOneWidget);
    expect(find.text('18,00 lei'), findsOneWidget);
  });

  testWidgets('nota unui tabel se afiseaza sub titlul lui', (tester) async {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/products/101',
      ApiResponse(status: 200, json: {
        ...bareProductJson(),
        'price_tables': [
          priceTableJson(
            title: 'Pret Ortho Club',
            note: [
              {
                'type': 'paragraph',
                'spans': [
                  {'text': 'Reducerea se aplica de la 5 bucati.', 'bold': false, 'italic': false},
                ],
              },
            ],
            entries: [tierJson(5, '5+', priceJson(amount: 20.0, formatted: '20,00 lei'))],
          ),
        ],
      }),
    );

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.text('Reducerea se aplica de la 5 bucati.'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Reducerea se aplica de la 5 bucati.')).dy,
        greaterThan(tester.getTopLeft(find.text('Pret Ortho Club')).dy));
  });

  testWidgets('un tabel fara titlu se deseneaza doar cu randurile lui', (tester) async {
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/products/101',
      ApiResponse(status: 200, json: {
        ...bareProductJson(),
        'price_tables': [
          priceTableJson(entries: [tierJson(3, '3+', priceJson(amount: 20.0, formatted: '20,00 lei'))]),
        ],
      }),
    );

    await pumpProduct(tester, transport: transport);

    expect(find.byType(PriceTierTable), findsOneWidget);
    expect(find.text('3+'), findsOneWidget);
    expect(find.text('20,00 lei'), findsOneWidget);
  });

  testWidgets('produsul complet deseneaza sectiunile in ordinea de pe site', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    double top(Finder finder) => tester.getTopLeft(finder).dy;

    final order = <String, double>{
      'galerie': top(find.byType(ImageGallery)),
      'badge': top(find.text('Nou')),
      'titlu': top(find.text('Cleste Tie Back mare (.016 - .021x.025) Ixion')),
      'recenzii (stele)': top(find.text('22 recenzii')),
      'pret': top(find.text('1.120,00 lei').first),
      'primul tabel de pret': top(find.text('Pret pe cantitate')),
      'al doilea tabel de pret': top(find.text('Campanie Toamna 2026')),
      'variante': top(find.byType(VariantOrderTable)),
      'disponibilitate': top(find.text('Precomanda. Livrare incepand cu 1 August')),
      'buton cos': top(find.widgetWithText(FilledButton, 'Adauga in cos')),
      'brand': top(find.byType(BrandCard)),
      'beneficii': top(find.text('Livrare gratuita')),
      'cod produs': top(find.text('Cod: IX954')),
      'descriere': top(find.text('Descriere')),
      'specificatii': top(find.text('Specificatii')),
      'documente': top(find.text('Documente')),
      'recenzii': top(find.text('Recenzii')),
      'similare': top(find.text('Produse similare')),
    };

    final names = order.keys.toList();
    for (var index = 1; index < names.length; index++) {
      expect(order[names[index]]!, greaterThan(order[names[index - 1]]!),
          reason: '"${names[index]}" trebuie sa fie sub "${names[index - 1]}"');
    }

    // Pretul taiat, procentul si mentiunea de taxe, toate din contract.
    // Pretul de lista apare taiat langa pretul curent SI ca prag "1+" in tabel -
    // amandoua vin ca siruri gata formatate de la server.
    expect(find.text('1.399,99 lei'), findsNWidgets(2));
    expect(find.text('-20%'), findsOneWidget);
    expect(find.text('Taxe incluse'), findsOneWidget);
    // Descrierea si specificatiile chiar au continut, nu doar titluri.
    expect(find.text('Cleste Tie Back pentru arcuri groase'), findsOneWidget);
    // Brandul apare de doua ori, ca pe site: in chenarul lui si in specificatii.
    expect(find.text('DB Orthodontics'), findsNWidgets(2));
    expect(find.text('Cleste Tie Back mic Ixion'), findsOneWidget);
  });

  testWidgets('butonul de cos e dezactivat si spune ca vine la pasul urmator', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: bareProductJson()));

    await pumpProduct(tester, transport: transport);

    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Adauga in cos'));
    expect(button.onPressed, isNull, reason: 'cosul vine in Faza 3');
    expect(find.text('Disponibil la pasul urmator'), findsOneWidget);
  });

  testWidgets('galeria primeste URL-uri absolute si cookie-ul de sesiune', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
      imageHeadersProvider.overrideWith((ref) async => const {'Cookie': 'session_id=abc'}),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProductScreen(productId: 101)),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    final gallery = tester.widget<ImageGallery>(find.byType(ImageGallery));
    expect(gallery.items.first.imageUrl, 'http://x/api/app/v1/products/101/gallery/0?unique=3a1f9c2');
    // Rutele de galerie sunt autentificate: fara header, pozele intorc 401.
    expect(gallery.httpHeaders, const {'Cookie': 'session_id=abc'});
    // Intrarea video isi pastreaza link-ul extern.
    expect(gallery.items.last.videoUrl, 'https://www.youtube.com/watch?v=xxxx');
  });

  testWidgets('alegerea unei variante recere produsul si actualizeaza pretul si codul',
      (tester) async {
    // Selectorul se deseneaza doar cand serverul NU trimite randuri de varianta
    // (produs cu o singura varianta activa, dar cu linii de atribut): cand exista
    // randuri, tabelul le inlocuieste.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: {...fullProductJson(), 'variant_rows': <dynamic>[]}));
    transport.when(
      'GET',
      '/api/app/v1/products/101?values=1358',
      ApiResponse(
        status: 200,
        json: {
          ...fullProductJson(),
          'variant_rows': <dynamic>[],
          'variant_id': 502,
          'default_code': 'IX955',
          'price': priceJson(amount: 990.0, formatted: '990,00 lei'),
        },
      ),
    );

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.text('Cod: IX954'), findsOneWidget);
    await tester.tap(find.text('Mic'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    // Ecranul trimite combinatia primita de la server pentru valoarea apasata.
    expect(transport.calls.last.path, '/api/app/v1/products/101?values=1358');
    expect(find.text('990,00 lei'), findsWidgets);
    expect(find.text('Cod: IX955'), findsOneWidget);
    // Ecranul nu s-a demontat cat timp se schimba varianta.
    expect(find.text('Cleste Tie Back mare (.016 - .021x.025) Ixion'), findsOneWidget);
  });

  testWidgets('pe un ecran ingust, cu texte romanesti lungi, nimic nu depaseste latimea',
      (tester) async {
    const longName =
        'Cleste Tie Back mare pentru arcuri groase (.016 - .021x.025) Ixion, cu falci zimtate';
    final transport = FakeTransport();
    transport.when(
      'GET',
      '/api/app/v1/products/101',
      ApiResponse(status: 200, json: {
        ...fullProductJson(),
        'name': longName,
        'default_code': 'IX954-MARE-ARGINTIU-EDITIE-LIMITATA',
        'price': priceJson(
          amount: 11211.5,
          formatted: '11.211,50 lei',
          listAmount: 13999.99,
          listFormatted: '13.999,99 lei',
          discountPct: 20,
        ),
        'availability': {
          'message': 'Precomanda. Livrare incepand cu 1 August, in limita stocului disponibil.',
          'in_stock': true,
        },
        'specs': [
          {'name': 'Denumire comerciala a producatorului', 'value': 'DB Orthodontics Limited, Marea Britanie'},
        ],
      }),
    );

    // 320px: cel mai ingust telefon pe care il tintim. Aici au aparut si data
    // trecuta depasirile de latime (RenderFlex overflow).
    await pumpProduct(tester, transport: transport, surface: const Size(320, 4000));

    expect(tester.takeException(), isNull);
    expect(find.text(longName), findsOneWidget);
    expect(find.text('11.211,50 lei'), findsOneWidget);
  });

  testWidgets('eroarea serverului arata mesajul si un buton de reincercare', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', const ApiResponse(status: 404, json: {
      'error': {'code': 'not_found', 'message': 'Produsul nu exista.', 'details': {}}
    }));

    await pumpProduct(tester, transport: transport);

    expect(find.text('Produsul nu exista.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Reincearca'), findsOneWidget);
  });

  // --- tabelul de comanda pe variante ----------------------------------------

  testWidgets('produsul cu mai multe variante arata tabelul, nu selectorul de atribute',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.byType(VariantOrderTable), findsOneWidget);
    expect(find.byType(VariantPicker), findsNothing,
        reason: 'randul fiecarei variante face selectorul redundant');
    // Cate un rand per varianta, cu atributele, codul si pretul din contract.
    expect(find.text('Marime: Mare'), findsOneWidget);
    expect(find.text('Marime: Mic'), findsOneWidget);
    expect(find.text('Cod: IX954-M'), findsOneWidget);
    expect(find.text('990,00 lei'), findsOneWidget);
    // Cantitatile pornesc de la zero, dar sumele de zero vin tot de la server (in
    // detaliul produsului): tabelul arata "0,00 lei" din primul cadru, fara sa mai
    // ceara nimic si fara ca ecranul sa formateze el vreo suma.
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('0,00 lei'), findsNWidgets(3),
        reason: 'subtotalul fiecarui rand si totalul');
    expect(find.text(VariantOrderTable.missingAmount), findsNothing);
    expect(transport.calls.where((call) => call.method == 'POST'), isEmpty,
        reason: 'sumele de pornire vin cu detaliul, fara un tur suplimentar la server');
  });

  testWidgets('fara sumele de pornire de la server, tabelul lasa liniuta, nu "0,00 lei"',
      (tester) async {
    // Un server care nu trimite inca `subtotal`/`variant_total` (versiune mai veche):
    // ecranul NU are voie sa scrie el zero - nu formateaza bani (CLAUDE.md).
    final json = fullProductJson();
    json['variant_total'] = null;
    json['variant_rows'] = [
      for (final row in json['variant_rows'] as List)
        {...row as Map<String, dynamic>}..remove('subtotal'),
    ];
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101', ApiResponse(status: 200, json: json));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.text(VariantOrderTable.missingAmount), findsWidgets);
  });

  testWidgets('o cantitate schimbata cere preturile de la server si actualizeaza totalul',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));
    transport.when(
      'POST',
      '/api/app/v1/products/101/prices',
      ApiResponse(status: 200, json: {
        'lines': [
          {
            'variant_id': 501,
            'qty': 5,
            // Pretul unitar de la 5 bucati: pragul listei de pret a coborat pretul.
            'price': priceJson(amount: 1000.0, formatted: '1.000,00 lei'),
            'subtotal': priceJson(amount: 5000.0, formatted: '5.000,00 lei'),
          },
          {
            'variant_id': 502,
            'qty': 0,
            'price': priceJson(amount: 990.0, formatted: '990,00 lei'),
            'subtotal': priceJson(amount: 0.0, formatted: '0,00 lei'),
          },
        ],
        'total': priceJson(amount: 5000.0, formatted: '5.000,00 lei'),
      }),
    );

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    for (var tap = 0; tap < 5; tap++) {
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
    }
    // O singura cerere pentru cele cinci apasari (debounce).
    await tester.pump(quantityDebounce + const Duration(milliseconds: 50));
    await tester.pump();

    final posts = transport.calls.where((call) => call.method == 'POST').toList();
    expect(posts.length, 1);
    expect((posts.single.body!['lines'] as List).first, {'variant_id': 501, 'qty': 5});

    // Toate cifrele de pe ecran sunt cele intoarse de server.
    expect(find.text('1.000,00 lei'), findsOneWidget);
    expect(find.text('5.000,00 lei'), findsNWidgets(2), reason: 'subtotalul randului si totalul');
    expect(find.text('0,00 lei'), findsOneWidget);
  });

  testWidgets('cat timp preturile se recalculeaza, cifrele dinainte raman pe ecran',
      (tester) async {
    // Transport tinut in loc: cu raspunsuri imediate, momentul "cererea e in aer"
    // trece intre doua cadre si nu se poate observa.
    final transport = HeldTransport();
    tester.view.physicalSize = const Size(500, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProductScreen(productId: 101)),
    ));
    transport.pending.last.complete(ApiResponse(status: 200, json: fullProductJson()));
    await tester.pumpAndSettle();

    Map<String, dynamic> pricesJson(int qty, String subtotal) => {
          'lines': [
            {
              'variant_id': 501,
              'qty': qty,
              'price': priceJson(amount: 1120.0, formatted: '1.120,00 lei'),
              'subtotal': priceJson(amount: 1120.0, formatted: subtotal),
            },
          ],
          'total': priceJson(amount: 1120.0, formatted: subtotal),
        };

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump(quantityDebounce + const Duration(milliseconds: 50));
    transport.pending.last.complete(ApiResponse(status: 200, json: pricesJson(1, '1.120,00 lei')));
    await tester.pumpAndSettle();
    expect(find.text('1.120,00 lei'), findsWidgets);

    // A doua apasare: cererea e in aer si nu a raspuns inca.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump(quantityDebounce + const Duration(milliseconds: 50));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('1.120,00 lei'), findsWidgets,
        reason: 'tabelul nu are voie sa se goleasca in timpul cererii');
    expect(find.text('2'), findsOneWidget, reason: 'steperul raspunde pe loc');

    transport.pending.last.complete(ApiResponse(status: 200, json: pricesJson(2, '2.240,00 lei')));
    await tester.pumpAndSettle();
    expect(find.text('2.240,00 lei'), findsNWidgets(2), reason: 'subtotalul randului si totalul');
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('documentele produsului apar sub titlul Documente, cu URL absolut',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.text('Documente'), findsOneWidget);
    expect(find.text('Fisa tehnica.pdf'), findsOneWidget);

    // URL-ul e absolut: documentul se deschide in afara aplicatiei, unde o cale
    // relativa n-ar insemna nimic. E ruta standard a Odoo pentru fisier.
    final list = tester.widget<DocumentList>(find.byType(DocumentList));
    expect(list.items.single.url, 'http://x/web/content/4821?download=true');
  });

  testWidgets('documentele stau intre specificatii si recenzii, ca pe site',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: {...fullProductJson(), 'rating': {'average': 5.0, 'count': 1}}));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    final specs = tester.getTopLeft(find.text('Specificatii')).dy;
    final documents = tester.getTopLeft(find.text('Documente')).dy;
    final reviews = tester.getTopLeft(find.text('Recenzii')).dy;
    expect(documents, greaterThan(specs));
    expect(reviews, greaterThan(documents));
  });

  testWidgets('chenarul de brand arata numele si descrierea, deasupra descrierii produsului',
      (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.byType(BrandCard), findsOneWidget);
    final card = tester.widget<BrandCard>(find.byType(BrandCard));
    expect(card.name, 'DB Orthodontics');
    expect(card.description.single.spans.single.text,
        'Producator britanic de produse ortodontice.');
    // Logoul e o ruta autentificata: URL absolut plus headerele de imagine.
    expect(card.logoUrl, 'http://x/api/app/v1/products/101/brand/logo?unique=7e2b4c1');

    expect(tester.getTopLeft(find.text('Descriere')).dy,
        greaterThan(tester.getTopLeft(find.byType(BrandCard)).dy));
  });

  testWidgets('brandul ramane si in tabelul de specificatii', (tester) async {
    // Site-ul il arata in amandoua locurile.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.text('Specificatii'), findsOneWidget);
    expect(find.text('DB Orthodontics'), findsNWidgets(2),
        reason: 'o data in chenarul de brand, o data in specificatii');
  });

  testWidgets('fara brand, chenarul lipseste complet', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: {...fullProductJson(), 'brand': null}));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.byType(BrandCard), findsNothing);
  });

  testWidgets('beneficiul cu logo incarcat in Odoo il arata pe el, cu URL absolut',
      (tester) async {
    // Ce se schimba din Odoo fara release de aplicatie: un curier nou, alt
    // procesator de plati.
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    final list = tester.widget<BenefitList>(find.byType(BenefitList));
    final withImage = list.items.firstWhere((item) => item.imageUrl != null);
    expect(withImage.title, 'Livrare gratuita');
    expect(withImage.imageUrl, 'http://x/api/app/v1/benefits/3/image?unique=b19f0d4');

    // Restul raman pe iconita.
    expect(list.items.where((item) => item.imageUrl == null), hasLength(3));
  });

  testWidgets('fara beneficii, blocul lipseste complet', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: {...fullProductJson(), 'benefits': <dynamic>[]}));

    await pumpProduct(tester, transport: transport, surface: const Size(500, 4000));

    expect(find.byType(BenefitList), findsNothing);
  });
}

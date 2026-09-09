import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/design_system/widgets/description_view.dart';
import 'package:uportho_app/design_system/widgets/image_gallery.dart';
import 'package:uportho_app/design_system/widgets/price_tier_table.dart';
import 'package:uportho_app/design_system/widgets/product_card.dart';
import 'package:uportho_app/design_system/widgets/variant_picker.dart';
import 'package:uportho_app/features/product/product_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

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
      'tiers': <Map<String, dynamic>>[],
      'club_tiers': <Map<String, dynamic>>[],
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
Map<String, dynamic> fullProductJson() => {
      ...jsonDecode(File('test/contract/product_detail.json').readAsStringSync())
          as Map<String, dynamic>,
      'rating': {'average': 4.5, 'count': 22},
    };

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
    expect(find.byType(ProductCard), findsNothing);
    for (final title in const [
      'Pret pe cantitate',
      'Pret Ortho Club',
      'Descriere',
      'Specificatii',
      'Recenzii',
      'Produse similare',
    ]) {
      expect(find.text(title), findsNothing, reason: 'sectiunea "$title" nu are date');
    }
    expect(find.textContaining('Cod:'), findsNothing);
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
      'praguri': top(find.text('Pret pe cantitate')),
      'praguri club': top(find.text('Pret Ortho Club')),
      'variante': top(find.byType(VariantPicker)),
      'disponibilitate': top(find.text('Precomanda. Livrare incepand cu 1 August')),
      'buton cos': top(find.widgetWithText(FilledButton, 'Adauga in cos')),
      'beneficii': top(find.text('Livrare gratuita')),
      'cod produs': top(find.text('Cod: IX954')),
      'descriere': top(find.text('Descriere')),
      'specificatii': top(find.text('Specificatii')),
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
    expect(find.text('DB Orthodontics'), findsOneWidget);
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
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/products/101',
        ApiResponse(status: 200, json: fullProductJson()));
    transport.when(
      'GET',
      '/api/app/v1/products/101?variant_id=1358',
      ApiResponse(
        status: 200,
        json: {
          ...fullProductJson(),
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

    expect(transport.calls.last.path, '/api/app/v1/products/101?variant_id=1358');
    expect(find.text('990,00 lei'), findsWidgets);
    expect(find.text('Cod: IX955'), findsOneWidget);
    // Ecranul nu s-a demontat cat timp se schimba varianta.
    expect(find.text('Cleste Tie Back mare (.016 - .021x.025) Ixion'), findsOneWidget);
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
}

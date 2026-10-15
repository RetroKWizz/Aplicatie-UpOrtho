import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/account_screen.dart';
import 'package:uportho_app/features/account/invoices_screen.dart';
import 'package:uportho_app/features/account/order_detail_screen.dart';
import 'package:uportho_app/features/product/document_controller.dart';
import 'package:uportho_app/features/product/document_files.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/contract/$name').readAsStringSync()) as Map<String, dynamic>;

List<dynamic> listFixture(String name) =>
    jsonDecode(File('test/contract/$name').readAsStringSync()) as List<dynamic>;

/// Depozitul, inlocuit cu unul care doar compune calea: testele de widget ruleaza
/// intr-o zona de timp fals, unde un `Directory.create` real nu s-ar termina.
class _PathOnlyStorage implements DocumentStorage {
  @override
  Future<File> fileFor({required String url, required String fileName}) async =>
      File('/tmp/$fileName');
}

class _RecordingOpener implements DocumentOpener {
  final List<String> opened = [];

  @override
  Future<DocumentOpenOutcome> open(String path) async {
    opened.add(path);
    return DocumentOpenOutcome.opened;
  }
}

void main() {
  FakeTransport accountTransport() {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/orders?offset=0&limit=20',
        ApiResponse(status: 200, json: fixture('orders.json')));
    transport.when('GET', '/api/app/v1/invoices?offset=0&limit=20',
        ApiResponse(status: 200, json: fixture('invoices.json')));
    transport.when('GET', '/api/app/v1/addresses',
        ApiResponse(status: 200, json: listFixture('addresses.json')));
    transport.when('GET', '/api/app/v1/account/profile',
        ApiResponse(status: 200, json: fixture('profile.json')));
    transport.when('GET', '/api/app/v1/loyalty',
        ApiResponse(status: 200, json: listFixture('loyalty.json')));
    transport.when('GET', '/api/app/v1/payment-methods',
        ApiResponse(status: 200, json: listFixture('payment_methods.json')));
    return transport;
  }

  /// Ecranele de cont sunt mai inalte decat suprafata implicita de test (800px):
  /// `ListView` construieste lenes, iar sectiunile de jos n-ar exista in arbore.
  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget screen,
    FakeTransport transport, {
    bool fakeDocuments = false,
    DocumentOpener? opener,
    Size surface = const Size(500, 2000),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Sesiune salvata plus `/me`: ecranul de cont are acum doua fete, iar fara un cont
    // restaurat arata invitatia de vizitator. Testele de aici verifica fata de CLIENT.
    transport.when('GET', '/api/app/v1/me', const ApiResponse(status: 200, json: {
      'user': {'id': 1, 'name': 'Client Test', 'email': 'client@uportho.ro', 'partner_id': 7}
    }));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(
          transport, InMemorySessionStore(initial: 'sesiune-de-test'), baseUrl: 'http://x')),
      if (fakeDocuments) documentStorageProvider.overrideWithValue(_PathOnlyStorage()),
      if (fakeDocuments) documentOpenerProvider.overrideWithValue(opener ?? _RecordingOpener()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: screen),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    return container;
  }

  /// Numarul scris in dreapta unui rand din meniu, cautat in chiar randul lui: un
  /// `find.text('1')` pe tot ecranul ar trece si daca numarul ar sta pe alt rand.
  Finder countOf(String label, String count) => find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
        matching: find.text(count),
      );

  testWidgets('contul arata cate comenzi, facturi si adrese are', (tester) async {
    await pump(tester, const AccountScreen(), accountTransport());

    expect(countOf('Comenzi', '1'), findsOneWidget);
    expect(countOf('Facturi', '1'), findsOneWidget);
    expect(countOf('Adrese', '1'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Datele contului'), findsOneWidget);
  });

  testWidgets('abonamentul valabil arata data si lista de preturi, din Odoo',
      (tester) async {
    await pump(tester, const AccountScreen(), accountTransport());

    expect(find.text('ORTHO CLUB'), findsOneWidget);
    expect(find.text('Activ'), findsOneWidget);
    expect(find.text('Membru pana la'), findsOneWidget);
    expect(find.text('31 decembrie 2026'), findsOneWidget);
    expect(find.text('Lista de preturi Ortho Club 2026 (RON)'), findsOneWidget);
  });

  testWidgets('abonamentul expirat o spune, cu data lui', (tester) async {
    // Serverul decide daca mai e membru - bifa din Odoo nu se stinge cand trece
    // data, iar aplicatia nu compara ea datele.
    final profile = Map<String, dynamic>.from(fixture('profile.json'));
    profile['club'] = {
      'member': false,
      'end_date': '2025-12-31',
      'end_date_label': '31 decembrie 2025',
      'pricelist': 'Lista de preturi publica 2026',
    };
    final transport = accountTransport();
    transport.when('GET', '/api/app/v1/account/profile',
        ApiResponse(status: 200, json: profile));

    await pump(tester, const AccountScreen(), transport);

    expect(find.text('Expirat'), findsOneWidget);
    expect(find.text('Abonamentul tau Ortho Club a expirat la 31 decembrie 2025.'),
        findsOneWidget);
    expect(find.text('Membru pana la'), findsNothing);
  });

  testWidgets('un cont fara abonament nu vede nimic despre club', (tester) async {
    final profile = Map<String, dynamic>.from(fixture('profile.json'));
    profile['club'] = null;
    final transport = accountTransport();
    transport.when('GET', '/api/app/v1/account/profile',
        ApiResponse(status: 200, json: profile));

    await pump(tester, const AccountScreen(), transport);

    expect(find.text('ORTHO CLUB'), findsNothing);
    expect(find.text('Expirat'), findsNothing);
  });

  testWidgets('cardurile si voucherele apar cu punctele lor, formatate de server',
      (tester) async {
    await pump(tester, const AccountScreen(), accountTransport());

    expect(find.text('Carduri si vouchere'), findsOneWidget);
    expect(find.text('Ortho Club 2026'), findsOneWidget);
    expect(find.text('150 puncte'), findsOneWidget);
    expect(find.text('250,00 lei'), findsOneWidget);
  });

  testWidgets('fara carduri, sectiunea de fidelitate lipseste complet', (tester) async {
    final transport = accountTransport();
    transport.when(
        'GET', '/api/app/v1/loyalty', const ApiResponse(status: 200, json: <dynamic>[]));

    await pump(tester, const AccountScreen(), transport);

    expect(find.text('Carduri si vouchere'), findsNothing);
  });

  testWidgets('o lista picata lasa randul fara numar, nu arunca ecranul', (tester) async {
    final transport = accountTransport();
    transport.when(
      'GET',
      '/api/app/v1/invoices?offset=0&limit=20',
      const ApiResponse(status: 500, json: {
        'error': {'code': 'internal_error', 'message': 'Facturile nu merg acum.', 'details': {}}
      }),
    );

    await pump(tester, const AccountScreen(), transport);

    // Randul exista si duce mai departe; doar numarul lipseste, pentru ca nu-l stim.
    expect(find.text('Facturi'), findsOneWidget);
    expect(countOf('Facturi', '1'), findsNothing);
    expect(countOf('Comenzi', '1'), findsOneWidget);
    expect(find.text('ORTHO CLUB'), findsOneWidget);
  });

  testWidgets('detaliul comenzii arata liniile, totalurile si adresele', (tester) async {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/orders/5001',
        ApiResponse(status: 200, json: fixture('order.json')));

    await pump(tester, const OrderDetailScreen(orderId: 5001), transport);

    expect(find.text('Confirmata'), findsOneWidget);
    expect(find.text('Bracket metalic Roth .022'), findsOneWidget);
    expect(find.text('280,00 lei'), findsWidgets);
    expect(find.text('Adresa de livrare'), findsOneWidget);
    expect(find.text('FACT/2026/0042'), findsOneWidget);
  });

  testWidgets('factura se descarca prin sesiunea aplicatiei si se deschide local',
      (tester) async {
    // Ruta e autentificata: un URL aruncat in browserul telefonului ar primi 401.
    final transport = accountTransport();
    transport.whenDownload('http://x/api/app/v1/invoices/8001/pdf',
        bytes: [37, 80, 68, 70], writeFile: false);
    final opener = _RecordingOpener();

    await pump(tester, const InvoicesScreen(), transport,
        fakeDocuments: true, opener: opener);

    await tester.tap(find.text('FACT/2026/0042'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(transport.downloads.single.url, 'http://x/api/app/v1/invoices/8001/pdf');
    expect(opener.opened.single, contains('FACT'));
  });

  testWidgets('o descarcare esuata lasa un mesaj, nu o apasare in gol', (tester) async {
    final transport = accountTransport();
    transport.whenDownload(
      'http://x/api/app/v1/invoices/8001/pdf',
      response: const ApiResponse(status: 404, json: {
        'error': {'code': 'not_found', 'message': 'Factura nu exista.', 'details': {}}
      }),
      writeFile: false,
    );

    await pump(tester, const InvoicesScreen(), transport, fakeDocuments: true);

    await tester.tap(find.text('FACT/2026/0042'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('Factura nu exista.'), findsOneWidget);
  });

  testWidgets('cardurile salvate apar cu numarul lor si se deschid', (tester) async {
    await pump(tester, const AccountScreen(), accountTransport());

    expect(countOf('Cardurile mele', '1'), findsOneWidget);
  });

  testWidgets('fara cont, tabul Cont arata invitatia, nu randuri goale', (tester) async {
    // Un vizitator care apasa "Contul meu" trebuie sa gaseasca aici cele doua drumuri,
    // nu un ecran de cont gol cu randuri care nu duc nicaieri.
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(FakeTransport(), InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Intra in cont'), findsOneWidget);
    expect(find.text('Creeaza cont'), findsOneWidget);
  });
}

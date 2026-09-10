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
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
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

  testWidgets('contul arata comenzile, facturile si adresele', (tester) async {
    await pump(tester, const AccountScreen(), accountTransport());

    expect(find.text('S12345'), findsOneWidget);
    expect(find.text('FACT/2026/0042'), findsOneWidget);
    expect(find.text('Cabinet Dentar Exemplu SRL'), findsOneWidget);
    expect(find.text('304,99 lei'), findsOneWidget);
  });

  testWidgets('o sectiune picata nu arunca tot ecranul pe eroare', (tester) async {
    final transport = accountTransport();
    transport.when(
      'GET',
      '/api/app/v1/invoices?offset=0&limit=20',
      const ApiResponse(status: 500, json: {
        'error': {'code': 'internal_error', 'message': 'Facturile nu merg acum.', 'details': {}}
      }),
    );

    await pump(tester, const AccountScreen(), transport);

    expect(find.text('Facturile nu merg acum.'), findsOneWidget);
    // Comenzile si adresele raman pe ecran.
    expect(find.text('S12345'), findsOneWidget);
    expect(find.text('Cabinet Dentar Exemplu SRL'), findsOneWidget);
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
}

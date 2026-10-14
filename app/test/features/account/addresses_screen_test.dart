import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/addresses_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  List<dynamic> addressesFixture() =>
      jsonDecode(File('test/contract/addresses.json').readAsStringSync()) as List<dynamic>;

  Future<void> pump(WidgetTester tester, List<dynamic> addresses) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final transport = FakeTransport();
    transport.when(
        'GET', '/api/app/v1/addresses', ApiResponse(status: 200, json: addresses));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AddressesScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('adresa buna la amandoua apare in ambele liste, cu ambele etichete',
      (tester) async {
    // Partenerul principal al contului e si de facturare, si de livrare, deci intra
    // in amandoua listele - ca pe site. Ca sa nu para o dublura, titlul listei spune
    // unde esti, iar etichetele spun la ce mai e buna adresa.
    await pump(tester, addressesFixture());

    expect(find.text('Adrese de facturare'), findsOneWidget);
    expect(find.text('Adrese de livrare'), findsOneWidget);
    expect(find.text('Cabinet Dentar Exemplu SRL'), findsNWidgets(2));
    expect(find.text('Facturare'), findsNWidgets(2));
    expect(find.text('Livrare'), findsNWidgets(2));
  });

  testWidgets('o adresa doar de livrare nu apare la facturare', (tester) async {
    final address = Map<String, dynamic>.from(addressesFixture().single as Map<String, dynamic>);
    address['name'] = 'Cabinet Test Livrare';
    address['for_billing'] = false;

    await pump(tester, [address]);

    // Lista de facturare ramane goala, deci nici titlul ei nu se deseneaza.
    expect(find.text('Adrese de facturare'), findsNothing);
    expect(find.text('Adrese de livrare'), findsOneWidget);
    expect(find.text('Cabinet Test Livrare'), findsOneWidget);
    expect(find.text('Livrare'), findsOneWidget);
    expect(find.text('Facturare'), findsNothing);
  });

  testWidgets('fara nicio adresa, ecranul o spune', (tester) async {
    await pump(tester, const []);

    expect(find.text('Nu ai nicio adresa salvata.'), findsOneWidget);
  });
}

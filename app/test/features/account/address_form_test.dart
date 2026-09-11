import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/address_options.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/address_form_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> optionsFixture() =>
    jsonDecode(File('test/contract/address_options.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> createdFixture() =>
    jsonDecode(File('test/contract/address_created.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('AddressOptions decodeaza address_options.json', () {
    final options = AddressOptions.fromJson(optionsFixture());

    expect(options.countries.first.name, 'Romania');
    expect(options.countries.first.stateRequired, isTrue);
    expect(options.defaultCountryId, 188);
    expect(options.states.single.name, 'Cluj');
    expect(options.cities.single.name, 'Cluj-Napoca');
    // Campurile obligatorii vin de la magazin, nu din aplicatie: `city_id` e acolo
    // pentru ca modulul clientului face orasul o inregistrare legata.
    expect(options.required.delivery, contains('city_id'));
    expect(options.required.invoice, contains('email'));
    expect(options.cityIsList, isTrue);
  });

  Future<void> pumpForm(WidgetTester tester, FakeTransport transport,
      {String kind = 'delivery'}) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: AddressFormScreen(kind: kind)),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  FakeTransport optionsTransport() {
    final transport = FakeTransport();
    // Prima cerere vine fara tara; ecranul o repeta cu tara implicita a magazinului.
    transport.when('GET', '/api/app/v1/addresses/options',
        ApiResponse(status: 200, json: optionsFixture()));
    transport.when('GET', '/api/app/v1/addresses/options?country_id=188',
        ApiResponse(status: 200, json: optionsFixture()));
    return transport;
  }

  testWidgets('formularul marcheaza cu stea campurile pe care le cere magazinul',
      (tester) async {
    await pumpForm(tester, optionsTransport());

    expect(find.text('Nume *'), findsOneWidget);
    expect(find.text('Strada si numarul *'), findsOneWidget);
    expect(find.text('Telefon *'), findsOneWidget);
    // `street2` nu e in lista ceruta, deci nu poarta stea.
    expect(find.text('Detalii (bloc, scara, apartament)'), findsOneWidget);
  });

  testWidgets('la facturare apar firma si codul fiscal, la livrare nu', (tester) async {
    await pumpForm(tester, optionsTransport());
    expect(find.text('Nume firma'), findsNothing);

    await pumpForm(tester, optionsTransport(), kind: 'invoice');
    expect(find.text('Nume firma'), findsOneWidget);
    expect(find.textContaining('Cod fiscal'), findsOneWidget);
  });

  testWidgets('orasul e lista cand magazinul il tine ca inregistrare', (tester) async {
    await pumpForm(tester, optionsTransport());
    expect(find.text('Oras *'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(3),
        reason: 'tara, judet, oras');
  });

  testWidgets('fara modulul de orase, orasul ramane camp de text', (tester) async {
    final json = {...optionsFixture(), 'city_is_list': false};
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/addresses/options', ApiResponse(status: 200, json: json));
    transport.when(
        'GET', '/api/app/v1/addresses/options?country_id=188', ApiResponse(status: 200, json: json));

    await pumpForm(tester, transport);

    expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(2), reason: 'tara si judet');
  });

  testWidgets('salvarea trimite valorile si tipul cerut', (tester) async {
    final transport = optionsTransport();
    transport.when('POST', '/api/app/v1/addresses',
        ApiResponse(status: 200, json: createdFixture()));

    await pumpForm(tester, transport, kind: 'invoice');
    await tester.enterText(find.widgetWithText(TextField, 'Nume *'), 'Cabinet Nou');
    await tester.enterText(find.widgetWithText(TextField, 'Strada si numarul *'), 'Str. Noua 5');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Salveaza adresa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    expect(call.body!['kind'], 'invoice');
    final values = (call.body!['values'] as Map).cast<String, dynamic>();
    expect(values['name'], 'Cabinet Nou');
    expect(values['street'], 'Str. Noua 5');
    expect(values['country_id'], 188, reason: 'tara implicita a magazinului');
    // Campurile goale nu se trimit deloc, ca serverul sa le raporteze el ca lipsa.
    expect(values.containsKey('street2'), isFalse);
  });

  testWidgets('un camp respins de server e marcat exact pe el', (tester) async {
    final transport = optionsTransport();
    transport.when(
      'POST',
      '/api/app/v1/addresses',
      const ApiResponse(status: 422, json: {
        'error': {
          'code': 'invalid_address',
          'message': 'Some required fields are empty.',
          'details': {
            'fields': ['phone', 'city_id']
          }
        }
      }),
    );

    await pumpForm(tester, transport);
    await tester.tap(find.widgetWithText(FilledButton, 'Salveaza adresa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Some required fields are empty.'), findsOneWidget);
    expect(find.text('Verifica acest camp'), findsOneWidget, reason: 'telefonul');
    expect(find.text('Alege orasul'), findsOneWidget);
  });

  testWidgets('schimbarea tarii cere din nou optiunile de la server', (tester) async {
    final transport = optionsTransport();
    transport.when('GET', '/api/app/v1/addresses/options?country_id=20',
        ApiResponse(status: 200, json: {...optionsFixture(), 'states': <dynamic>[]}));

    await pumpForm(tester, transport);
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulgaria').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      transport.calls.any((c) => c.path == '/api/app/v1/addresses/options?country_id=20'),
      isTrue,
      reason: 'alta tara poate avea alte judete si alte campuri obligatorii',
    );
  });
}

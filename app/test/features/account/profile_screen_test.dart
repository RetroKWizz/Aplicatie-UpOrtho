import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/profile.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/profile_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

Map<String, dynamic> profileFixture() =>
    jsonDecode(File('test/contract/profile.json').readAsStringSync()) as Map<String, dynamic>;

List<dynamic> loyaltyFixture() =>
    jsonDecode(File('test/contract/loyalty.json').readAsStringSync()) as List<dynamic>;

void main() {
  test('AccountProfileResponse decodeaza profile.json', () {
    final response = AccountProfileResponse.fromJson(profileFixture());

    expect(response.profile.name, 'Dr. Exemplu Popescu');
    expect(response.profile.mobile, '+40711111111');
    expect(response.profile.companyName, 'Cabinet Dentar Exemplu SRL');
    expect(response.profile.canEditVat, isFalse);
    expect(response.required, contains('email'));
    expect(response.editable, contains('vat'));
  });

  test('LoyaltyCard decodeaza loyalty.json', () {
    final cards = [
      for (final item in loyaltyFixture()) LoyaltyCard.fromJson(item as Map<String, dynamic>)
    ];

    expect(cards.first.program, 'Ortho Club 2026');
    // Textul e compus de Odoo: un program pe bani scrie o suma, unul pe puncte scrie
    // puncte. Aplicatia nu formateaza bani.
    expect(cards.first.pointsDisplay, '150 puncte');
    expect(cards.last.pointsDisplay, '250,00 lei');
    expect(cards.last.expirationDate, '2026-12-31');
  });

  Future<void> pumpProfile(WidgetTester tester, FakeTransport transport) async {
    tester.view.physicalSize = const Size(500, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProfileScreen()),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  FakeTransport profileTransport() {
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/account/profile',
        ApiResponse(status: 200, json: profileFixture()));
    return transport;
  }

  testWidgets('campurile sunt pre-completate cu datele contului', (tester) async {
    await pumpProfile(tester, profileTransport());

    expect(find.text('Dr. Exemplu Popescu'), findsOneWidget);
    expect(find.text('cabinet@exemplu.ro'), findsOneWidget);
    expect(find.text('+40711111111'), findsOneWidget, reason: 'mobil');
    expect(find.text('Medic primar'), findsOneWidget);
    expect(find.textContaining('Tara: Romania'), findsOneWidget);
  });

  testWidgets('codul fiscal e blocat cand Odoo spune ca nu mai poate fi schimbat',
      (tester) async {
    await pumpProfile(tester, profileTransport());

    final vat = tester.widget<TextField>(find.widgetWithText(TextField, 'RO12345678'));
    expect(vat.enabled, isFalse);
    expect(find.textContaining('nu mai pot fi schimbate'), findsOneWidget);
  });

  testWidgets('cu CUI editabil, campul nu mai e blocat', (tester) async {
    final json = profileFixture();
    (json['profile'] as Map<String, dynamic>)['can_edit_vat'] = true;
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/account/profile', ApiResponse(status: 200, json: json));

    await pumpProfile(tester, transport);

    final vat = tester.widget<TextField>(find.widgetWithText(TextField, 'RO12345678'));
    expect(vat.enabled, isTrue);
  });

  testWidgets('salvarea trimite campurile editabile, inclusiv pe cele golite',
      (tester) async {
    final transport = profileTransport();
    transport.when('POST', '/api/app/v1/account/profile',
        ApiResponse(status: 200, json: profileFixture()));

    await pumpProfile(tester, transport);
    await tester.enterText(find.widgetWithText(TextField, '+40700000000'), '+40799999999');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Salveaza'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final call = transport.calls.firstWhere((c) => c.method == 'POST');
    final values = (call.body!['values'] as Map).cast<String, dynamic>();
    expect(values['phone'], '+40799999999');
    // Golirea unui camp e o cerere de stergere: se trimite, ca serverul sa o refuze
    // daca e obligatoriu. Netrimisa, clientul ar primi 200 si nimic nu s-ar intampla.
    expect(values.containsKey('street2'), isTrue);
    // Codul fiscal blocat nu se trimite deloc.
    expect(values.containsKey('vat'), isFalse);
  });

  testWidgets('un camp respins de server e marcat exact pe el', (tester) async {
    final transport = profileTransport();
    transport.when(
      'POST',
      '/api/app/v1/account/profile',
      const ApiResponse(status: 422, json: {
        'error': {
          'code': 'invalid_profile',
          'message': 'Invalid Email! Please enter a valid email address.',
          'details': {
            'fields': ['email']
          }
        }
      }),
    );

    await pumpProfile(tester, transport);
    await tester.tap(find.widgetWithText(FilledButton, 'Salveaza'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Invalid Email'), findsOneWidget);
    expect(find.text('Verifica acest camp'), findsOneWidget);
  });

  testWidgets('o salvare reusita confirma pe ecran', (tester) async {
    final transport = profileTransport();
    transport.when('POST', '/api/app/v1/account/profile',
        ApiResponse(status: 200, json: profileFixture()));

    await pumpProfile(tester, transport);
    await tester.tap(find.widgetWithText(FilledButton, 'Salveaza'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Datele au fost salvate.'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/account/password_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, FakeTransport transport) async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PasswordScreen()),
    ));
    await tester.pump();
  }

  Future<void> fill(WidgetTester tester, String current, String next, String confirm) async {
    await tester.enterText(find.widgetWithText(TextField, 'Parola actuala'), current);
    await tester.enterText(find.widgetWithText(TextField, 'Parola noua'), next);
    await tester.enterText(find.widgetWithText(TextField, 'Confirma parola noua'), confirm);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Schimba parola'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('confirmarea gresita se prinde in aplicatie, fara sa deranjeze serverul',
      (tester) async {
    final transport = FakeTransport();
    await pumpScreen(tester, transport);

    await fill(tester, 'veche', 'noua123', 'altceva');

    expect(find.textContaining('nu sunt la fel'), findsOneWidget);
    expect(transport.calls, isEmpty);
  });

  testWidgets('o schimbare reusita confirma pe ecran si goleste campurile',
      (tester) async {
    final transport = FakeTransport();
    transport.when('POST', '/api/app/v1/account/password',
        const ApiResponse(status: 200, json: {'ok': true}));

    await pumpScreen(tester, transport);
    await fill(tester, 'Veche123!', 'Noua456!', 'Noua456!');

    final call = transport.calls.single;
    expect(call.body!['current_password'], 'Veche123!');
    expect(call.body!['new_password'], 'Noua456!');
    expect(find.text('Parola a fost schimbata.'), findsOneWidget);
    expect(find.text('Noua456!'), findsNothing, reason: 'campurile se golesc');
  });

  testWidgets('mesajul portalului se arata asa cum vine', (tester) async {
    final transport = FakeTransport();
    transport.when(
      'POST',
      '/api/app/v1/account/password',
      const ApiResponse(status: 422, json: {
        'error': {
          'code': 'invalid_password',
          'message': 'The old password you provided is incorrect.',
          'details': {'fields': []}
        }
      }),
    );

    await pumpScreen(tester, transport);
    await fill(tester, 'gresita', 'Noua456!', 'Noua456!');

    expect(find.textContaining('old password'), findsOneWidget);
  });
}

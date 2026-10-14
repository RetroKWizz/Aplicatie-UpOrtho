import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/home/home_screen.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  Map<String, dynamic> homeFixture() =>
      jsonDecode(File('test/contract/home.json').readAsStringSync()) as Map<String, dynamic>;

  Map<String, dynamic> banner(int id, String title, String placement) => {
        'id': id,
        'title': title,
        'subtitle': null,
        'cta_text': null,
        'placement': placement,
        'image_url': null,
        'link': {'type': 'none', 'category_id': null, 'url': null},
      };

  Future<void> pump(WidgetTester tester, Map<String, dynamic> home) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final transport = FakeTransport();
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: home));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('bannerele mari stau intr-un carusel, cu puncte cand sunt mai multe',
      (tester) async {
    await pump(tester, {
      'banners': [
        banner(1, 'Alatura-te Ortho Club', 'hero'),
        banner(2, 'Campanie de toamna', 'hero'),
      ],
      'quick_categories': <dynamic>[],
    });

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byKey(const Key('hero-dots')), findsOneWidget);
  });

  testWidgets('un singur banner nu primeste puncte', (tester) async {
    // Un rand cu un singur punct nu spune nimic.
    await pump(tester, {
      'banners': [banner(1, 'Alatura-te Ortho Club', 'hero')],
      'quick_categories': <dynamic>[],
    });

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byKey(const Key('hero-dots')), findsNothing);
  });

  testWidgets('fixture-ul de contract se deseneaza: banner, categorii si oferte',
      (tester) async {
    await pump(tester, homeFixture());

    expect(find.text('Alatura-te Ortho Club'), findsOneWidget);
    expect(find.text('Categorii'), findsOneWidget);
    expect(find.text('Bracketi'), findsWidgets);
    expect(find.text('Oferte'), findsOneWidget);
  });

  testWidgets('fara niciun continut, ecranul o spune in loc sa ramana gol',
      (tester) async {
    await pump(tester, {'banners': <dynamic>[], 'quick_categories': <dynamic>[]});

    expect(find.textContaining('Nu exista continut inca'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('randurile de produse apar cu titlul lor si cu preturile de la server',
      (tester) async {
    await pump(tester, homeFixture());

    expect(find.text('Noutati'), findsOneWidget);
    expect(find.text('Bracket metalic Roth .022'), findsOneWidget);
    expect(find.text('148,50 lei'), findsWidgets);
    // Randul facut dintr-o categorie are unde sa duca mai departe.
    expect(find.text('Vezi toate'), findsOneWidget);
  });

  testWidgets('un rand de produse alese de mana nu arata "Vezi toate"', (tester) async {
    // Nu exista o lista care sa le cuprinda, deci butonul n-ar avea unde sa duca.
    final home = homeFixture();
    ((home['sections'] as List).first as Map<String, dynamic>)['category_id'] = null;

    await pump(tester, home);

    expect(find.text('Noutati'), findsOneWidget);
    expect(find.text('Vezi toate'), findsNothing);
  });

  testWidgets('fara sectiuni, Acasa ramane cu bannere si categorii', (tester) async {
    final home = {...homeFixture(), 'sections': <dynamic>[]};

    await pump(tester, home);

    expect(find.text('Noutati'), findsNothing);
    expect(find.text('Categorii'), findsOneWidget);
  });
}

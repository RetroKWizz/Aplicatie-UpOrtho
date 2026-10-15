import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uportho_app/api/models/social_link.dart';
import 'package:uportho_app/design_system/widgets/feature_banner_card.dart';
import 'package:uportho_app/design_system/widgets/instagram_feed_card.dart';
import 'package:uportho_app/design_system/widgets/social_row.dart';
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

  Future<void> pump(WidgetTester tester, Map<String, dynamic> home,
      {double bottomInset = 0}) async {
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
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
          child: const HomeScreen(),
        ),
      ),
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

  testWidgets('categoriile arata cate produse au, ca pe site', (tester) async {
    await pump(tester, homeFixture());

    expect(find.text('41 produse'), findsOneWidget);
  });

  testWidgets('o categorie goala nu se lauda cu zero produse', (tester) async {
    final home = homeFixture();
    for (final c in home['quick_categories'] as List) {
      (c as Map<String, dynamic>)['product_count'] = 0;
    }

    await pump(tester, home);

    expect(find.text('0 produse'), findsNothing);
    expect(find.text('Bracketi'), findsWidgets, reason: 'categoria ramane, doar numarul lipseste');
  });

  testWidgets('randul de branduri arata numele si cate produse are fiecare',
      (tester) async {
    await pump(tester, homeFixture());

    expect(find.text('Cumpara dupa brand'), findsOneWidget);
    expect(find.text('G&H Orthodontics'), findsOneWidget);
    expect(find.text('111 produse'), findsOneWidget);
  });

  testWidgets('fara branduri, randul lipseste cu totul', (tester) async {
    // Pe o baza fara modulele magazinului, serverul trimite lista goala.
    final home = {...homeFixture(), 'brands': <dynamic>[]};

    await pump(tester, home);

    expect(find.text('Cumpara dupa brand'), findsNothing);
  });

  testWidgets('retelele sociale stau la capatul paginii, cate o iconita de fiecare',
      (tester) async {
    await pump(tester, homeFixture());
    // Lista de pe Acasa are si randuri orizontale, deci exista mai multe Scrollable;
    // derularea se face explicit pe lista verticala, prima din arbore.
    await tester.scrollUntilVisible(find.text('Urmareste-ne'), 300,
        scrollable: find.byType(Scrollable).first);

    expect(find.text('Urmareste-ne'), findsOneWidget);
    expect(find.byType(SocialRow), findsOneWidget);
    expect(
      tester.widget<SocialRow>(find.byType(SocialRow)).links.map((l) => l.network),
      ['facebook', 'instagram'],
    );
  });

  testWidgets('fara nicio retea completata in Odoo, blocul nu se deseneaza',
      (tester) async {
    final home = {...homeFixture(), 'social': <dynamic>[]};

    await pump(tester, home);

    expect(find.text('Urmareste-ne'), findsNothing);
  });

  testWidgets('ultimul lucru din pagina nu ramane sub bara plutitoare',
      (tester) async {
    // Shell-ul rezerva loc cat bara, prin `MediaQuery`. Un padding scris de noi il
    // inlocuieste pe al lui Flutter, deci rezerva trebuie adunata explicit - altfel
    // randul de retele sociale sta pentru totdeauna sub sticla.
    await pump(tester, homeFixture(), bottomInset: 110);

    final list = tester.widget<ListView>(find.byType(ListView).first);
    expect(list.padding, const EdgeInsets.only(top: 12, bottom: 122));
  });

  testWidgets('banda lata are supratitlu, titlu si buton langa poza', (tester) async {
    // Spre deosebire de hero si promo, textul NU se scrie peste poza: pozele de
    // produs sunt pe fundal deschis si text alb peste ele nu se citeste.
    await pump(tester, homeFixture());
    await tester.scrollUntilVisible(find.byType(FeatureBannerCard), 300,
        scrollable: find.byType(Scrollable).first);

    expect(find.byType(FeatureBannerCard), findsOneWidget);
    expect(find.text('NOU la UpOrtho'), findsOneWidget);
    expect(find.text('Instrumentar Ixion'), findsOneWidget);
  });

  testWidgets('o plasare necunoscuta nu ajunge niciodata banda lata', (tester) async {
    // Un server mai nou poate trimite o plasare pe care aplicatia n-o stie; ea cade
    // pe `promo`, niciodata pe ceva ce ocupa toata latimea.
    final home = {
      ...homeFixture(),
      'banners': [
        {...banner(9, 'Plasare viitoare', 'carousel_3d')},
      ],
    };

    await pump(tester, home);

    expect(find.byType(FeatureBannerCard), findsNothing);
  });

  testWidgets('feedul de Instagram apare cu contul magazinului', (tester) async {
    await pump(tester, homeFixture());
    await tester.scrollUntilVisible(find.byType(InstagramFeedCard), 300,
        scrollable: find.byType(Scrollable).first);

    expect(find.text('De pe Instagram'), findsOneWidget);
    expect(find.text('@uporthoromania'), findsOneWidget);
  });

  testWidgets('fara cont de Instagram in Odoo, feedul nu se deseneaza', (tester) async {
    final home = {...homeFixture(), 'instagram': null};

    await pump(tester, home);

    expect(find.byType(InstagramFeedCard), findsNothing);
  });

  testWidgets('apasarea pe o retea cere deschiderea adresei ei', (tester) async {
    // Widgetul nu deschide el nimic: primeste callback-ul de la ecran, care trece
    // adresa prin aceeasi paza ca link-ul extern al unui banner.
    final deschise = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SocialRow(
          links: const [
            SocialLink(network: 'facebook', url: 'https://facebook.test/u'),
            SocialLink(network: 'instagram', url: 'https://instagram.test/u'),
          ],
          onOpen: (link) => deschise.add(link.url),
        ),
      ),
    ));

    await tester.tap(find.byTooltip('Instagram'));

    expect(deschise, ['https://instagram.test/u']);
  });

  testWidgets('o retea necunoscuta se arata cu iconita de link, nu dispare',
      (tester) async {
    // Daca Odoo adauga maine o retea noua, adresa completata de un editor trebuie
    // sa se vada; altfel ar parea ca aplicatia a pierdut-o.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SocialRow(
          links: const [SocialLink(network: 'threads', url: 'https://threads.test/u')],
          onOpen: (_) {},
        ),
      ),
    ));

    expect(find.byTooltip('Threads'), findsOneWidget);
    expect(socialNetworkLook('threads').icon, FontAwesomeIcons.link);
  });
}

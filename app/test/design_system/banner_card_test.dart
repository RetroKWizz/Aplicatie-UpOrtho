import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/banner.dart';
import 'package:uportho_app/design_system/widgets/banner_card.dart';

void main() {
  const banner = AppBanner(
    id: 1, title: 'Titlu', subtitle: 'Sub', ctaText: 'Vezi', placement: BannerPlacement.hero,
    imageUrl: null, link: BannerLink(type: BannerLinkType.none),
  );

  testWidgets('shows title, subtitle and cta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BannerCard(banner: banner, imageUrl: null))));
    expect(find.text('Titlu'), findsOneWidget);
    expect(find.text('Sub'), findsOneWidget);
    expect(find.text('Vezi'), findsOneWidget);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: BannerCard(banner: banner, imageUrl: null, onTap: () => tapped = true))));
    await tester.tap(find.byType(BannerCard));
    expect(tapped, isTrue);
  });

  testWidgets('hides subtitle and cta when null', (tester) async {
    const bare = AppBanner(id: 2, title: 'T', placement: BannerPlacement.promo, link: BannerLink(type: BannerLinkType.none));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BannerCard(banner: bare, imageUrl: null))));
    expect(find.text('T'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  // Testul de dinainte se numea "accepts httpHeaders without crashing" si verifica doar
  // ca se randeaza o eticheta de text - ar fi trecut si daca parametrul httpHeaders ar fi
  // fost sters cu totul. Aici verificam efectiv ca headerele ajung pe cererea de imagine,
  // adica exact garantia pe care se sprijina autentificarea imaginilor din Odoo.
  testWidgets('httpHeaders ajung pe CachedNetworkImage cand exista imageUrl', (tester) async {
    const headers = {'Cookie': 'session_id=abc'};
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BannerCard(
        banner: banner,
        imageUrl: 'https://example.test/api/app/v1/banners/1/image?unique=3a1f9c2',
        httpHeaders: headers,
      )),
    ));
    final image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(image.httpHeaders, headers);
    expect(image.imageUrl, 'https://example.test/api/app/v1/banners/1/image?unique=3a1f9c2');
  });

  testWidgets('fara httpHeaders, CachedNetworkImage nu primeste headere inventate', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BannerCard(banner: banner, imageUrl: 'https://example.test/i.png')),
    ));
    expect(tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).httpHeaders, isNull);
  });

  testWidgets('fara imageUrl nu se cere nicio imagine', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BannerCard(banner: banner, imageUrl: null, httpHeaders: {'Cookie': 'session_id=abc'})),
    ));
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('promo card cu titlu si subtitlu lungi nu da overflow, in grila reala 2 coloane', (tester) async {
    // Reproduce defectul din raportarea de test manual: titlu romanesc lung, care se
    // infasoara pe 2 randuri, plus subtitlu lung si CTA, intr-un card promo (childAspectRatio
    // 4/3, 2 coloane) - inainte de fix acest caz dadea "BOTTOM OVERFLOWED BY N PIXELS".
    const longBanner = AppBanner(
      id: 3,
      title: 'Reducere speciala de toamna la toate produsele ortodontice pentru clinici partenere',
      subtitle: 'Oferta valabila pana la epuizarea stocului, doar pentru comenzile plasate prin aplicatie',
      ctaText: 'Vezi toate ofertele disponibile',
      placement: BannerPlacement.promo,
      link: BannerLink(type: BannerLinkType.none),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 4 / 3,
              children: const [BannerCard(banner: longBanner, imageUrl: null)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Vezi toate ofertele disponibile'), findsOneWidget);
  });
}

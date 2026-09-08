import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/product_card.dart';

void main() {
  Widget sized(Widget child, {double width = 170, double height = 280}) =>
      MaterialApp(home: Scaffold(body: SizedBox(width: width, height: height, child: child)));

  testWidgets('produs cu reducere: pret curent, pret taiat, eticheta de reducere, pret club si badge',
      (tester) async {
    await tester.pumpWidget(sized(const ProductCard(
      title: 'Bracket metalic Roth .022',
      code: 'BR-ROTH-022',
      priceFormatted: '148,50 lei',
      listAmountFormatted: '330,00 lei',
      discountLabel: '-55%',
      clubPriceFormatted: '133,65 lei',
      badgeText: 'Nou',
      badgeColor: Colors.green,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Bracket metalic Roth .022'), findsOneWidget);
    expect(find.text('BR-ROTH-022'), findsOneWidget);
    expect(find.text('148,50 lei'), findsOneWidget);
    expect(find.text('330,00 lei'), findsOneWidget);
    expect(find.text('-55%'), findsOneWidget);
    // Eticheta si suma sunt doua randuri: pe cardul ingust de grila suma era
    // altfel retezata de ellipsis.
    expect(find.text('Pret Ortho Club'), findsOneWidget);
    expect(find.text('133,65 lei'), findsOneWidget);
    expect(find.text('Nou'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('produs fara reducere: nu arata pret taiat, eticheta de reducere, pret club sau badge',
      (tester) async {
    await tester.pumpWidget(sized(const ProductCard(
      title: 'Arc NiTi termic .014',
      priceFormatted: '25,00 lei',
    )));
    await tester.pumpAndSettle();

    expect(find.text('25,00 lei'), findsOneWidget);
    expect(find.text('Arc NiTi termic .014'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fara imageUrl afiseaza iconita locala, nicio cerere de imagine', (tester) async {
    await tester.pumpWidget(sized(const ProductCard(
      title: 'X',
      priceFormatted: '1 leu',
      httpHeaders: {'Cookie': 'session_id=abc'},
    )));
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('httpHeaders ajung pe CachedNetworkImage cand exista imageUrl', (tester) async {
    const headers = {'Cookie': 'session_id=abc'};
    await tester.pumpWidget(sized(const ProductCard(
      title: 'X',
      priceFormatted: '1 leu',
      imageUrl: 'https://example.test/api/app/v1/products/1/image?unique=abc',
      httpHeaders: headers,
    )));
    final image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(image.httpHeaders, headers);
    expect(image.imageUrl, 'https://example.test/api/app/v1/products/1/image?unique=abc');
  });

  testWidgets('fara httpHeaders, CachedNetworkImage nu primeste headere inventate', (tester) async {
    await tester.pumpWidget(sized(const ProductCard(
      title: 'X',
      priceFormatted: '1 leu',
      imageUrl: 'https://example.test/i.png',
    )));
    expect(tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).httpHeaders, isNull);
  });

  testWidgets('tap apeleaza onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(sized(ProductCard(
      title: 'X',
      priceFormatted: '1 leu',
      onTap: () => tapped = true,
    )));
    await tester.tap(find.byType(ProductCard));
    expect(tapped, isTrue);
  });

  testWidgets('nume romanesc foarte lung, intr-o grila reala de 2 coloane, nu da overflow', (tester) async {
    // Reproduce clasa de defect deja lovita in acest proiect (BannerCard): titlu
    // lung + cod lung + toate campurile optionale de pret, intr-un card ingust de
    // grila (childAspectRatio 0.62, 2 coloane) - inainte de fix ar fi dat
    // "BOTTOM OVERFLOWED BY N PIXELS".
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
            children: const [
              ProductCard(
                title: 'Set bracketi metalici Atlas Mini .022 pentru tratament ortodontic complet',
                code: 'SET-ATLAS-MINI-022-KIT-COMPLET-CLINICA',
                priceFormatted: '1.234,56 lei',
                listAmountFormatted: '2.000,00 lei',
                discountLabel: '-38%',
                clubPriceFormatted: '1.100,00 lei',
                badgeText: 'Promotie limitata',
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Set bracketi metalici Atlas Mini'), findsOneWidget);
  });
}

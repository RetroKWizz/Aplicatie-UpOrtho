import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/benefit_list.dart';

void main() {
  Widget sized(Widget child, {double width = 360}) =>
      MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: width, child: child))));

  testWidgets('lista goala nu deseneaza nimic', (tester) async {
    await tester.pumpWidget(sized(const BenefitList(items: [])));
    expect(find.byType(Icon), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arata titlul si subtitlul fiecarui beneficiu', (tester) async {
    await tester.pumpWidget(sized(const BenefitList(items: [
      BenefitItem(
          icon: Icons.local_shipping_outlined,
          title: 'Livrare gratuita',
          text: 'pentru comenzi de peste 400 lei'),
      BenefitItem(icon: Icons.lock_outline, title: 'Plata online sigura'),
    ])));

    expect(find.text('Livrare gratuita'), findsOneWidget);
    expect(find.text('pentru comenzi de peste 400 lei'), findsOneWidget);
    expect(find.text('Plata online sigura'), findsOneWidget);
  });

  testWidgets('fara imagine se deseneaza iconita', (tester) async {
    await tester.pumpWidget(sized(const BenefitList(items: [
      BenefitItem(icon: Icons.local_shipping_outlined, title: 'Livrare gratuita'),
    ])));

    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('cu imagine incarcata in Odoo, iconita nu se mai deseneaza', (tester) async {
    // Blocurile echivalente de pe site arata logouri adevarate (curier, sigle de
    // card), nu iconite: cand exista logo, el castiga.
    await tester.pumpWidget(sized(const BenefitList(items: [
      BenefitItem(
        icon: Icons.local_shipping_outlined,
        title: 'Livrare prin curier',
        imageUrl: 'http://x/api/app/v1/benefits/3/image?unique=a',
      ),
    ])));

    expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);
    expect(find.text('Livrare prin curier'), findsOneWidget);
  });
}

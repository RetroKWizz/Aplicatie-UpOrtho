import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/brand_card.dart';
import 'package:uportho_app/design_system/widgets/description_view.dart';

void main() {
  Widget sized(Widget child, {double width = 360}) =>
      MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: width, child: child))));

  const description = [
    DescriptionBlockData(
      style: DescriptionBlockStyle.paragraph,
      spans: [DescriptionSpanData(text: 'Producator britanic de produse ortodontice.')],
    ),
  ];

  testWidgets('arata numele si descrierea brandului', (tester) async {
    await tester.pumpWidget(sized(
      const BrandCard(name: 'DB Orthodontics', description: description),
    ));

    expect(find.text('DB Orthodontics'), findsOneWidget);
    expect(find.byType(DescriptionView), findsOneWidget);
    expect(find.textContaining('Producator britanic'), findsOneWidget);
  });

  testWidgets('fara logo, chenarul ramane cu numele si textul', (tester) async {
    await tester.pumpWidget(sized(
      const BrandCard(name: 'DB Orthodontics', description: description),
    ));

    expect(find.text('DB Orthodontics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fara descriere, nu se deseneaza un bloc de text gol', (tester) async {
    await tester.pumpWidget(sized(const BrandCard(name: 'DB Orthodontics')));

    expect(find.text('DB Orthodontics'), findsOneWidget);
    expect(find.byType(DescriptionView), findsNothing);
  });

  testWidgets('fara nume nu se deseneaza nimic', (tester) async {
    await tester.pumpWidget(sized(const BrandCard(name: '  ', description: description)));

    expect(find.byType(DescriptionView), findsNothing);
    expect(find.textContaining('Producator britanic'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/product_tabs.dart';

void main() {
  /// Cele patru file de pe pagina de produs a site-ului, cu etichetele romanesti
  /// folosite in aplicatie. Sunt cele mai lungi pe care le va primi widgetul.
  List<ProductTabItem> fourTabs() => const [
        ProductTabItem(label: 'Descriere', content: Text('continut descriere')),
        ProductTabItem(label: 'Specificatii', content: Text('continut specificatii')),
        ProductTabItem(label: 'Documente', content: Text('continut documente')),
        ProductTabItem(label: 'Recenzii', content: Text('continut recenzii')),
      ];

  /// Widgetul se foloseste in interiorul listei ecranului de produs, deci se
  /// testeaza tot intr-o lista verticala: asa se vede exact acelasi calcul de
  /// latime si aceeasi inaltime nemarginita ca in aplicatie.
  Widget inList(Widget child) => MaterialApp(
        home: Scaffold(
          body: ListView(padding: const EdgeInsets.all(16), children: [child]),
        ),
      );

  Future<void> pumpAt(WidgetTester tester, Widget child, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(inList(child));
    await tester.pumpAndSettle();
  }

  group('bara de taburi pe ecran ingust', () {
    testWidgets('cele patru etichete romanesti incap pe 320px fara overflow',
        (tester) async {
      // Testul e scris INAINTE de widget si e motivul pentru care bara nu e un `Row`:
      // "Descriere / Specificatii / Documente / Recenzii" nu incap pe un rand de
      // 320px, iar proiectul asta a mai livrat exact acest fel de bug.
      await pumpAt(tester, ProductTabs(tabs: fourTabs()), size: const Size(320, 800));

      expect(tester.takeException(), isNull, reason: 'niciun RenderFlex overflow');
      for (final label in const ['Descriere', 'Specificatii', 'Documente', 'Recenzii']) {
        expect(find.text(label), findsOneWidget, reason: 'eticheta "$label" ramane vizibila');
      }
    });

    testWidgets('nicio eticheta nu iese in afara latimii ecranului', (tester) async {
      await pumpAt(tester, ProductTabs(tabs: fourTabs()), size: const Size(320, 800));

      for (final label in const ['Descriere', 'Specificatii', 'Documente', 'Recenzii']) {
        final box = tester.getRect(find.text(label));
        expect(box.left, greaterThanOrEqualTo(0.0), reason: '"$label" incepe in ecran');
        expect(box.right, lessThanOrEqualTo(320.0), reason: '"$label" se termina in ecran');
      }
    });
  });

  testWidgets('la pornire se vede continutul primului tab, nu al celorlalte',
      (tester) async {
    await pumpAt(tester, ProductTabs(tabs: fourTabs()), size: const Size(390, 800));

    expect(find.text('continut descriere'), findsOneWidget);
    expect(find.text('continut specificatii'), findsNothing);
    expect(find.text('continut recenzii'), findsNothing);
  });

  testWidgets('apasarea pe un tab ii arata continutul si il ascunde pe cel dinainte',
      (tester) async {
    await pumpAt(tester, ProductTabs(tabs: fourTabs()), size: const Size(390, 800));

    await tester.tap(find.text('Documente'));
    await tester.pumpAndSettle();

    expect(find.text('continut documente'), findsOneWidget);
    expect(find.text('continut descriere'), findsNothing);
  });

  testWidgets('un singur tab se deseneaza fara bara: o eticheta singura nu e un tab',
      (tester) async {
    await pumpAt(
      tester,
      const ProductTabs(tabs: [
        ProductTabItem(label: 'Descriere', content: Text('continut descriere')),
      ]),
      size: const Size(390, 800),
    );

    expect(find.text('continut descriere'), findsOneWidget);
    expect(find.text('Descriere'), findsNothing, reason: 'fara bara, deci fara eticheta');
  });

  testWidgets('fara taburi nu se deseneaza nimic', (tester) async {
    await pumpAt(tester, const ProductTabs(tabs: []), size: const Size(390, 800));

    expect(find.byType(Text), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cand lista de taburi se scurteaza, selectia nu ramane in afara ei',
      (tester) async {
    // Se intampla la schimbarea variantei: raspunsul nou poate veni fara documente.
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(inList(ProductTabs(tabs: fourTabs())));
    await tester.tap(find.text('Recenzii'));
    await tester.pumpAndSettle();
    expect(find.text('continut recenzii'), findsOneWidget);

    await tester.pumpWidget(inList(const ProductTabs(tabs: [
      ProductTabItem(label: 'Descriere', content: Text('continut descriere')),
      ProductTabItem(label: 'Specificatii', content: Text('continut specificatii')),
    ])));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('continut descriere'), findsOneWidget);
  });
}

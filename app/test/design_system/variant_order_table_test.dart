import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/variant_order_table.dart';

void main() {
  VariantOrderRow row({
    int id = 1,
    List<String> attributes = const ['Brand: Dynaflex Orthodontics', 'Slot: .022'],
    String? code = 'DF201-M2-345',
    String? stock = 'In stoc',
    bool inStock = true,
    String price = '148,50 lei',
    String? subtotal,
    int qty = 0,
  }) =>
      VariantOrderRow(
        id: id,
        attributes: attributes,
        code: code,
        stockLabel: stock,
        inStock: inStock,
        priceFormatted: price,
        subtotalFormatted: subtotal,
        qty: qty,
      );

  Future<void> pump(WidgetTester tester, Widget child, {Size size = const Size(400, 800)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ));
  }

  testWidgets('deseneaza coloanele site-ului si continutul fiecarui rand', (tester) async {
    await pump(
      tester,
      VariantOrderTable(
        rows: [row(subtotal: '297,00 lei', qty: 2)],
        totalFormatted: '297,00 lei',
      ),
    );

    for (final column in const ['Atribute', 'Pret', 'Cantitate', 'Subtotal']) {
      expect(find.text(column), findsOneWidget, reason: 'coloana $column');
    }
    expect(find.text('Brand: Dynaflex Orthodontics'), findsOneWidget);
    expect(find.text('Slot: .022'), findsOneWidget);
    expect(find.text('Cod: DF201-M2-345'), findsOneWidget);
    expect(find.text('In stoc'), findsOneWidget);
    expect(find.text('148,50 lei'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    // Subtotalul randului si totalul de sub tabel: aceeasi suma, doua locuri.
    expect(find.text('297,00 lei'), findsNWidgets(2));
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('minusul si plusul anunta noua cantitate, nu delta', (tester) async {
    final changes = <(int, int)>[];
    await pump(
      tester,
      VariantOrderTable(
        rows: [row(id: 42, qty: 3)],
        onQuantityChanged: (id, qty) => changes.add((id, qty)),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));

    expect(changes, [(42, 4), (42, 3 - 1)]);
  });

  testWidgets('la cantitatea 0 minusul e dezactivat - nu exista cantitati negative',
      (tester) async {
    final changes = <(int, int)>[];
    await pump(
      tester,
      VariantOrderTable(
        rows: [row(qty: 0)],
        onQuantityChanged: (id, qty) => changes.add((id, qty)),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));

    expect(changes, isEmpty);
  });

  testWidgets('fara callback, steperele sunt inerte (ecranul le poate dezactiva)',
      (tester) async {
    await pump(tester, VariantOrderTable(rows: [row(qty: 1)]));

    final plus = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.add), matching: find.byType(IconButton)));
    expect(plus.onPressed, isNull);
  });

  testWidgets('o suma inca necunoscuta se arata ca liniuta, nu ca zero inventat',
      (tester) async {
    // Widgetul nu are voie sa scrie "0,00 lei": nu stie valuta, nu stie formatul si
    // nu face aritmetica pe bani (CLAUDE.md). Pana cand serverul trimite subtotalul,
    // celula ramane goala.
    await pump(tester, VariantOrderTable(rows: [row(subtotal: null)]));

    expect(find.text('—'), findsWidgets);
  });

  testWidgets('un rand fara cod si fara stoc nu deseneaza randuri goale', (tester) async {
    await pump(tester, VariantOrderTable(rows: [row(code: null, stock: null)]));

    expect(find.textContaining('Cod:'), findsNothing);
    expect(find.text('In stoc'), findsNothing);
  });

  testWidgets('tabelul gol nu deseneaza niciun pixel', (tester) async {
    await pump(tester, const VariantOrderTable(rows: []));

    expect(find.text('Atribute'), findsNothing);
    expect(find.text('Total'), findsNothing);
  });

  testWidgets('pe un ecran ingust, cu atribute lungi, nimic nu depaseste latimea',
      (tester) async {
    await pump(
      tester,
      VariantOrderTable(
        rows: [
          row(
            attributes: const [
              'Brand: Dynaflex Orthodontics International',
              'Tip set: All Hooks cu carlige pe toti dintii',
              'Prescriptie: MBT',
              'Slot: .022',
            ],
            price: '1.399,99 lei',
            subtotal: '13.999,90 lei',
            qty: 10,
          ),
        ],
        totalFormatted: '13.999,90 lei',
      ),
      size: const Size(320, 800),
    );

    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/description_view.dart';
import 'package:uportho_app/design_system/widgets/price_tier_table.dart';

void main() {
  Widget sized(Widget child, {double width = 360}) =>
      MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: width, child: child))));

  /// Ca pe ecranul real de produs: latime data, inaltime derulabila. Pe un ecran
  /// foarte ingust pragurile trec pe multe randuri si depasesc inaltimea ferestrei
  /// de test - pe telefon pagina se deruleaza pe verticala, deci testul trebuie sa
  /// masoare latimea, nu inaltimea ferestrei.
  Widget scrollable(Widget child, {double width = 360}) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: SingleChildScrollView(child: child)),
          ),
        ),
      );

  const tiers = [
    PriceTierEntry(label: '1+', priceFormatted: '1.399,99 lei'),
    PriceTierEntry(label: '3+', priceFormatted: '1.120,00 lei'),
    PriceTierEntry(label: '10+', priceFormatted: '999,00 lei'),
  ];

  testWidgets('tabel gol nu deseneaza nimic, nici macar titlul', (tester) async {
    await tester.pumpWidget(sized(const PriceTierTable(title: 'Cantitate', entries: [])));
    expect(find.text('Cantitate'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arata titlul, eticheta si suma fiecarui prag, exact cum vin de la server',
      (tester) async {
    await tester.pumpWidget(sized(const PriceTierTable(title: 'Pret pe cantitate', entries: tiers)));

    expect(find.text('Pret pe cantitate'), findsOneWidget);
    for (final tier in tiers) {
      expect(find.text(tier.label), findsOneWidget);
      expect(find.text(tier.priceFormatted), findsOneWidget);
    }
  });

  testWidgets('nota vine sub titlu si deasupra randurilor', (tester) async {
    // Nota e textul de pe lista de pret (`bulk_info` pe site), trimis de server ca
    // blocuri — widgetul primeste tipuri locale de design system, nu modele API.
    await tester.pumpWidget(sized(const PriceTierTable(
      title: 'Pret public',
      note: [
        DescriptionBlockData(
          style: DescriptionBlockStyle.paragraph,
          spans: [DescriptionSpanData(text: 'Reducerea se aplica de la 5 bucati.')],
        ),
      ],
      entries: tiers,
    )));

    expect(find.text('Reducerea se aplica de la 5 bucati.'), findsOneWidget);
    final noteTop = tester.getTopLeft(find.text('Reducerea se aplica de la 5 bucati.')).dy;
    expect(noteTop, greaterThan(tester.getTopLeft(find.text('Pret public')).dy));
    expect(noteTop, lessThan(tester.getTopLeft(find.text('1.399,99 lei')).dy));
  });

  testWidgets('fara nota nu se deseneaza nimic in locul ei', (tester) async {
    await tester.pumpWidget(sized(const PriceTierTable(title: 'Pret public', entries: tiers)));
    expect(find.byType(DescriptionView), findsNothing);
  });

  testWidgets('randul curent (cantitatea 1) e evidentiat, celelalte nu', (tester) async {
    await tester.pumpWidget(sized(const PriceTierTable(title: 'Cantitate', entries: tiers)));

    final cells = tester.widgetList<PriceTierCell>(find.byType(PriceTierCell)).toList();
    expect(cells, hasLength(3));
    expect(cells[0].highlighted, isTrue);
    expect(cells[1].highlighted, isFalse);
    expect(cells[2].highlighted, isFalse);
  });

  testWidgets('evidentierea poate fi mutata pe alt prag', (tester) async {
    await tester.pumpWidget(sized(const PriceTierTable(entries: tiers, highlightedIndex: 2)));
    final cells = tester.widgetList<PriceTierCell>(find.byType(PriceTierCell)).toList();
    expect(cells[0].highlighted, isFalse);
    expect(cells[2].highlighted, isTrue);
  });

  testWidgets('un index de evidentiere in afara listei nu evidentiaza nimic si nu arunca',
      (tester) async {
    await tester.pumpWidget(sized(const PriceTierTable(entries: tiers, highlightedIndex: 9)));
    expect(tester.widgetList<PriceTierCell>(find.byType(PriceTierCell)).every((c) => !c.highlighted), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multe praguri cu sume lungi, intr-un container ingust: toate vizibile, fara overflow',
      (tester) async {
    await tester.pumpWidget(scrollable(
      const PriceTierTable(
        title: 'Pret Ortho Club pentru comenzi de volum la produsul acesta',
        entries: [
          PriceTierEntry(label: '1+', priceFormatted: '11.399,99 lei'),
          PriceTierEntry(label: '3+', priceFormatted: '11.120,00 lei'),
          PriceTierEntry(label: '10+', priceFormatted: '10.999,00 lei'),
          PriceTierEntry(label: '25+', priceFormatted: '10.499,00 lei'),
          PriceTierEntry(label: '50+', priceFormatted: '9.999,00 lei'),
          PriceTierEntry(label: '100+', priceFormatted: '9.499,00 lei'),
        ],
      ),
      width: 150,
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Pragurile trec pe randurile urmatoare, deci se vad TOATE fara nicio
    // derulare. Inainte se derulau lateral si ultimele ramaneau ascunse - exact
    // ce s-a vazut pe telefon, unde al patrulea prag era taiat de marginea
    // ecranului.
    for (final suma in [
      '11.399,99 lei', '11.120,00 lei', '10.999,00 lei',
      '10.499,00 lei', '9.999,00 lei', '9.499,00 lei',
    ]) {
      expect(find.text(suma), findsOneWidget, reason: 'lipseste $suma');
    }
    expect(find.byType(PriceTierCell), findsNWidgets(6));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/description_view.dart';

void main() {
  Widget sized(Widget child, {double width = 360}) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: Center(child: SizedBox(width: width, child: child))),
        ),
      );

  const blocks = [
    DescriptionBlockData(
      style: DescriptionBlockStyle.heading,
      spans: [DescriptionSpanData(text: 'Cleste Tie Back pentru arcuri groase', bold: true)],
    ),
    DescriptionBlockData(
      style: DescriptionBlockStyle.paragraph,
      spans: [
        DescriptionSpanData(text: 'Clestele este conceput pentru '),
        DescriptionSpanData(text: 'arcuri groase', bold: true),
        DescriptionSpanData(text: ' si tratamente lungi', italic: true),
      ],
    ),
    DescriptionBlockData(
      style: DescriptionBlockStyle.bullets,
      bullets: [
        [DescriptionSpanData(text: 'Falci zimtate care asigura o prindere ferma.')],
        [DescriptionSpanData(text: 'Maner ergonomic.')],
      ],
    ),
  ];

  testWidgets('descriere goala nu deseneaza nimic', (tester) async {
    await tester.pumpWidget(sized(const DescriptionView(blocks: [])));
    expect(find.byType(RichText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('randeaza titlu, paragraf si lista, in ordinea din contract', (tester) async {
    await tester.pumpWidget(sized(const DescriptionView(blocks: blocks)));

    expect(find.textContaining('Cleste Tie Back pentru arcuri groase'), findsOneWidget);
    expect(find.textContaining('Clestele este conceput pentru'), findsOneWidget);
    expect(find.textContaining('Falci zimtate care asigura o prindere ferma.'), findsOneWidget);
    expect(find.textContaining('Maner ergonomic.'), findsOneWidget);
    // Fiecare element de lista are bulina lui.
    expect(find.text('•'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bold si italic ajung pe span-ul corect, nu pe tot paragraful', (tester) async {
    await tester.pumpWidget(sized(const DescriptionView(blocks: blocks)));

    final paragraph = tester.widget<Text>(find.byWidgetPredicate(
      (w) => w is Text && (w.textSpan?.toPlainText() ?? '').startsWith('Clestele este conceput'),
    ));
    final children = (paragraph.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(children, hasLength(3));
    expect(children[0].style?.fontWeight, isNot(FontWeight.w700));
    expect(children[0].style?.fontStyle, isNot(FontStyle.italic));
    expect(children[1].style?.fontWeight, FontWeight.w700);
    expect(children[2].style?.fontStyle, FontStyle.italic);
  });

  testWidgets('titlul e mai mare decat paragraful (ierarhie vizuala, nu HTML)', (tester) async {
    await tester.pumpWidget(sized(const DescriptionView(blocks: blocks)));
    final texts = tester.widgetList<Text>(find.byType(Text)).toList();
    final heading = texts.firstWhere(
        (t) => (t.textSpan?.toPlainText() ?? '').startsWith('Cleste Tie Back pentru'));
    final paragraph = texts.firstWhere(
        (t) => (t.textSpan?.toPlainText() ?? '').startsWith('Clestele este conceput'));
    expect(heading.style!.fontSize!, greaterThan(paragraph.style!.fontSize!));
  });

  testWidgets('un bloc fara span-uri nu deseneaza un rand gol', (tester) async {
    await tester.pumpWidget(sized(const DescriptionView(blocks: [
      DescriptionBlockData(style: DescriptionBlockStyle.paragraph),
      DescriptionBlockData(style: DescriptionBlockStyle.bullets),
    ])));
    expect(find.byType(RichText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text romanesc lung intr-un container ingust nu da overflow', (tester) async {
    await tester.pumpWidget(sized(
      const DescriptionView(blocks: [
        DescriptionBlockData(
          style: DescriptionBlockStyle.heading,
          spans: [
            DescriptionSpanData(
                text: 'Set bracketi metalici Atlas Mini .022 pentru tratament ortodontic complet',
                bold: true),
          ],
        ),
        DescriptionBlockData(
          style: DescriptionBlockStyle.bullets,
          bullets: [
            [
              DescriptionSpanData(
                  text: 'Falci zimtate care asigura o prindere ferma pe arcurile groase, '
                      'inclusiv la tratamentele de lunga durata din cabinetele aglomerate.'),
            ],
          ],
        ),
      ]),
      width: 150,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

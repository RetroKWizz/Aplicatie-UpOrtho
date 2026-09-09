import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/variant_picker.dart';

void main() {
  Widget sized(Widget child, {double width = 360}) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: Center(child: SizedBox(width: width, child: child))),
        ),
      );

  const groups = [
    VariantGroup(id: 7, name: 'Marime', options: [
      VariantOption(id: 1357, label: 'Mare', selected: true),
      VariantOption(id: 1358, label: 'Mic'),
      VariantOption(id: 1359, label: 'Extra mic', available: false),
    ]),
    VariantGroup(id: 8, name: 'Culoare', options: [
      VariantOption(id: 2001, label: 'Argintiu', selected: true),
    ]),
  ];

  testWidgets('fara grupuri nu deseneaza nimic (produs fara variante)', (tester) async {
    await tester.pumpWidget(sized(const VariantPicker(groups: [])));
    expect(find.byType(VariantOptionChip), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cate un grup de butoane per atribut, cu numele atributului deasupra',
      (tester) async {
    await tester.pumpWidget(sized(const VariantPicker(groups: groups)));

    expect(find.text('Marime'), findsOneWidget);
    expect(find.text('Culoare'), findsOneWidget);
    expect(find.byType(VariantOptionChip), findsNWidgets(4));
    expect(find.text('Mare'), findsOneWidget);
    expect(find.text('Extra mic'), findsOneWidget);
  });

  testWidgets('valorile indisponibile sunt aratate dezactivat, nu ascunse', (tester) async {
    var chosen = <int>[];
    await tester.pumpWidget(sized(VariantPicker(
      groups: groups,
      onSelected: (groupId, valueId) => chosen = [groupId, valueId],
    )));

    final unavailable = tester.widget<VariantOptionChip>(find.ancestor(
      of: find.text('Extra mic'),
      matching: find.byType(VariantOptionChip),
    ));
    expect(unavailable.option.available, isFalse);
    expect(unavailable.onTap, isNull);

    await tester.tap(find.text('Extra mic'));
    await tester.pump();
    expect(chosen, isEmpty);
  });

  testWidgets('apasarea pe o valoare disponibila anunta atributul si valoarea', (tester) async {
    int? group;
    int? value;
    await tester.pumpWidget(sized(VariantPicker(
      groups: groups,
      onSelected: (groupId, valueId) {
        group = groupId;
        value = valueId;
      },
    )));

    await tester.tap(find.text('Mic'));
    await tester.pump();
    expect(group, 7);
    expect(value, 1358);
  });

  testWidgets('valoarea selectata e marcata ca atare', (tester) async {
    await tester.pumpWidget(sized(const VariantPicker(groups: groups)));
    final chips = tester.widgetList<VariantOptionChip>(find.byType(VariantOptionChip)).toList();
    expect(chips[0].option.selected, isTrue);
    expect(chips[1].option.selected, isFalse);
  });

  testWidgets('valori romanesti lungi, multe, intr-un container ingust: trec pe randul urmator',
      (tester) async {
    await tester.pumpWidget(sized(
      const VariantPicker(groups: [
        VariantGroup(id: 7, name: 'Marime pentru tratament ortodontic complet la cabinet', options: [
          VariantOption(id: 1, label: 'Mare cu falci zimtate pentru arcuri groase', selected: true),
          VariantOption(id: 2, label: 'Mic cu maner ergonomic si arc de revenire'),
          VariantOption(id: 3, label: 'Extra mic, editie limitata de clinica', available: false),
        ]),
      ]),
      width: 150,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(VariantOptionChip), findsNWidgets(3));
  });
}

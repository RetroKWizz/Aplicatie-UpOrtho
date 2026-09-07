import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/category_chip.dart';

void main() {
  testWidgets('shows name and placeholder icon without iconUrl', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CategoryChip(name: 'Bracketi', iconUrl: null))));
    expect(find.text('Bracketi'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });

  testWidgets('tap calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CategoryChip(name: 'X', iconUrl: null, onTap: () => tapped = true))));
    await tester.tap(find.text('X'));
    expect(tapped, isTrue);
  });
}

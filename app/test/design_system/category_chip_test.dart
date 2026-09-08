import 'package:cached_network_image/cached_network_image.dart';
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

  // Vezi comentariul din banner_card_test.dart: testul de dinainte verifica doar ca se
  // randeaza numele si ar fi trecut si fara parametrul httpHeaders.
  testWidgets('httpHeaders ajung pe CachedNetworkImage cand exista iconUrl', (tester) async {
    const headers = {'Cookie': 'session_id=abc'};
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: CategoryChip(
        name: 'Bracketi',
        iconUrl: 'https://example.test/api/app/v1/categories/12/icon?unique=8be4d17',
        httpHeaders: headers,
      )),
    ));
    final image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(image.httpHeaders, headers);
    expect(image.imageUrl, 'https://example.test/api/app/v1/categories/12/icon?unique=8be4d17');
  });

  testWidgets('fara httpHeaders, CachedNetworkImage nu primeste headere inventate', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: CategoryChip(name: 'Bracketi', iconUrl: 'https://example.test/i.png')),
    ));
    expect(tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).httpHeaders, isNull);
  });

  testWidgets('fara iconUrl se afiseaza iconita locala, fara nicio cerere de imagine', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: CategoryChip(name: 'Y', iconUrl: null, httpHeaders: {'Cookie': 'session_id=abc'})),
    ));
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });
}

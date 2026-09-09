import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/document_list.dart';

void main() {
  Widget sized(Widget child, {double width = 360}) =>
      MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: width, child: child))));

  const documents = [
    DocumentItem(
      name: 'Fisa tehnica',
      fileName: 'fisa-tehnica.pdf',
      url: 'http://x/api/app/v1/products/101/documents/standard/12?unique=a',
    ),
    DocumentItem(
      name: 'Certificat CE',
      fileName: 'certificat.pdf',
      url: 'http://x/api/app/v1/products/101/documents/standard/13?unique=b',
    ),
  ];

  testWidgets('lista goala nu deseneaza nimic', (tester) async {
    await tester.pumpWidget(sized(DocumentList(items: const [], onOpen: (_) {})));
    expect(find.byType(ListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arata numele fiecarui document si numele fisierului', (tester) async {
    await tester.pumpWidget(sized(DocumentList(items: documents, onOpen: (_) {})));

    expect(find.text('Fisa tehnica'), findsOneWidget);
    expect(find.text('fisa-tehnica.pdf'), findsOneWidget);
    expect(find.text('Certificat CE'), findsOneWidget);
  });

  testWidgets('numele fisierului lipseste cand e acelasi cu numele afisat', (tester) async {
    // Pe `product.document` numele documentului CHIAR e numele fisierului (modelul
    // Odoo il mosteneste din `ir.attachment`), deci scris de doua ori ar fi zgomot.
    await tester.pumpWidget(sized(DocumentList(
      items: const [DocumentItem(name: 'fisa.pdf', fileName: 'fisa.pdf', url: 'http://x/d')],
      onOpen: (_) {},
    )));
    expect(find.text('fisa.pdf'), findsOneWidget);
  });

  testWidgets('apasarea trimite URL-ul documentului mai departe', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(sized(DocumentList(items: documents, onOpen: opened.add)));

    await tester.tap(find.text('Certificat CE'));
    await tester.pump();

    expect(opened, [documents[1].url]);
  });
}

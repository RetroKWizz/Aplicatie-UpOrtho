import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/sign_in_banner.dart';

void main() {
  testWidgets('banda spune ce se castiga cu un cont si cum se intra', (tester) async {
    var cerut = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SignInBanner(onSignIn: () => cerut++)),
    ));

    expect(find.textContaining('preturile'), findsOneWidget);

    await tester.tap(find.text('Intra'));

    expect(cerut, 1);
  });

  testWidgets('butonul are inaltimea minima de atins cu degetul', (tester) async {
    // Sub 44 de puncte, butonul se rateaza pe telefon.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SignInBanner(onSignIn: () {})),
    ));

    expect(tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(44.0));
  });
}

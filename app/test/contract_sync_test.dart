import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Sursa de adevar a contractului e modulul Odoo (`odoo/uportho_app/contract/`);
/// `tool/sync_contract.sh` copiaza fixture-urile in `app/test/contract/`, iar cele
/// doua suite (Python si Dart) verifica fiecare propria copie.
///
/// Fara acest test, o divergenta intre copii trece nedetectata: cine schimba
/// serializatorul SI fixture-ul din modul face testul Python sa treaca, in timp ce
/// testul Dart continua sa decodeze copia veche din app/ si trece si el. Ambele
/// suite verzi, aplicatia rupta in productie. Aici comparam copiile byte cu byte.
void main() {
  const moduleDir = '../odoo/uportho_app/contract';
  const appDir = 'test/contract';
  const hint = 'Ruleaza `app/tool/sync_contract.sh` ca sa resincronizezi fixture-urile '
      'de contract din modulul Odoo (sursa de adevar) in app/test/contract/.';

  Set<String> jsonNamesIn(String path) {
    final directory = Directory(path);
    if (!directory.existsSync()) return const {};
    return directory
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .where((name) => name.endsWith('.json'))
        .toSet();
  }

  test('directorul de contract al modulului Odoo exista si are cele 4 fixture-uri', () {
    expect(
      Directory(moduleDir).existsSync(),
      isTrue,
      reason: 'Nu gasesc $moduleDir. Testul trebuie rulat din radacina pachetului Flutter (app/).',
    );
    expect(
      jsonNamesIn(moduleDir),
      containsAll(const ['home.json', 'login.json', 'me.json', 'error.json']),
    );
  });

  test('aceleasi fisiere de contract exista in ambele copii', () {
    final inModule = jsonNamesIn(moduleDir);
    final inApp = jsonNamesIn(appDir);
    final onlyInModule = inModule.difference(inApp);
    final onlyInApp = inApp.difference(inModule);
    expect(
      onlyInModule,
      isEmpty,
      reason: 'Fixture-uri prezente doar in modulul Odoo, lipsa din $appDir: $onlyInModule. $hint',
    );
    expect(
      onlyInApp,
      isEmpty,
      reason: 'Fixture-uri prezente doar in $appDir, lipsa din modulul Odoo: $onlyInApp. '
          'Fie au fost sterse din modul, fie adaugate direct in app (interzis). $hint',
    );
  });

  // Cate un test per fisier, ca un raport de esec sa numeasca exact fisierul divergent.
  for (final name in const ['home.json', 'login.json', 'me.json', 'error.json']) {
    test('$name e identic in modulul Odoo si in app/test/contract', () {
      final module = File('$moduleDir/$name');
      final app = File('$appDir/$name');
      expect(module.existsSync(), isTrue, reason: 'Lipseste $moduleDir/$name. $hint');
      expect(app.existsSync(), isTrue, reason: 'Lipseste $appDir/$name. $hint');
      expect(
        app.readAsBytesSync(),
        orderedEquals(module.readAsBytesSync()),
        reason: 'Fixture-ul $name difera intre modulul Odoo si copia din app. $hint',
      );
    });
  }
}

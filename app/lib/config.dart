import 'package:flutter/foundation.dart';

/// Configurare de build. `API_BASE_URL` vine din `--dart-define`; pe emulatorul
/// Android `localhost` al Mac-ului este `10.0.2.2`, pe simulatorul iOS este `localhost`.
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8069',
  );

  /// Verificare de pornire: un build de release TREBUIE sa arate spre un `https`.
  ///
  /// Default-ul e cel de dezvoltare (`http://localhost:8069`), ca fluxul local sa
  /// mearga fara nicio ceremonie. Riscul e ca un build de release care uita
  /// `--dart-define=API_BASE_URL=...` compileaza, trece analiza, se publica si
  /// tinteste localhost in clar. Nu putem alege in schimb un default de productie,
  /// fiindca backendul nu e inca deployat si un default de productie ar face ca
  /// orice rulare de dezvoltare sa loveasca Odoo-ul real - exact ce interzice regula
  /// de siguranta a proiectului. Asa ca default-ul ramane cel de dezvoltare, iar
  /// release-ul gresit se opreste zgomotos, la lansare, cu un mesaj care spune ce
  /// lipseste.
  ///
  /// Parametrii exista doar ca testele sa poata verifica ambele ramuri fara sa
  /// construiasca efectiv in modul release.
  static void assertReleaseApiBaseUrl({
    String url = apiBaseUrl,
    bool releaseMode = kReleaseMode,
  }) {
    if (!releaseMode) return;
    if (Uri.tryParse(url)?.isScheme('https') ?? false) return;
    throw StateError(
      'Build de release configurat gresit: API_BASE_URL = "$url" nu foloseste https. '
      'Reconstruieste cu --dart-define=API_BASE_URL=https://<host-ul de productie>.',
    );
  }
}

/// Configurare de build. `API_BASE_URL` vine din `--dart-define`; pe emulatorul
/// Android `localhost` al Mac-ului este `10.0.2.2`, pe simulatorul iOS este `localhost`.
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8069',
  );
}

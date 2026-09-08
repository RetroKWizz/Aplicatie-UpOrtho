import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/config.dart';

void main() {
  group('AppConfig.assertReleaseApiBaseUrl', () {
    test('in debug/profil orice URL e acceptat, inclusiv localhost in clar', () {
      // Fluxul local (flutter run --dart-define=API_BASE_URL=http://localhost:8069)
      // nu trebuie stricat de garda.
      AppConfig.assertReleaseApiBaseUrl(url: 'http://localhost:8069', releaseMode: false);
      AppConfig.assertReleaseApiBaseUrl(url: 'http://10.0.2.2:8069', releaseMode: false);
    });

    test('in release un URL https trece', () {
      AppConfig.assertReleaseApiBaseUrl(url: 'https://uportho.ro', releaseMode: true);
    });

    test('in release default-ul de dezvoltare arunca, cu mesaj care spune ce lipseste', () {
      expect(
        () => AppConfig.assertReleaseApiBaseUrl(url: AppConfig.apiBaseUrl, releaseMode: true),
        throwsA(isA<StateError>()
            .having((e) => e.message, 'message', contains('API_BASE_URL'))
            .having((e) => e.message, 'message', contains('--dart-define'))),
      );
    });

    test('in release orice URL non-https arunca', () {
      for (final url in const ['http://uportho.ro', 'localhost:8069', '', 'ftp://uportho.ro']) {
        expect(
          () => AppConfig.assertReleaseApiBaseUrl(url: url, releaseMode: true),
          throwsA(isA<StateError>()),
          reason: 'URL-ul "$url" nu e https si ar trebui sa opreasca un build de release',
        );
      }
    });

    test('default-ul de compilare ramane cel de dezvoltare', () {
      // Daca cineva schimba default-ul, testul de mai sus ("default-ul de dezvoltare
      // arunca in release") ar putea deveni tautologic; il fixam explicit aici.
      expect(AppConfig.apiBaseUrl, 'http://localhost:8069');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/features/home/banner_link.dart';

void main() {
  group('externalBannerUri', () {
    test('accepta http si https si pastreaza URL-ul intreg', () {
      expect(externalBannerUri('https://uportho.ro/promo')?.toString(), 'https://uportho.ro/promo');
      expect(externalBannerUri('http://uportho.ro')?.toString(), 'http://uportho.ro');
      expect(
        externalBannerUri('https://uportho.ro/c/bracketi?utm=app#top')?.toString(),
        'https://uportho.ro/c/bracketi?utm=app#top',
      );
      expect(externalBannerUri('  https://uportho.ro/promo  ')?.toString(), 'https://uportho.ro/promo');
    });

    test('refuza null, sirul gol si sirul de spatii', () {
      // Uri.tryParse('') intoarce un Uri VALID, fara schema: garda pe null nu prindea nimic.
      expect(Uri.tryParse(''), isNotNull);
      expect(externalBannerUri(null), isNull);
      expect(externalBannerUri(''), isNull);
      expect(externalBannerUri('   '), isNull);
    });

    test('refuza orice alta schema decat http/https', () {
      for (final url in const [
        'tel:+40123456789',
        'mailto:contact@uportho.ro',
        'javascript:alert(1)',
        'file:///etc/passwd',
        'intent://scan/#Intent;scheme=zxing;end',
        'ftp://uportho.ro/fisier',
        'bancapp://transfer?suma=1000',
      ]) {
        expect(externalBannerUri(url), isNull, reason: 'schema din "$url" nu trebuie deschisa');
      }
    });

    test('refuza un URL http fara host', () {
      expect(externalBannerUri('http://'), isNull);
      expect(externalBannerUri('/promo'), isNull);
      expect(externalBannerUri('uportho.ro/promo'), isNull);
    });
  });
}

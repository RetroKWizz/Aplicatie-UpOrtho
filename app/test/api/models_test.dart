import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/home_response.dart';
import 'package:uportho_app/api/models/price.dart';
import 'package:uportho_app/api/models/user_profile.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/contract/$name').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('UserProfile decodes login.json', () {
    final user = UserProfile.fromJson(fixture('login.json')['user'] as Map<String, dynamic>);
    expect(user.id, 42);
    expect(user.email, 'app.test@uportho.ro');
    expect(user.partnerId, 77);
  });

  test('HomeResponse decodes home.json with nullable fields', () {
    final home = HomeResponse.fromJson(fixture('home.json'));
    expect(home.banners, hasLength(2));
    final hero = home.banners.first;
    expect(hero.placement, BannerPlacement.hero);
    expect(hero.link.type, BannerLinkType.category);
    expect(hero.link.categoryId, 12);
    // `image_url` e un string opac pentru aplicatie; serverul ii adauga un token
    // `?unique=` derivat din write_date, ca imaginea sa poata fi invalidata din cache.
    expect(hero.imageUrl, '/api/app/v1/banners/1/image?unique=3a1f9c2');
    final promo = home.banners.last;
    expect(promo.subtitle, isNull);
    expect(promo.imageUrl, isNull);
    expect(promo.link.type, BannerLinkType.none);
    expect(home.quickCategories.first.iconUrl, '/api/app/v1/categories/12/icon?unique=8be4d17');
    expect(home.quickCategories.last.iconUrl, isNull);
  });

  test('unknown placement or link type falls back safely', () {
    final json = fixture('home.json');
    (json['banners'] as List)[0]['placement'] = 'sidebar';
    (json['banners'] as List)[0]['link']['type'] = 'deeplink';
    final home = HomeResponse.fromJson(json);
    expect(home.banners.first.placement, BannerPlacement.promo);
    expect(home.banners.first.link.type, BannerLinkType.none);
  });

  test('Price decodes and exposes formatted only', () {
    final price = Price.fromJson({
      'amount': 149.9, 'currency': 'RON', 'formatted': '149,90 lei',
      'with_vat': true, 'list_amount': 189.9, 'discount_pct': 21,
    });
    expect(price.formatted, '149,90 lei');
    expect(price.discountPct, 21);
    expect(price.listAmount, 189.9);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/models/banner.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/home/home_controller.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  Map<String, dynamic> homeFixture() =>
      jsonDecode(File('test/contract/home.json').readAsStringSync()) as Map<String, dynamic>;

  setUp(() {
    transport = FakeTransport();
    container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
    ]);
  });

  tearDown(() => container.dispose());

  test('loads home from /home and splits hero vs promo', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));
    final home = await container.read(homeControllerProvider.future);
    expect(home.banners.where((b) => b.placement == BannerPlacement.hero), hasLength(1));
    expect(home.banners.where((b) => b.placement == BannerPlacement.promo), hasLength(1));
    expect(home.quickCategories, hasLength(2));
  });

  test('api error surfaces as AsyncError with ApiException', () async {
    transport.when('GET', '/api/app/v1/home', const ApiResponse(status: 500, json: null));
    await expectLater(container.read(homeControllerProvider.future), throwsA(isA<ApiException>()));
  });

  test('refresh refetches', () async {
    transport.when('GET', '/api/app/v1/home', ApiResponse(status: 200, json: homeFixture()));
    await container.read(homeControllerProvider.future);
    await container.read(homeControllerProvider.notifier).refresh();
    expect(transport.calls.where((c) => c.path == '/api/app/v1/home'), hasLength(2));
  });
}

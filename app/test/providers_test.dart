import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/providers.dart';

void main() {
  test('imageHeadersProvider builds Cookie header from session id', () async {
    final store = InMemorySessionStore();
    await store.write('abc123');
    final container = ProviderContainer(overrides: [sessionStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);

    final headers = await container.read(imageHeadersProvider.future);
    expect(headers, {'Cookie': 'session_id=abc123'});
  });

  test('imageHeadersProvider returns empty map when no session yet', () async {
    final container = ProviderContainer(overrides: [
      sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
    ]);
    addTearDown(container.dispose);

    final headers = await container.read(imageHeadersProvider.future);
    expect(headers, isEmpty);
  });
}

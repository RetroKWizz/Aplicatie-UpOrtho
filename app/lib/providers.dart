import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/dio_transport.dart';
import 'api/session_store.dart';
import 'config.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return ApiClient(DioTransport(AppConfig.apiBaseUrl, store), store, baseUrl: AppConfig.apiBaseUrl);
});

// Headerele HTTP necesare ca imaginile din bannere/categorii (rute Odoo auth='user')
// sa treaca de autentificare: acelasi cookie de sesiune pe care DioTransport il pune
// pe cererile API. CachedNetworkImage nu stie de SessionStore, deci ii dam headerele
// gata construite din acest provider.
// retry: null - vezi comentariul din home_controller.dart (Riverpod 3 reincearca
// implicit erorile de build() cu backoff de pana la ~38s; SessionStore.read() nu ar
// trebui sa arunce, dar daca o face, eroarea trebuie sa ajunga imediat, nu dupa backoff).
final imageHeadersProvider = FutureProvider<Map<String, String>>(
  (ref) async {
    final sessionId = await ref.watch(sessionStoreProvider).read();
    return sessionId == null ? const {} : {'Cookie': 'session_id=$sessionId'};
  },
  retry: (retryCount, error) => null,
);

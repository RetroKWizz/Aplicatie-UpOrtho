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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/dio_transport.dart';
import 'api/session_store.dart';
import 'config.dart';
import 'features/auth/auth_controller.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return ApiClient(DioTransport(AppConfig.apiBaseUrl, store), store, baseUrl: AppConfig.apiBaseUrl);
});

// Headerele HTTP necesare ca imaginile din bannere/categorii (rute Odoo auth='user')
// sa treaca de autentificare: acelasi cookie de sesiune pe care DioTransport il pune
// pe cererile API. CachedNetworkImage nu stie de SessionStore, deci ii dam headerele
// gata construite din acest provider.
//
// La fel ca homeControllerProvider (vezi comentariul din home_controller.dart),
// asteptam `authControllerProvider.future` inainte sa citim sesiunea, ca sa ne
// re-executam la fiecare tranzitie de autentificare (restaurare terminata, login,
// logout, schimbare de user). Fara acest watch, build() ar rula o singura data
// pentru toata durata containerului: pe o instalare noua, Home se monteaza inainte
// ca sesiunea sa fie confirmata, providerul e citit prima data fara sesiune, ramane
// cache-uit la {} pentru totdeauna, si imaginile nu s-ar mai incarca deloc in acea
// rulare a aplicatiei, nici dupa un login reusit ulterior.
//
// Nu lasam nicio eroare sa iasa din build(): o imagine lipsa nu merita o stare de
// eroare (widget-urile trateaza deja `httpHeaders == null` ca "fara header", iar
// CachedNetworkImage cade pe propriul placeholder), asa ca orice esec la citirea
// autentificarii sau a sesiunii degradeaza la headere goale in loc sa propage
// AsyncError. `retry: null` ramane ca plasa de siguranta suplimentara (Riverpod 3
// reincearca implicit un build() cazut, cu backoff exponential de pana la ~38s).
final imageHeadersProvider = FutureProvider<Map<String, String>>(
  (ref) async {
    try {
      await ref.watch(authControllerProvider.future);
      final sessionId = await ref.watch(sessionStoreProvider).read();
      return sessionId == null ? const {} : {'Cookie': 'session_id=$sessionId'};
    } catch (_) {
      return const {};
    }
  },
  retry: (retryCount, error) => null,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/home_response.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';
import 'home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => HomeRepository(ref.watch(apiClientProvider)));

// retry: null dezactiveaza reincercarea automata (Riverpod 3 reincearca implicit
// erorile de build() cu backoff exponential pana la ~38s); eroarea trebuie sa
// ajunga imediat la ecran, iar reincercarea e explicita, din butonul "Reincearca".
final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeResponse>(
  HomeController.new,
  retry: (retryCount, error) => null,
);

/// Stare pentru ecranul Acasa: un singur apel /home, cu refetch explicit la refresh.
class HomeController extends AsyncNotifier<HomeResponse> {
  @override
  Future<HomeResponse> build() async {
    // Home ramane montat permanent (StatefulShellRoute.indexedStack), deci nu se
    // poate baza pe un singur build() facut la pornirea aplicatiei - trebuie sa
    // reactioneze singur la schimbarile de autentificare:
    // - asteptam intai rezultatul restaurarii sesiunii (succes sau eroare), ca sa
    //   nu mai trimitem /home cat timp sesiunea e inca in curs de restaurare -
    //   asta era sursa 401-ului care ramanea blocat definitiv in AsyncError, din
    //   cauza lui `retry: null` de mai sus;
    // - `ref.watch(authControllerProvider.future)` (nu `ref.read`) leaga home de
    //   starea de autentificare pe toata durata de viata a providerului: orice
    //   build nou al lui authControllerProvider (restaurare terminata, login,
    //   logout, schimbare de user pe acelasi telefon) invalideaza automat
    //   homeControllerProvider si declanseaza un /home nou - fara reincercare
    //   manuala si fara ca datele contului anterior sa ramana pe ecran.
    await ref.watch(authControllerProvider.future);
    return ref.read(homeRepositoryProvider).fetch();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeRepositoryProvider).fetch());
  }
}

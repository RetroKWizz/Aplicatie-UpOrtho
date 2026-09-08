import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/home_response.dart';
import '../../providers.dart';
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
  Future<HomeResponse> build() => ref.read(homeRepositoryProvider).fetch();

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeRepositoryProvider).fetch());
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/user_profile.dart';
import '../../providers.dart';
import 'auth_repository.dart';

sealed class AuthState {
  const AuthState();
  const factory AuthState.signedOut() = SignedOut;
  const factory AuthState.signedIn(UserProfile user) = SignedIn;
}

class SignedOut extends AuthState {
  const SignedOut();
  @override
  bool operator ==(Object other) => other is SignedOut;
  @override
  int get hashCode => 0;
}

class SignedIn extends AuthState {
  const SignedIn(this.user);
  final UserProfile user;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

// retry: null dezactiveaza reincercarea automata (Riverpod 3 reincearca implicit
// erorile de build() cu backoff exponential pana la ~38s); userul trebuie sa
// ajunga rapid la ecranul de login, nu sa astepte un backoff cand build() da eroare
// (ex. fara conexiune, cu sesiune salvata) inainte ca router-ul sa il redirectioneze.
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
  retry: (retryCount, error) => null,
);

class AuthController extends AsyncNotifier<AuthState> {
  String? lastErrorMessage;

  @override
  Future<AuthState> build() async {
    final user = await ref.read(authRepositoryProvider).restore();
    return user == null ? const AuthState.signedOut() : AuthState.signedIn(user);
  }

  Future<void> login(String login, String password) async {
    lastErrorMessage = null;
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).login(login.trim(), password);
      state = AsyncData(AuthState.signedIn(user));
    } on ApiException catch (e, st) {
      lastErrorMessage = e.message;
      state = AsyncError(e, st);
    } catch (e, st) {
      lastErrorMessage = 'Nu s-a putut contacta serverul. Verifica conexiunea.';
      state = AsyncError(e, st);
    }
  }

  /// Sesiunea serverului a expirat in timpul folosirii aplicatiei: ApiClient a primit
  /// 401 pe o cerere obisnuita si si-a sters sesiunea locala. Trecem in SignedOut, iar
  /// `refreshListenable` al routerului duce userul la login (spec §8).
  ///
  /// Ne miscam DOAR dintr-o stare SignedIn. Asta exclude, prin constructie, cele doua
  /// cazuri care nu sunt expirari de sesiune: un login cu date gresite (starea e
  /// AsyncLoading/AsyncError, iar 401-ul are deja mesajul lui) si restaurarea de la
  /// pornire cu o sesiune veche (suntem in build(), unde nu avem voie sa scriem state).
  void onSessionExpired() {
    if (state.value is! SignedIn) return;
    lastErrorMessage = null;
    state = const AsyncData(AuthState.signedOut());
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.signedOut());
  }
}

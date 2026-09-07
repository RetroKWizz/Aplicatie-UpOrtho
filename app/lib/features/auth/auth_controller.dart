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

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

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

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.signedOut());
  }
}

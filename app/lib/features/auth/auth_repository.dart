import '../../api/api_client.dart';
import '../../api/api_exception.dart';
import '../../api/models/user_profile.dart';

/// Stie cum vorbeste cu serverul pentru autentificare; nu tine stare.
class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  /// Profilul userului daca exista o sesiune valida, altfel null (sesiune lipsa sau expirata).
  Future<UserProfile?> restore() async {
    if (!await _api.hasSession()) return null;
    try {
      final body = await _api.get('/me');
      return UserProfile.fromJson(body['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null;
      rethrow;
    }
  }

  Future<UserProfile> login(String login, String password) async {
    final body = await _api.login(login, password);
    return UserProfile.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<void> logout() => _api.logout();
}

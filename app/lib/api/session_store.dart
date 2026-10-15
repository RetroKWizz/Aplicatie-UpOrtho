import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String sessionId);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();
  static const _key = 'odoo_session_id';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String sessionId) => _storage.write(key: _key, value: sessionId);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class InMemorySessionStore implements SessionStore {
  /// `initial` porneste depozitul cu o sesiune deja salvata. Testele care verifica
  /// un CLIENT au nevoie de ea: de cand catalogul e public, providerii de cont nu mai
  /// cer serverul fara sesiune, iar un test fara sesiune verifica fara sa stie un
  /// vizitator.
  InMemorySessionStore({String? initial}) : _value = initial;

  String? _value;
  @override
  Future<String?> read() async => _value;
  @override
  Future<void> write(String sessionId) async => _value = sessionId;
  @override
  Future<void> clear() async => _value = null;
}

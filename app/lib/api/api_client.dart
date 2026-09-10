import 'api_exception.dart';
import 'api_transport.dart';
import 'session_store.dart';

/// Clientul contractului /api/app/v1. Nu stie de Odoo; stie doar forma raspunsurilor.
class ApiClient {
  ApiClient(this._transport, this._sessions, {required this.baseUrl, this.onUnauthorized});

  static const prefix = '/api/app/v1';
  final ApiTransport _transport;
  final SessionStore _sessions;
  final String baseUrl;

  /// Semnal de "sesiune expirata": un 401 pe o cerere obisnuita, dupa ce sesiunea
  /// locala a fost stearsa. Cine asculta (AuthController) trece aplicatia in
  /// SignedOut, iar routerul redirectioneaza la login.
  ///
  /// Nu se declanseaza pentru `login()`: acolo 401 inseamna date de autentificare
  /// gresite - un esec asteptat, cu mesajul lui, nu o expirare de sesiune. `login()`
  /// vorbeste direct cu transportul tocmai ca sa nu treaca prin acest drum.
  final void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  /// Ca `get`, dar pentru endpointuri al caror raspuns e un array JSON la nivelul
  /// radacinii (contractul `GET /categories`), nu un obiect.
  Future<List<dynamic>> getList(String path) async {
    final response = await _transport.send('GET', '$prefix$path');
    if (response.status == 401) {
      await _sessions.clear();
      onUnauthorized?.call();
    }
    return _listBodyOrThrow(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<void> delete(String path) async {
    await _request('DELETE', path);
  }

  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await _transport.send('POST', '$prefix/auth/login',
        body: {'login': login, 'password': password});
    final body = _bodyOrThrow(response);
    if (response.sessionCookie != null) {
      await _sessions.write(response.sessionCookie!);
    }
    return body;
  }

  Future<void> logout() async {
    try {
      await _transport.send('POST', '$prefix/auth/logout');
    } catch (_) {
      // Sesiunea locala se sterge oricum; serverul o expira singur.
    } finally {
      await _sessions.clear();
    }
  }

  Future<bool> hasSession() async => (await _sessions.read()) != null;

  /// Descarca in `savePath` continutul unei rute de fisier a contractului
  /// (documentele de produs). `url` e URL-ul complet primit de la server — el
  /// contine deja prefixul `/api/app/v1`, deci nu se mai adauga aici.
  ///
  /// Trece prin acelasi transport ca restul cererilor, deci poarta cookie-ul de
  /// sesiune si header-ul de aplicatie; un 401 stinge sesiunea si anunta expirarea
  /// exact ca pe orice alt endpoint. Fisierul ramane pe disc, nu in memorie.
  Future<void> downloadTo(String url, String savePath) async {
    final response = await _transport.download(url, savePath);
    if (response.status == 401) {
      await _sessions.clear();
      onUnauthorized?.call();
    }
    if (response.status >= 200 && response.status < 300) return;
    _throwError(response);
  }

  String absoluteUrl(String path) => path.startsWith('http') ? path : '$baseUrl$path';

  Future<Map<String, dynamic>> _request(String method, String path, {Map<String, dynamic>? body}) async {
    final response = await _transport.send(method, '$prefix$path', body: body);
    if (response.status == 401) {
      await _sessions.clear();
      onUnauthorized?.call();
    }
    return _bodyOrThrow(response);
  }

  Map<String, dynamic> _bodyOrThrow(ApiResponse response) {
    if (response.status >= 200 && response.status < 300) {
      final data = response.json;
      return data is Map<String, dynamic> ? data : const {};
    }
    _throwError(response);
  }

  List<dynamic> _listBodyOrThrow(ApiResponse response) {
    if (response.status >= 200 && response.status < 300) {
      final data = response.json;
      return data is List ? data : const [];
    }
    _throwError(response);
  }

  /// Forma de eroare e mereu un obiect (`{"error": {...}}`), indiferent daca
  /// raspunsul de succes al endpointului e un obiect sau un array.
  Never _throwError(ApiResponse response) {
    final data = response.json;
    final error = data is Map<String, dynamic> ? data['error'] : null;
    if (error is Map<String, dynamic>) {
      throw ApiException(
        status: response.status,
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String? ?? 'Eroare necunoscuta.',
        details: (error['details'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
    throw ApiException(
      status: response.status,
      code: response.status == 401 ? 'unauthorized' : 'internal_error',
      message: 'A aparut o eroare. Incearca din nou.',
    );
  }
}

import 'package:dio/dio.dart';

import 'api_transport.dart';
import 'session_store.dart';

/// Transport real: Dio + header X-UpOrtho-App + cookie de sesiune din SessionStore.
class DioTransport implements ApiTransport {
  DioTransport(String baseUrl, this._sessions)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {'X-UpOrtho-App': '1', 'Accept': 'application/json'},
          validateStatus: (_) => true, // codurile de eroare le interpreteaza ApiClient
          responseType: ResponseType.json,
        ));

  final Dio _dio;
  final SessionStore _sessions;

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) async {
    final sessionId = await _sessions.read();
    final response = await _dio.request<dynamic>(
      path,
      data: body,
      options: Options(
        method: method,
        headers: {if (sessionId != null) 'Cookie': 'session_id=$sessionId'},
        contentType: body == null ? null : Headers.jsonContentType,
      ),
    );
    return ApiResponse(
      status: response.statusCode ?? 0,
      json: response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null,
      sessionCookie: _extractSessionId(response.headers['set-cookie']),
    );
  }

  static String? _extractSessionId(List<String>? setCookies) {
    if (setCookies == null) return null;
    for (final cookie in setCookies) {
      final match = RegExp(r'(?:^|;\s*)session_id=([^;]+)').firstMatch(cookie);
      if (match != null) return match.group(1);
    }
    return null;
  }
}

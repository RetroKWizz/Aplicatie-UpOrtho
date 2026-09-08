import 'package:dio/dio.dart';

import 'api_exception.dart';
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
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(
          method: method,
          headers: {if (sessionId != null) 'Cookie': 'session_id=$sessionId'},
          contentType: body == null ? null : Headers.jsonContentType,
        ),
      );
      return _toApiResponse(response);
    } on DioException catch (e) {
      // validateStatus accepta orice cod HTTP, deci un raspuns prezent inseamna
      // ca serverul chiar a raspuns (ex. eroare de decodare) si mergem pe calea normala.
      final response = e.response;
      if (response != null) {
        return _toApiResponse(response);
      }
      // Fara raspuns: timeout, DNS picat, conexiune intrerupta - defect de retea real,
      // status 0 inseamna "niciun raspuns HTTP primit".
      throw const ApiException(
        status: 0,
        code: 'network_error',
        message: 'Nu s-a putut contacta serverul. Verifica conexiunea.',
      );
    }
  }

  ApiResponse _toApiResponse(Response<dynamic> response) {
    // Corpul poate fi un obiect JSON (majoritatea endpointurilor) sau un array JSON
    // la nivelul radacinii (`GET /categories`) - orice altceva (text simplu, gol)
    // e tratat ca "fara corp decodabil", niciodata propagat ca atare.
    final data = response.data;
    return ApiResponse(
      status: response.statusCode ?? 0,
      json: (data is Map<String, dynamic> || data is List) ? data : null,
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

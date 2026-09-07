/// Raspuns brut de la server: cod HTTP, corp JSON (daca a putut fi decodat) si
/// valoarea cookie-ului `session_id` daca serverul a trimis unul nou.
class ApiResponse {
  const ApiResponse({required this.status, this.json, this.sessionCookie});
  final int status;
  final Map<String, dynamic>? json;
  final String? sessionCookie;
}

/// Singurul punct prin care aplicatia trimite HTTP. Implementarea reala foloseste Dio;
/// testele folosesc un fake.
abstract class ApiTransport {
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body});
}

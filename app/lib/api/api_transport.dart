/// Raspuns brut de la server: cod HTTP, corp JSON (daca a putut fi decodat) si
/// valoarea cookie-ului `session_id` daca serverul a trimis unul nou.
///
/// `json` e `dynamic` (nu `Map<String, dynamic>?`) fiindca nu toate endpointurile
/// v1 raspund cu un obiect — `GET /categories` raspunde cu un array JSON la nivelul
/// radacinii. `ApiClient.get`/`getList` fac garda de tip potrivita fiecarui contract.
class ApiResponse {
  const ApiResponse({required this.status, this.json, this.sessionCookie});
  final int status;
  final dynamic json;
  final String? sessionCookie;
}

/// Singurul punct prin care aplicatia trimite HTTP. Implementarea reala foloseste Dio;
/// testele folosesc un fake.
abstract class ApiTransport {
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body});
}

import 'package:uportho_app/api/api_transport.dart';

class RecordedCall {
  RecordedCall(this.method, this.path, this.body);
  final String method;
  final String path;
  final Map<String, dynamic>? body;
}

/// Transport de test: raspunsuri pre-inregistrate pe (metoda, cale), plus jurnalul apelurilor.
class FakeTransport implements ApiTransport {
  final Map<String, ApiResponse> responses = {};
  final List<RecordedCall> calls = [];

  void when(String method, String path, ApiResponse response) {
    responses['$method $path'] = response;
  }

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) async {
    calls.add(RecordedCall(method, path, body));
    final response = responses['$method $path'];
    if (response == null) {
      throw StateError('Fara raspuns inregistrat pentru $method $path');
    }
    return response;
  }
}

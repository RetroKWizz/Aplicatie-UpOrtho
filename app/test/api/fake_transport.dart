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
  final Map<String, Object> errors = {};
  final List<RecordedCall> calls = [];

  void when(String method, String path, ApiResponse response) {
    responses['$method $path'] = response;
  }

  /// Inregistreaza un esec pentru (metoda, cale): send() arunca `error` in loc
  /// sa returneze un raspuns. Simuleaza defecte de transport reale (retea cazuta,
  /// timeout) pe care DioTransport le-ar traduce/propaga, fara a deschide un socket.
  void whenThrows(String method, String path, Object error) {
    errors['$method $path'] = error;
  }

  @override
  Future<ApiResponse> send(String method, String path, {Map<String, dynamic>? body}) async {
    calls.add(RecordedCall(method, path, body));
    final key = '$method $path';
    final error = errors[key];
    if (error != null) {
      throw error;
    }
    final response = responses[key];
    if (response == null) {
      throw StateError('Fara raspuns inregistrat pentru $method $path');
    }
    return response;
  }
}

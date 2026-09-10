import 'dart:async';
import 'dart:io';

import 'package:uportho_app/api/api_transport.dart';

class RecordedCall {
  RecordedCall(this.method, this.path, this.body);
  final String method;
  final String path;
  final Map<String, dynamic>? body;
}

/// O descarcare ceruta transportului: ce URL si in ce fisier.
class RecordedDownload {
  RecordedDownload(this.url, this.savePath);
  final String url;
  final String savePath;
}

/// Transport de test: raspunsuri pre-inregistrate pe (metoda, cale), plus jurnalul apelurilor.
class FakeTransport implements ApiTransport {
  final Map<String, ApiResponse> responses = {};
  final Map<String, Object> errors = {};
  final List<RecordedCall> calls = [];
  final List<RecordedDownload> downloads = [];

  final Map<String, ApiResponse> _downloadResponses = {};
  final Map<String, List<int>> _downloadBytes = {};
  final Map<String, Completer<void>> _downloadGates = {};

  /// Ce "serveste" transportul la o descarcare de pe `url`: codul HTTP (plus
  /// eventualul corp de eroare) si, la succes, octetii care ajung pe disc — exact
  /// ce face DioTransport real, care scrie corpul in fisier si nu-l intoarce.
  ///
  /// `gate`, cand e dat, tine descarcarea in aer pana e completat: asa poate un
  /// test sa apese a doua oara exact cat timp prima cerere inca nu a raspuns.
  void whenDownload(
    String url, {
    ApiResponse response = const ApiResponse(status: 200),
    List<int> bytes = const [],
    Completer<void>? gate,
  }) {
    _downloadResponses[url] = response;
    _downloadBytes[url] = bytes;
    if (gate != null) _downloadGates[url] = gate;
  }

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

  @override
  Future<ApiResponse> download(String url, String savePath) async {
    downloads.add(RecordedDownload(url, savePath));
    final error = errors['GET $url'];
    if (error != null) throw error;
    final response = _downloadResponses[url];
    if (response == null) {
      throw StateError('Fara raspuns de descarcare inregistrat pentru $url');
    }
    final gate = _downloadGates[url];
    if (gate != null) await gate.future;
    if (response.status >= 200 && response.status < 300) {
      // Fisierul chiar apare pe disc, ca la transportul real: testele verifica
      // apoi ca vizualizatorului i se da o cale existenta, nu un sir inventat.
      final file = File(savePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(_downloadBytes[url] ?? const []);
    }
    return response;
  }
}

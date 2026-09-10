import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_exception.dart';
import 'package:uportho_app/api/dio_transport.dart';
import 'package:uportho_app/api/session_store.dart';

/// Ce a primit efectiv serverul. Headerele se copiaza pe loc, cat timp cererea e
/// inca deschisa.
class _Received {
  _Received(this.method, this.path, this.headers, this.body);
  final String method;
  final String path;
  final Map<String, List<String>> headers;
  final String body;

  String? header(String name) => headers[name.toLowerCase()]?.join(', ');
}

void main() {
  // Toate celelalte teste Dart trec prin FakeTransport, deci nimic nu verifica
  // transportul real: nici ca header-ul X-UpOrtho-App chiar pleaca (antetul pe care
  // se sprijina tot argumentul anti-CSRF al API-ului), nici forma cookie-ului de
  // sesiune, nici parsarea lui Set-Cookie. Aici pornim un server HTTP pe loopback si
  // ne uitam la ce ajunge pe fir.
  late HttpServer server;
  late List<_Received> received;
  late InMemorySessionStore store;
  late DioTransport transport;

  /// Dosar propriu pentru fisierele descarcate in teste, sters la final.
  late Directory downloadDir;

  /// Ce raspunde serverul la urmatoarea cerere.
  late int responseStatus;
  late Object? responseBody;
  late List<int>? responseBytes;
  late List<String> responseCookies;

  setUp(() async {
    received = [];
    store = InMemorySessionStore();
    responseStatus = 200;
    responseBody = {'ok': true};
    responseBytes = null;
    responseCookies = [];

    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final headers = <String, List<String>>{};
      request.headers.forEach((name, values) => headers[name.toLowerCase()] = values);
      final body = await utf8.decoder.bind(request).join();
      received.add(_Received(request.method, request.uri.path, headers, body));

      final response = request.response;
      response.statusCode = responseStatus;
      for (final cookie in responseCookies) {
        response.headers.add('set-cookie', cookie);
      }
      if (responseBytes != null) {
        // Corp binar (un document de produs), nu JSON: exact ce serveste ruta
        // `/products/<id>/documents/<id>`.
        response.headers.contentType = ContentType('application', 'pdf');
        response.add(responseBytes!);
      } else if (responseBody != null) {
        response.headers.contentType = ContentType.json;
        response.write(jsonEncode(responseBody));
      }
      await response.close();
    });

    transport = DioTransport('http://127.0.0.1:${server.port}', store);

    downloadDir = Directory.systemTemp.createTempSync('uportho-download-test');
  });

  tearDown(() async {
    await server.close(force: true);
    if (downloadDir.existsSync()) downloadDir.deleteSync(recursive: true);
  });

  group('header-ul de aplicatie', () {
    test('X-UpOrtho-App: 1 pleaca pe orice cerere, indiferent de metoda', () async {
      await transport.send('GET', '/api/app/v1/home');
      await transport.send('POST', '/api/app/v1/auth/login', body: {'login': 'a@b.ro'});
      await transport.send('DELETE', '/api/app/v1/devices/tok');

      expect(received, hasLength(3));
      for (final request in received) {
        expect(request.header('x-uportho-app'), '1',
            reason: 'lipseste X-UpOrtho-App pe ${request.method} ${request.path}');
      }
      expect(received.map((r) => r.method), ['GET', 'POST', 'DELETE']);
    });

    test('corpul unui POST pleaca serializat JSON', () async {
      await transport.send('POST', '/api/app/v1/auth/login',
          body: {'login': 'a@b.ro', 'password': 'pw'});
      expect(jsonDecode(received.single.body), {'login': 'a@b.ro', 'password': 'pw'});
      expect(received.single.header('content-type'), contains('application/json'));
    });
  });

  group('cookie-ul de sesiune trimis', () {
    test('e atasat ca `session_id=<valoare>` cand exista o sesiune stocata', () async {
      await store.write('8f2c4a1b');
      await transport.send('GET', '/api/app/v1/me');
      expect(received.single.header('cookie'), 'session_id=8f2c4a1b');
    });

    test('lipseste complet cand nu exista sesiune stocata', () async {
      await transport.send('GET', '/api/app/v1/home');
      expect(received.single.headers.containsKey('cookie'), isFalse);
    });

    test('se reciteste din store la fiecare cerere', () async {
      await transport.send('GET', '/api/app/v1/home');
      await store.write('dupa-login');
      await transport.send('GET', '/api/app/v1/home');
      await store.clear();
      await transport.send('GET', '/api/app/v1/home');

      expect(received[0].headers.containsKey('cookie'), isFalse);
      expect(received[1].header('cookie'), 'session_id=dupa-login');
      expect(received[2].headers.containsKey('cookie'), isFalse);
    });
  });

  group('extragerea session_id din Set-Cookie', () {
    test('dintr-un Set-Cookie realist de Odoo, cu atribute', () async {
      responseCookies = [
        'session_id=7a19c3f0b2; Expires=Mon, 15 Sep 2026 08:00:00 GMT; Max-Age=604800; '
            'HttpOnly; Path=/; SameSite=Lax',
      ];
      final response = await transport.send('POST', '/api/app/v1/auth/login');
      expect(response.sessionCookie, '7a19c3f0b2');
    });

    test('cand serverul intoarce mai multe cookie-uri', () async {
      responseCookies = [
        'frontend_lang=ro_RO; Path=/',
        'session_id=7a19c3f0b2; HttpOnly; Path=/; SameSite=Lax',
        'cids=1; Path=/',
      ];
      final response = await transport.send('POST', '/api/app/v1/auth/login');
      expect(response.sessionCookie, '7a19c3f0b2');
    });

    test('nu confunda un alt cookie al carui nume se termina in session_id', () async {
      responseCookies = ['other_session_id=nu-asta; Path=/'];
      final response = await transport.send('POST', '/api/app/v1/auth/login');
      expect(response.sessionCookie, isNull);
    });

    test('e null cand serverul nu trimite niciun cookie', () async {
      final response = await transport.send('GET', '/api/app/v1/home');
      expect(response.sessionCookie, isNull);
    });
  });

  group('raspunsuri si defecte', () {
    test('un cod de eroare ajunge intact la ApiClient, nu ca exceptie', () async {
      responseStatus = 401;
      responseBody = {
        'error': {'code': 'unauthorized', 'message': 'Trebuie sa te autentifici.', 'details': {}}
      };
      final response = await transport.send('GET', '/api/app/v1/me');
      expect(response.status, 401);
      expect(response.json?['error']['code'], 'unauthorized');
    });

    test('un corp care nu e obiect JSON lasa json null, fara sa arunce', () async {
      responseStatus = 204;
      responseBody = null;
      final response = await transport.send('DELETE', '/api/app/v1/devices/tok');
      expect(response.status, 204);
      expect(response.json, isNull);
    });

    test('descarcarea unui document duce sesiunea si header-ul de aplicatie pe fir',
        () async {
      // Motivul intregii rute: browserul telefonului nu duce cookie-ul de sesiune,
      // deci fisierul trebuie adus de aplicatie, cu aceleasi headere ca orice alta
      // cerere autentificata.
      await store.write('8f2c4a1b');
      responseBytes = const [37, 80, 68, 70, 45, 49, 46, 55]; // "%PDF-1.7"
      final file = File('${downloadDir.path}/fisa.pdf');

      final response =
          await transport.download('/api/app/v1/products/101/documents/4821', file.path);

      expect(response.status, 200);
      expect(received.single.header('cookie'), 'session_id=8f2c4a1b');
      expect(received.single.header('x-uportho-app'), '1');
      expect(received.single.path, '/api/app/v1/products/101/documents/4821');
      expect(file.readAsBytesSync(), responseBytes);
    });

    test('un cod de eroare nu ajunge niciodata pe disc ca fisier', () async {
      // Un 401 salvat ca "document" s-ar deschide in vizualizator ca un fisier
      // corupt de cateva zeci de octeti - mai rau decat un mesaj de eroare.
      responseStatus = 401;
      responseBody = {
        'error': {'code': 'unauthorized', 'message': 'Trebuie sa te autentifici.', 'details': {}}
      };
      final file = File('${downloadDir.path}/refuzat.pdf');

      final response =
          await transport.download('/api/app/v1/products/101/documents/4821', file.path);

      expect(response.status, 401);
      expect(response.json?['error']['code'], 'unauthorized');
      expect(file.existsSync(), isFalse);
    });

    test('fara server la capat, o descarcare da tot ApiException(network_error)', () async {
      final port = server.port;
      await server.close(force: true);
      final orphan = DioTransport('http://127.0.0.1:$port', store);
      await expectLater(
        orphan.download('/api/app/v1/products/101/documents/4821',
            '${downloadDir.path}/nimic.pdf'),
        throwsA(isA<ApiException>()
            .having((e) => e.status, 'status', 0)
            .having((e) => e.code, 'code', 'network_error')),
      );
    });

    test('fara server la capat, iese ApiException(network_error) cu status 0', () async {
      final port = server.port;
      await server.close(force: true);
      final orphan = DioTransport('http://127.0.0.1:$port', store);
      await expectLater(
        orphan.send('GET', '/api/app/v1/home'),
        throwsA(isA<ApiException>()
            .having((e) => e.status, 'status', 0)
            .having((e) => e.code, 'code', 'network_error')),
      );
    });
  });
}

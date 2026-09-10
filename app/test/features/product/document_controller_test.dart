import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/api_client.dart';
import 'package:uportho_app/api/api_transport.dart';
import 'package:uportho_app/api/session_store.dart';
import 'package:uportho_app/features/product/document_controller.dart';
import 'package:uportho_app/features/product/document_files.dart';
import 'package:uportho_app/providers.dart';

import '../../api/fake_transport.dart';

/// Vizualizatorul de sistem, inlocuit: retine calea primita si raspunde ce i se
/// cere. Nu atinge platforma - `open_filex` chiar ar lansa o aplicatie.
class FakeOpener implements DocumentOpener {
  FakeOpener([this.outcome = DocumentOpenOutcome.opened]);

  DocumentOpenOutcome outcome;
  final List<String> opened = [];

  @override
  Future<DocumentOpenOutcome> open(String path) async {
    opened.add(path);
    return outcome;
  }
}

/// Lasa descarcarea pornita sa ajunga pana la transport: intre apasare si cerere
/// sta pregatirea fisierului (dosarul temporar), care e ea insasi asincrona.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  const url = 'http://x/api/app/v1/products/101/documents/4821';
  const otherUrl = 'http://x/api/app/v1/products/101/documents/4822';
  const pdfBytes = [37, 80, 68, 70, 45, 49, 46, 55]; // "%PDF-1.7"

  late Directory tempRoot;
  late FakeTransport transport;
  late FakeOpener opener;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('uportho-docs-test');
    transport = FakeTransport();
    opener = FakeOpener();
  });

  tearDown(() {
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  /// Container cu transportul si vizualizatorul de test, dar cu ApiClient-ul si
  /// depozitul REALE: descarcarea trece prin acelasi client ca orice alta cerere
  /// autentificata, iar calea fisierului e calculata de codul de productie.
  ProviderContainer makeContainer() {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          ApiClient(transport, InMemorySessionStore(), baseUrl: 'http://x')),
      documentStorageProvider.overrideWithValue(
          TempDocumentStorage(temporaryDirectory: () async => tempRoot)),
      documentOpenerProvider.overrideWithValue(opener),
    ]);
    addTearDown(container.dispose);
    // Providerul e autoDispose: fara un ascultator, Riverpod l-ar arunca in prima
    // pauza dintre doua `await` si scrierea de stare de dupa ar exploda.
    container.listen(documentsControllerProvider(101), (_, _) {});
    return container;
  }

  test('documentul se descarca prin clientul aplicatiei si ajunge la vizualizator',
      () async {
    transport.whenDownload(url, bytes: pdfBytes);
    final container = makeContainer();

    await container
        .read(documentsControllerProvider(101).notifier)
        .open(url: url, fileName: 'Fisa tehnica.pdf');

    // Cererea a plecat pe drumul obisnuit al aplicatiei (transportul care pune
    // cookie-ul de sesiune si X-UpOrtho-App), catre URL-ul primit de la server.
    expect(transport.downloads.single.url, url);

    // Vizualizatorul a primit o cale reala, cu fisierul chiar scris pe disc si cu
    // extensia pastrata - fara ea, telefonul n-ar sti ce aplicatie sa deschida.
    final path = opener.opened.single;
    expect(path, transport.downloads.single.savePath);
    expect(path, startsWith(tempRoot.path));
    expect(path, endsWith('.pdf'));
    expect(File(path).readAsBytesSync(), pdfBytes);

    final state = container.read(documentsControllerProvider(101));
    expect(state.error, isNull);
    expect(state.busy, isEmpty);
  });

  test('doua documente cu acelasi nume de fisier nu se suprascriu', () async {
    transport.whenDownload(url, bytes: const [1, 2, 3]);
    transport.whenDownload(otherUrl, bytes: const [9, 9, 9]);
    final container = makeContainer();
    final controller = container.read(documentsControllerProvider(101).notifier);

    await controller.open(url: url, fileName: 'certificat.pdf');
    await controller.open(url: otherUrl, fileName: 'certificat.pdf');

    expect(opener.opened, hasLength(2));
    expect(opener.opened.first, isNot(opener.opened.last));
    expect(File(opener.opened.first).readAsBytesSync(), [1, 2, 3]);
    expect(File(opener.opened.last).readAsBytesSync(), [9, 9, 9]);
  });

  test('a doua apasare pe acelasi document, cat timp prima e in aer, nu face nimic',
      () async {
    final gate = Completer<void>();
    transport.whenDownload(url, bytes: pdfBytes, gate: gate);
    final container = makeContainer();
    final controller = container.read(documentsControllerProvider(101).notifier);

    final first = controller.open(url: url, fileName: 'fisa.pdf');
    await settle();
    expect(container.read(documentsControllerProvider(101)).busy, contains(url),
        reason: 'randul trebuie sa arate ca lucreaza');
    expect(transport.downloads, hasLength(1), reason: 'prima descarcare e in aer');

    // A doua apasare, exact cat timp descarcarea e in aer.
    await controller.open(url: url, fileName: 'fisa.pdf');
    expect(transport.downloads, hasLength(1), reason: 'o singura descarcare');

    gate.complete();
    await first;
    expect(transport.downloads, hasLength(1));
    expect(opener.opened, hasLength(1));
    expect(container.read(documentsControllerProvider(101)).busy, isEmpty);
  });

  test('un alt document poate porni cat timp primul se descarca', () async {
    final gate = Completer<void>();
    transport.whenDownload(url, bytes: pdfBytes, gate: gate);
    transport.whenDownload(otherUrl, bytes: pdfBytes);
    final container = makeContainer();
    final controller = container.read(documentsControllerProvider(101).notifier);

    final first = controller.open(url: url, fileName: 'fisa.pdf');
    await settle();
    await controller.open(url: otherUrl, fileName: 'certificat.pdf');

    expect(transport.downloads, hasLength(2));
    expect(container.read(documentsControllerProvider(101)).busy, [url],
        reason: 'doar primul mai lucreaza');
    gate.complete();
    await first;
    expect(container.read(documentsControllerProvider(101)).busy, isEmpty);
  });

  test('o descarcare esuata arata mesajul serverului si elibereaza randul', () async {
    transport.whenDownload(url,
        response: const ApiResponse(status: 404, json: {
          'error': {'code': 'not_found', 'message': 'Documentul nu exista.', 'details': {}}
        }));
    final container = makeContainer();

    await container
        .read(documentsControllerProvider(101).notifier)
        .open(url: url, fileName: 'fisa.pdf');

    final state = container.read(documentsControllerProvider(101));
    expect(state.error, 'Documentul nu exista.');
    expect(state.busy, isEmpty);
    expect(opener.opened, isEmpty, reason: 'nu se deschide nimic daca n-a venit nimic');
  });

  test('o cadere de retea nu ramane fara mesaj', () async {
    transport.whenThrows('GET', url, StateError('socket inchis'));
    final container = makeContainer();

    await container
        .read(documentsControllerProvider(101).notifier)
        .open(url: url, fileName: 'fisa.pdf');

    final state = container.read(documentsControllerProvider(101));
    expect(state.error, isNotNull);
    expect(state.error, contains('Nu s-a putut descarca'));
    expect(state.busy, isEmpty);
  });

  test('telefonul fara aplicatie pentru acel tip de fisier primeste un mesaj', () async {
    transport.whenDownload(url, bytes: pdfBytes);
    opener.outcome = DocumentOpenOutcome.noViewer;
    final container = makeContainer();

    await container
        .read(documentsControllerProvider(101).notifier)
        .open(url: url, fileName: 'fisa.dwg');

    expect(container.read(documentsControllerProvider(101)).error,
        contains('nicio aplicatie'));
  });

  test('o deschidere esuata din alt motiv are si ea mesaj', () async {
    transport.whenDownload(url, bytes: pdfBytes);
    opener.outcome = DocumentOpenOutcome.failed;
    final container = makeContainer();

    await container
        .read(documentsControllerProvider(101).notifier)
        .open(url: url, fileName: 'fisa.pdf');

    expect(container.read(documentsControllerProvider(101)).error,
        contains('Nu s-a putut deschide'));
  });

  test('mesajul de eroare dispare la incercarea urmatoare, reusita', () async {
    transport.whenDownload(url,
        response: const ApiResponse(status: 500, json: {
          'error': {'code': 'internal_error', 'message': 'Eroare interna.', 'details': {}}
        }));
    final container = makeContainer();
    final controller = container.read(documentsControllerProvider(101).notifier);

    await controller.open(url: url, fileName: 'fisa.pdf');
    expect(container.read(documentsControllerProvider(101)).error, isNotNull);

    transport.whenDownload(url, bytes: pdfBytes);
    await controller.open(url: url, fileName: 'fisa.pdf');
    expect(container.read(documentsControllerProvider(101)).error, isNull);
  });

  group('numele fisierului scris pe disc', () {
    test('un nume cu caractere de cale nu iese din dosarul aplicatiei', () async {
      transport.whenDownload(url, bytes: pdfBytes);
      final container = makeContainer();

      await container
          .read(documentsControllerProvider(101).notifier)
          .open(url: url, fileName: '../../../etc/passwd.pdf');

      final path = opener.opened.single;
      expect(path, startsWith(tempRoot.path));
      expect(File(path).parent.path, startsWith(tempRoot.path));
      expect(path, isNot(contains('..')));
      expect(File(path).existsSync(), isTrue);
    });

    test('un nume gol nu lasa fisierul fara nume', () async {
      transport.whenDownload(url, bytes: pdfBytes);
      final container = makeContainer();

      await container
          .read(documentsControllerProvider(101).notifier)
          .open(url: url, fileName: '   ');

      expect(File(opener.opened.single).existsSync(), isTrue);
      expect(opener.opened.single.split('/').last, isNotEmpty);
    });
  });
}

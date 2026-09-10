import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../providers.dart';
import 'document_files.dart';

final documentStorageProvider = Provider<DocumentStorage>((ref) => TempDocumentStorage());

final documentOpenerProvider =
    Provider<DocumentOpener>((ref) => const SystemDocumentOpener());

/// Starea documentelor unui produs: care se descarca acum si ce mesaj a lasat
/// ultima incercare.
///
/// Nu tine niciun octet: fisierul se scrie direct pe disc si se da mai departe
/// sistemului, ca un document de cateva megaocteti sa nu stea in memorie.
@immutable
class DocumentsState {
  const DocumentsState({this.busy = const {}, this.error});

  /// URL-urile documentelor a caror descarcare e in aer. Set, nu un singur flag:
  /// doua documente diferite pot fi apasate unul dupa altul, iar randul care
  /// lucreaza trebuie sa fie exact cel apasat.
  final Set<String> busy;

  /// Mesajul ultimei incercari esuate, in romana. Se sterge la incercarea
  /// urmatoare — e despre ultima apasare, nu o stare permanenta.
  final String? error;

  bool isBusy(String url) => busy.contains(url);
}

/// Cate un controller per produs (`family`), la fel ca `productControllerProvider`:
/// deschiderea unui produs similar peste cel curent nu are voie sa-i miste randurile
/// de dedesubt. `autoDispose`: starea dispare cu ecranul.
final documentsControllerProvider =
    NotifierProvider.autoDispose.family<DocumentsController, DocumentsState, int>(
  DocumentsController.new,
  // retry: null - vezi CLAUDE.md, gotcha 3. `build()` de aici nu arunca, dar regula
  // ramane regula: fara ea, o eroare aparuta candva in build ar fi reincercata cu
  // backoff pana la ~38s.
  retry: (retryCount, error) => null,
);

/// Descarcarea si deschiderea documentelor de produs.
///
/// De ce nu se arunca URL-ul direct in browser (cum se facea): ruta e autentificata,
/// iar browserul telefonului nu duce cookie-ul de sesiune al aplicatiei — cererea
/// lui ar primi 401 si userul ar vedea o pagina de eroare Odoo. Deci fisierul il
/// aduce aplicatia, prin acelasi `ApiClient` ca orice alta cerere, si abia apoi il
/// da vizualizatorului de sistem.
class DocumentsController extends Notifier<DocumentsState> {
  DocumentsController(this.productId);

  final int productId;

  bool _disposed = false;

  @override
  DocumentsState build() {
    ref.onDispose(() => _disposed = true);
    return const DocumentsState();
  }

  /// Descarca documentul de la `url` si il deschide. Doua apasari pe acelasi
  /// document nu pornesc doua descarcari: a doua se opreste aici.
  ///
  /// Nu arunca niciodata: orice esec devine mesaj in stare. O apasare fara niciun
  /// raspuns vizibil ar fi cel mai prost rezultat posibil.
  Future<void> open({required String url, required String fileName}) async {
    if (state.busy.contains(url)) return;
    state = DocumentsState(busy: {...state.busy, url});

    // Toate cele trei unelte se citesc ACUM, inainte de primul `await`. Providerul
    // e autoDispose, iar fila "Documente" se poate inchide cat timp fisierul vine
    // (userul se uita intre timp la specificatii): un `ref.read` de dupa dispose ar
    // arunca si descarcarea ceruta de user s-ar pierde in tacere.
    final storage = ref.read(documentStorageProvider);
    final api = ref.read(apiClientProvider);
    final opener = ref.read(documentOpenerProvider);

    String? message;
    try {
      final file = await storage.fileFor(url: url, fileName: fileName);
      // Descarcarea scrie direct in fisier, in pasi, pe firul de I/O: interfata
      // ramane vie si documentul nu trece intreg prin memorie.
      await api.downloadTo(url, file.path);
      final outcome = await opener.open(file.path);
      message = switch (outcome) {
        DocumentOpenOutcome.opened => null,
        DocumentOpenOutcome.noViewer =>
          'Nu ai nicio aplicatie care sa deschida acest fisier.',
        DocumentOpenOutcome.failed => 'Nu s-a putut deschide documentul.',
      };
    } on ApiException catch (error) {
      // Mesajul serverului, in aceeasi forma ca peste tot in aplicatie (inclusiv
      // "Nu s-a putut contacta serverul. Verifica conexiunea." la retea cazuta).
      message = error.message;
    } catch (error) {
      debugPrint('Nu s-a putut descarca documentul produsului: $error');
      message = 'Nu s-a putut descarca documentul. Incearca din nou.';
    }

    // Ecranul se poate inchide cat timp descarcarea e in aer; atunci nu mai exista
    // stare in care sa scriem.
    if (_disposed) return;
    state = DocumentsState(busy: {...state.busy}..remove(url), error: message);
  }
}

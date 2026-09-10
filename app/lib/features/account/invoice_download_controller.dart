import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../providers.dart';
import '../product/document_controller.dart' show documentOpenerProvider, documentStorageProvider;
import '../product/document_files.dart';

/// Starea descarcarii facturilor: care PDF se aduce acum si ce a lasat ultima
/// incercare.
@immutable
class InvoiceDownloadState {
  const InvoiceDownloadState({this.busy = const {}, this.error});

  /// Id-urile facturilor a caror descarcare e in aer. Set, nu un singur flag: doua
  /// facturi pot fi apasate una dupa alta, iar randul care lucreaza trebuie sa fie
  /// exact cel apasat.
  final Set<int> busy;
  final String? error;

  bool isBusy(int invoiceId) => busy.contains(invoiceId);
}

final invoiceDownloadProvider =
    NotifierProvider<InvoiceDownloadController, InvoiceDownloadState>(
  InvoiceDownloadController.new,
  // retry: null - vezi CLAUDE.md, gotcha 3.
  retry: (retryCount, error) => null,
);

/// Descarca PDF-ul unei facturi si il deschide cu vizualizatorul telefonului.
///
/// Aceeasi cale ca la documentele de produs, si din acelasi motiv: ruta e
/// autentificata, iar browserul telefonului nu duce cookie-ul de sesiune al
/// aplicatiei - un URL aruncat in browser ar primi 401. Fisierul il aduce aplicatia,
/// prin `ApiClient`, si abia apoi il da sistemului. Se refolosesc chiar providerii de
/// stocare si de deschidere ai documentelor, ca sa existe o singura implementare.
class InvoiceDownloadController extends Notifier<InvoiceDownloadState> {
  @override
  InvoiceDownloadState build() => const InvoiceDownloadState();

  /// Nu arunca niciodata: orice esec devine mesaj in stare. O apasare fara niciun
  /// raspuns vizibil ar fi cel mai prost rezultat posibil.
  Future<void> open({required int invoiceId, required String url, required String name}) async {
    if (state.busy.contains(invoiceId)) return;
    state = InvoiceDownloadState(busy: {...state.busy, invoiceId});

    final storage = ref.read(documentStorageProvider);
    final api = ref.read(apiClientProvider);
    final opener = ref.read(documentOpenerProvider);

    String? message;
    try {
      final file = await storage.fileFor(url: url, fileName: '$name.pdf');
      await api.downloadTo(api.absoluteUrl(url), file.path);
      final outcome = await opener.open(file.path);
      message = switch (outcome) {
        DocumentOpenOutcome.opened => null,
        DocumentOpenOutcome.noViewer => 'Nu ai nicio aplicatie care sa deschida fisiere PDF.',
        DocumentOpenOutcome.failed => 'Nu s-a putut deschide factura.',
      };
    } on ApiException catch (error) {
      message = error.message;
    } catch (error) {
      debugPrint('Nu s-a putut descarca factura: $error');
      message = 'Nu s-a putut descarca factura. Incearca din nou.';
    }

    state = InvoiceDownloadState(busy: {...state.busy}..remove(invoiceId), error: message);
  }
}

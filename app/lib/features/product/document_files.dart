import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Cum s-a terminat incercarea de a da fisierul aplicatiei potrivite de pe telefon.
enum DocumentOpenOutcome {
  /// Sistemul a preluat fisierul (a deschis vizualizatorul, sau foaia de alegere).
  opened,

  /// Telefonul nu are nicio aplicatie pentru tipul asta de fisier.
  noViewer,

  /// Orice altceva: fisier respins, permisiune refuzata, eroare de platforma.
  failed,
}

/// Deschiderea unui fisier local cu aplicatia potrivita de pe telefon.
///
/// E o interfata proprie, nu pachetul direct, din doua motive: testele nu au voie
/// sa lanseze aplicatii reale (pe macOS `open_filex` chiar cheama `open`), iar
/// aplicatia trebuie sa poata schimba pachetul fara sa umble in ecran.
abstract class DocumentOpener {
  Future<DocumentOpenOutcome> open(String path);
}

/// Implementarea reala, peste `open_filex`. `url_launcher` nu poate deschide o cale
/// locala pe iOS/Android (schema `file:` e documentata doar pentru desktop), de
/// aceea a fost nevoie de un pachet in plus — vezi docs/DE-FACUT.md.
class SystemDocumentOpener implements DocumentOpener {
  const SystemDocumentOpener();

  @override
  Future<DocumentOpenOutcome> open(String path) async {
    try {
      final result = await OpenFilex.open(path);
      return switch (result.type) {
        ResultType.done => DocumentOpenOutcome.opened,
        ResultType.noAppToOpen => DocumentOpenOutcome.noViewer,
        _ => DocumentOpenOutcome.failed,
      };
    } catch (error) {
      // Un canal de platforma cazut nu are voie sa iasa dintr-un handler de tap.
      debugPrint('Nu s-a putut deschide documentul produsului: $error');
      return DocumentOpenOutcome.failed;
    }
  }
}

/// Unde se scrie documentul descarcat, inainte sa fie dat sistemului.
abstract class DocumentStorage {
  /// Fisierul in care se scrie documentul de la `url`, cu dosarul lui deja creat.
  Future<File> fileFor({required String url, required String fileName});
}

/// Implementarea reala: dosarul temporar al aplicatiei, singurul care exista si e
/// scriibil si pe iOS, si pe Android, fara nicio permisiune. E temporar cu
/// intentie — documentele se pot recere oricand de la server, si sistemul are voie
/// sa curete dosarul cand are nevoie de spatiu.
class TempDocumentStorage implements DocumentStorage {
  TempDocumentStorage({Future<Directory> Function()? temporaryDirectory})
      : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  /// Injectabil ca testele sa nu atinga `path_provider` (canal de platforma), dar
  /// sa exercite tot restul: numele curatat, dosarul per document, crearea lui.
  final Future<Directory> Function() _temporaryDirectory;

  static const folderName = 'uportho_documente';

  /// Fiecare document primeste
  /// **dosarul lui**, numit dupa calea rutei (care contine si id-ul produsului, si
  /// id-ul atasamentului): doua documente diferite nu pot ajunge in acelasi fisier
  /// nici cand poarta acelasi nume — pe catalogul real numele "certificat.pdf" se
  /// repeta de la produs la produs.
  ///
  /// Numele de pe disc ramane cel din Odoo, curatat: fara el (si mai ales fara
  /// extensie) telefonul n-ar sti ce aplicatie sa deschida.
  @override
  Future<File> fileFor({required String url, required String fileName}) async {
    final root = await _temporaryDirectory();
    final directory = Directory('${root.path}/$folderName/${_keyFor(url)}');
    await directory.create(recursive: true);
    return File('${directory.path}/${_safeFileName(fileName)}');
  }

  /// Numele dosarului pentru un document: segmentele de cale ale URL-ului, curatate.
  static String _keyFor(String url) {
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    final key = segments.isEmpty ? url : segments.join('_');
    final safe = key.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return safe.isEmpty ? 'document' : safe;
  }

  /// Numele fisierului, adus la ceva ce se poate scrie in siguranta: fara
  /// separatoare de cale (un `../..` din numele venit de pe server n-are voie sa
  /// scrie in afara dosarului), fara caractere problematice si niciodata gol.
  /// Extensia se pastreaza — de ea depinde alegerea vizualizatorului.
  static String _safeFileName(String fileName) {
    final base = fileName.split(RegExp(r'[\\/]')).last.trim();
    final cleaned = base.replaceAll(RegExp(r'[^A-Za-z0-9._ ()+-]'), '_');
    final trimmed = cleaned.replaceAll(RegExp(r'^[.\s]+'), '');
    if (trimmed.isEmpty) return 'document';
    // Numele foarte lungi pica pe unele sisteme de fisiere; extensia se pastreaza.
    if (trimmed.length <= 100) return trimmed;
    final dot = trimmed.lastIndexOf('.');
    final extension = dot > 0 && trimmed.length - dot <= 10 ? trimmed.substring(dot) : '';
    return trimmed.substring(0, 100 - extension.length) + extension;
  }
}

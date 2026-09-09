import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../colors.dart';
import '../typography.dart';

/// Un document de deschis, in forma de care are nevoie widgetul: numele afisat,
/// numele fisierului si un URL absolut. Deliberat NU e modelul API
/// `ProductDocument` — design system-ul nu importa modele de wire (vezi datoria
/// tehnica 1 din docs/DE-FACUT.md). Maparea model -> element sta in ecran.
@immutable
class DocumentItem {
  const DocumentItem({required this.name, this.fileName, required this.url});

  final String name;

  /// Numele fisierului de pe disc. Poate lipsi, si poate fi chiar acelasi text ca
  /// `name` — atunci nu se scrie de doua ori.
  final String? fileName;

  /// URL absolut. E ruta standard a Odoo pentru fisier, nu una a modulului nostru:
  /// documentul se deschide in afara aplicatiei.
  final String url;

  @override
  bool operator ==(Object other) =>
      other is DocumentItem &&
      other.name == name &&
      other.fileName == fileName &&
      other.url == url;

  @override
  int get hashCode => Object.hash(name, fileName, url);
}

/// Documentele produsului (fise tehnice, certificate, cataloage), cate un rand
/// fiecare. Apasarea deschide fisierul in exterior (browser sau vizualizatorul de
/// sistem) — nu exista vizualizator in aplicatie si nu se adauga niciun pachet
/// pentru asta, exact ca la elementele video din galerie.
///
/// Lista goala = niciun pixel desenat: pe ecranul de produs fiecare sectiune fara
/// date dispare complet.
class DocumentList extends StatelessWidget {
  const DocumentList({super.key, required this.items, this.onOpen});

  final List<DocumentItem> items;

  /// Ce se intampla la apasarea pe un document. Implicit: deschidere externa cu
  /// `url_launcher`. Testele injecteaza propriul callback ca sa nu atinga platforma.
  final void Function(String url)? onOpen;

  void _open(String url) {
    final onOpen = this.onOpen;
    if (onOpen != null) {
      onOpen(url);
      return;
    }
    // Aceleasi doua capcane ca la link-urile de banner (vezi
    // features/home/banner_link.dart) si la videourile din galerie:
    // `Uri.tryParse('')` intoarce un Uri valid, iar o schema arbitrara ar deschide
    // orice aplicatie care o pretinde. Deschidem doar http/https cu host, si
    // niciodata nu lasam o exceptie de platforma sa scape dintr-un handler de tap.
    final uri = Uri.tryParse(url.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https')) || uri.host.isEmpty) {
      return;
    }
    unawaited(() async {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (error) {
        debugPrint('Nu s-a putut deschide documentul produsului: $error');
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.description_outlined, color: AppColors.primary),
            title: Text(item.name, style: AppTypography.body),
            subtitle: item.fileName == null || item.fileName == item.name
                ? null
                : Text(item.fileName!, style: AppTypography.caption),
            trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.textSecondary),
            onTap: () => _open(item.url),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Un document de deschis, in forma de care are nevoie widgetul: numele afisat,
/// numele fisierului, un URL absolut si daca se descarca chiar acum. Deliberat NU e
/// modelul API `ProductDocument` — design system-ul nu importa modele de wire (vezi
/// datoria tehnica 1 din docs/DE-FACUT.md). Maparea model -> element sta in ecran.
@immutable
class DocumentItem {
  const DocumentItem({
    required this.name,
    this.fileName,
    required this.url,
    this.busy = false,
  });

  final String name;

  /// Numele fisierului de pe disc. Poate lipsi, si poate fi chiar acelasi text ca
  /// `name` — atunci nu se scrie de doua ori.
  final String? fileName;

  /// URL absolut. E o ruta AUTENTIFICATA a modulului nostru
  /// (`/api/app/v1/products/<id>/documents/<id>`), nu `/web/content/...` al Odoo:
  /// fisierul se da doar cererilor care poarta sesiunea aplicatiei.
  final String url;

  /// True cat timp documentul se descarca. Randul arata ca lucreaza si nu mai
  /// raspunde la apasari; restul listei ramane folosibil.
  final bool busy;

  DocumentItem copyWith({String? name, String? fileName, String? url, bool? busy}) =>
      DocumentItem(
        name: name ?? this.name,
        fileName: fileName ?? this.fileName,
        url: url ?? this.url,
        busy: busy ?? this.busy,
      );

  @override
  bool operator ==(Object other) =>
      other is DocumentItem &&
      other.name == name &&
      other.fileName == fileName &&
      other.url == url &&
      other.busy == busy;

  @override
  int get hashCode => Object.hash(name, fileName, url, busy);
}

/// Documentele produsului (fise tehnice, certificate, cataloage), cate un rand
/// fiecare.
///
/// Apasarea nu deschide un link: URL-ul e o ruta autentificata, iar browserul
/// telefonului nu duce cookie-ul de sesiune al aplicatiei — aruncat in browser, ar
/// raspunde 401. Fisierul il aduce aplicatia (cu sesiunea pe cerere) si abia apoi il
/// da vizualizatorului de sistem; widgetul doar anunta apasarea si arata ce i se
/// spune despre ea (`busy`, `error`).
///
/// Lista goala = niciun pixel desenat: pe ecranul de produs fiecare sectiune fara
/// date dispare complet.
class DocumentList extends StatelessWidget {
  const DocumentList({
    super.key,
    required this.items,
    required this.onOpen,
    this.error,
  });

  final List<DocumentItem> items;

  /// Apasarea pe un document. Primeste elementul intreg, nu doar URL-ul: cine
  /// descarca are nevoie si de numele fisierului, ca sa-l scrie pe disc cu extensia
  /// lui (fara ea, telefonul nu stie ce aplicatie sa deschida).
  final void Function(DocumentItem item) onOpen;

  /// Mesajul ultimei incercari esuate, desenat sub lista — ca `footnote`-ul
  /// tabelului de variante. Fara el, o apasare care esueaza n-ar avea niciun raspuns.
  final String? error;

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
            trailing: item.busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new, size: 18, color: AppColors.textSecondary),
            // Randul ocupat nu mai porneste inca o descarcare. (Controllerul opreste
            // oricum a doua apasare; aici e ca sa se si vada ca nu are rost.)
            onTap: item.busy ? null : () => onOpen(item),
          ),
        if (error != null && error!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error!, style: AppTypography.caption.copyWith(color: AppColors.danger)),
          ),
      ],
    );
  }
}

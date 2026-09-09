import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';
import 'description_view.dart';

/// Un prag de cantitate, gata de afisat: eticheta ("1+", "3+") si suma, ambele
/// siruri venite formatate de la server. Widgetul nu primeste niciodata numere de
/// bani si nu formateaza nimic — regula "nicio aritmetica pe bani" din CLAUDE.md.
/// Ca si `GalleryItem`, e un tip local de design system, nu modelul API `PriceTier`.
@immutable
class PriceTierEntry {
  const PriceTierEntry({required this.label, required this.priceFormatted});

  final String label;
  final String priceFormatted;

  @override
  bool operator ==(Object other) =>
      other is PriceTierEntry && other.label == label && other.priceFormatted == priceFormatted;

  @override
  int get hashCode => Object.hash(label, priceFormatted);
}

/// Un tabel de preturi: cate o celula per prag, asezate cu `Wrap` — trec pe randul
/// urmator cand nu mai incap, deci toate pragurile se vad deodata, fara derulare
/// laterala. Derularea orizontala de dinainte ascundea al patrulea prag exact pe
/// produsele cu reduceri de volum, adica acolo unde tabelul conteaza cel mai mult.
/// `Wrap` nu poate da overflow nici la sase praguri cu sume de cinci cifre.
///
/// Titlul si nota vin de la apelant (adica, prin ecran, de la server): magazinul
/// arata unul, doua sau niciun tabel, iar titlurile sunt nume de liste de pret sau
/// de campanii — widgetul nu cunoaste niciunul.
///
/// Lista goala = niciun pixel desenat, nici macar titlul: 214 din 619 produse
/// reale n-au praguri.
class PriceTierTable extends StatelessWidget {
  const PriceTierTable({
    super.key,
    required this.entries,
    this.title,
    this.note = const [],
    this.highlightedIndex = 0,
  });

  final List<PriceTierEntry> entries;
  final String? title;

  /// Textul de pe lista de pret ("de la 5 bucati", conditii de campanie), sub titlu.
  /// Aceleasi blocuri ca descrierea produsului — tip local de design system, nu
  /// modelul API.
  final List<DescriptionBlockData> note;

  /// Pragul evidentiat — implicit primul, adica pretul la cantitatea 1, cel care
  /// se aplica in mod obisnuit. Un index in afara listei nu evidentiaza nimic.
  final int highlightedIndex;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Text(title!, style: AppTypography.sectionTitle),
          const SizedBox(height: 8),
        ],
        if (note.isNotEmpty) ...[
          DescriptionView(blocks: note),
          const SizedBox(height: 8),
        ],
        // LayoutBuilder + ConstrainedBox: o celula nu poate fi mai lata decat
        // spatiul disponibil. Fara asta, `Wrap` nu decupeaza si nu micsoreaza —
        // o suma foarte lunga pe un ecran foarte ingust ar iesi din ecran.
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < entries.length; index++)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: PriceTierCell(
                    entry: entries[index],
                    highlighted: index == highlightedIndex,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// O coloana din tabel. Publica pentru ca testele sa poata verifica evidentierea
/// fara sa se agate de culori.
class PriceTierCell extends StatelessWidget {
  const PriceTierCell({super.key, required this.entry, required this.highlighted});

  final PriceTierEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlighted ? AppColors.primary : AppColors.primaryLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.label,
            style: AppTypography.caption.copyWith(
              color: highlighted ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          // Fara maxLines/ellipsis: suma e exact informatia pentru care exista
          // celula. Latimea o rezolva `Wrap`, mutand celula pe randul urmator, nu
          // retezarea textului (greseala facuta o data pe pretul de club din card).
          // Suma nu se rupe pe doua randuri si nu se reteaza; daca celula a fost
          // ingustata pana sub latimea ei, textul se micsoreaza uniform.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              entry.priceFormatted,
              softWrap: false,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
                color: highlighted ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

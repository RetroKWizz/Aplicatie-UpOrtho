import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

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

/// Tabelul de praguri de cantitate (si cel de Ortho Club, care are aceeasi forma).
/// Cate o coloana per prag, derulabile orizontal cand nu incap — de aceea nu poate
/// da overflow nici la sase praguri cu sume de cinci cifre pe un ecran ingust.
///
/// Lista goala = niciun pixel desenat, nici macar titlul: 214 din 619 produse
/// reale n-au praguri.
class PriceTierTable extends StatelessWidget {
  const PriceTierTable({
    super.key,
    required this.entries,
    this.title,
    this.highlightedIndex = 0,
  });

  final List<PriceTierEntry> entries;
  final String? title;

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
        if (title != null) ...[
          Text(title!, style: AppTypography.sectionTitle),
          const SizedBox(height: 8),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < entries.length; index++)
                Padding(
                  padding: EdgeInsets.only(right: index == entries.length - 1 ? 0 : 8),
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
          // celula, iar latimea e rezolvata de derularea orizontala, nu prin
          // retezarea textului (greseala facuta o data pe pretul de club din card).
          Text(
            entry.priceFormatted,
            softWrap: false,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w800,
              color: highlighted ? Colors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

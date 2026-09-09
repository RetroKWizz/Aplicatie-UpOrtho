import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Un rand din tabelul de comanda pe variante, gata de afisat. Ca si
/// `PriceTierEntry` sau `GalleryItem`, e un tip local de design system, nu modelul
/// API: widgetul nu stie de contract si nu primeste niciodata numere de bani —
/// sumele sunt siruri formatate de server (regula "nicio aritmetica pe bani" din
/// CLAUDE.md).
///
/// `subtotalFormatted` poate lipsi: pana cand serverul raspunde cu subtotalul
/// pentru cantitatile alese nu exista niciun sir de bani de scris in celula, iar
/// widgetul nu are voie sa scrie "0,00 lei" de la el (nu stie nici valuta, nici
/// formatul).
@immutable
class VariantOrderRow {
  const VariantOrderRow({
    required this.id,
    required this.attributes,
    required this.priceFormatted,
    required this.qty,
    this.code,
    this.stockLabel,
    this.inStock = true,
    this.subtotalFormatted,
  });

  /// Identificatorul randului, intors la `onQuantityChanged`. Ecranul pune aici
  /// id-ul variantei; widgetul nu il interpreteaza.
  final int id;

  /// Cate o linie per atribut, deja compusa de ecran ("Brand: Dynaflex").
  final List<String> attributes;

  final String priceFormatted;
  final int qty;

  /// Codul produsului (`default_code`), fara prefix — eticheta "Cod:" o pune tabelul.
  final String? code;

  /// Linia de stoc ("In stoc", "Precomanda..."), asa cum vine de la server.
  final String? stockLabel;
  final bool inStock;
  final String? subtotalFormatted;
}

/// Tabelul de comanda pe variante de pe pagina de produs a site-ului:
/// **Atribute | Pret | Cantitate | Subtotal**, cate un rand per varianta, cu un
/// total sub tabel.
///
/// Widgetul nu calculeaza nimic: subtotalurile si totalul vin gata formatate (de la
/// server, prin ecran), pentru ca o cantitate mai mare poate trece un prag de pret —
/// subtotalul NU e pretul unitar inmultit cu cantitatea.
///
/// Steperul anunta **noua cantitate**, nu diferenta, ca apelantul sa nu tina el
/// socoteala. Fara `onQuantityChanged` butoanele sunt inerte (ecranul le poate
/// dezactiva).
///
/// Lista goala = niciun pixel desenat: produsele cu o singura varianta nu au tabel.
class VariantOrderTable extends StatelessWidget {
  const VariantOrderTable({
    super.key,
    required this.rows,
    this.totalFormatted,
    this.onQuantityChanged,
    this.footnote,
  });

  final List<VariantOrderRow> rows;

  /// Totalul de sub tabel; `null` cat timp serverul nu a trimis inca unul.
  final String? totalFormatted;

  final void Function(int rowId, int quantity)? onQuantityChanged;

  /// Text sub total (mesaj de eroare de la ultima cerere de preturi, de exemplu).
  final String? footnote;

  /// Ce se scrie in locul unei sume pe care serverul nu a trimis-o (inca).
  static const missingAmount = '—';

  /// Sub aceasta latime, cele patru coloane nu mai incap una langa alta fara ca
  /// atributele (singurul text lung din rand) sa ramana pe o coloana de doua-trei
  /// litere. Sub ea randul se aseaza pe doua etaje, cu etichetele langa sume.
  static const compactBreakpoint = 380.0;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < compactBreakpoint;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Capul de tabel are sens doar cand exista coloane; in forma compacta
          // etichetele stau langa sumele lor, in fiecare rand.
          if (!compact) ...[
            const _HeaderRow(),
            const Divider(height: 12, color: AppColors.primaryLight),
          ],
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const Divider(height: 20, color: AppColors.primaryLight),
            _Row(row: rows[index], onQuantityChanged: onQuantityChanged, compact: compact),
          ],
          const Divider(height: 20, color: AppColors.primaryLight),
          Row(
            children: [
              const Expanded(
                child: Text('Total',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
              Text(
                totalFormatted ?? missingAmount,
                style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 18),
              ),
            ],
          ),
          if (footnote != null && footnote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(footnote!, style: AppTypography.caption.copyWith(color: AppColors.danger)),
          ],
        ],
      );
    });
  }
}

/// Latimile coloanelor. Atributele iau restul: sunt singurul text de lungime
/// necontrolata ("Brand: Dynaflex Orthodontics / Tip set: All Hooks / ...").
const _priceWidth = 78.0;
const _qtyWidth = 96.0;
const _subtotalWidth = 84.0;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, height: 1.2);
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text('Atribute', style: style)),
        SizedBox(width: _priceWidth, child: Text('Pret', style: style, textAlign: TextAlign.end)),
        SizedBox(
            width: _qtyWidth, child: Text('Cantitate', style: style, textAlign: TextAlign.center)),
        SizedBox(
            width: _subtotalWidth, child: Text('Subtotal', style: style, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.onQuantityChanged, required this.compact});

  final VariantOrderRow row;
  final void Function(int rowId, int quantity)? onQuantityChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final stepper = _Stepper(row: row, onQuantityChanged: onQuantityChanged);
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Attributes(row: row),
          const SizedBox(height: 6),
          // Wrap, nu Row: pe un ecran ingust cele trei grupuri (pret, stepper,
          // subtotal) nu incap pe un rand, iar un Row ar da RenderFlex overflow.
          Wrap(
            spacing: 14,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _LabeledAmount(label: 'Pret', amount: row.priceFormatted),
              stepper,
              _LabeledAmount(
                label: 'Subtotal',
                amount: row.subtotalFormatted ?? VariantOrderTable.missingAmount,
                highlighted: true,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _Attributes(row: row)),
        SizedBox(
          width: _priceWidth,
          child: Text(row.priceFormatted,
              textAlign: TextAlign.end,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ),
        SizedBox(width: _qtyWidth, child: stepper),
        SizedBox(
          width: _subtotalWidth,
          child: Text(
            row.subtotalFormatted ?? VariantOrderTable.missingAmount,
            textAlign: TextAlign.end,
            style: AppTypography.caption
                .copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// Eticheta de coloana pusa langa suma ei, pentru forma compacta a randului.
class _LabeledAmount extends StatelessWidget {
  const _LabeledAmount({required this.label, required this.amount, this.highlighted = false});

  final String label;
  final String amount;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        Text(amount,
            style: AppTypography.caption.copyWith(
                fontWeight: highlighted ? FontWeight.w800 : FontWeight.w700,
                color: highlighted ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }
}

/// Valorile de atribut ale variantei, codul si linia de stoc — coloana "Atribute".
class _Attributes extends StatelessWidget {
  const _Attributes({required this.row});

  final VariantOrderRow row;

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final attribute in row.attributes)
                Text(attribute,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textPrimary, height: 1.3)),
              if (row.code != null && row.code!.isNotEmpty)
                Text('Cod: ${row.code}',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              if (row.stockLabel != null && row.stockLabel!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(row.inStock ? Icons.check_circle_outline : Icons.schedule,
                        size: 13, color: row.inStock ? AppColors.success : AppColors.accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(row.stockLabel!,
                          style: AppTypography.caption.copyWith(
                              color: row.inStock ? AppColors.success : AppColors.accent)),
                    ),
                  ],
                ),
      ],
    );
  }
}

/// −/+ in jurul cantitatii. Minusul e dezactivat la zero: nu exista cantitati
/// negative, iar serverul le-ar refuza oricum cu 422.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.row, required this.onQuantityChanged});

  final VariantOrderRow row;
  final void Function(int rowId, int quantity)? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          tooltip: 'Scade cantitatea',
          onPressed: onQuantityChanged == null || row.qty <= 0
              ? null
              : () => onQuantityChanged!(row.id, row.qty - 1),
        ),
        SizedBox(
          width: 24,
          child: Text('${row.qty}',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
        ),
        _StepperButton(
          icon: Icons.add,
          tooltip: 'Creste cantitatea',
          onPressed:
              onQuantityChanged == null ? null : () => onQuantityChanged!(row.id, row.qty + 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      style: IconButton.styleFrom(
        // Fara `minimumSize` explicit, IconButton isi pastreaza minimul de 40x40 din
        // stilul implicit si depaseste latimea coloanei de cantitate.
        minimumSize: const Size(30, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textSecondary.withValues(alpha: 0.4),
        side: const BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

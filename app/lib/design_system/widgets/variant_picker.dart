import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// O valoare de atribut, gata de afisat. `available` vine din combinatiile
/// posibile calculate de Odoo — aplicatia nu deduce singura ce combinatii exista.
@immutable
class VariantOption {
  const VariantOption({
    required this.id,
    required this.label,
    this.selected = false,
    this.available = true,
  });

  final int id;
  final String label;
  final bool selected;
  final bool available;

  @override
  bool operator ==(Object other) =>
      other is VariantOption &&
      other.id == id &&
      other.label == label &&
      other.selected == selected &&
      other.available == available;

  @override
  int get hashCode => Object.hash(id, label, selected, available);
}

/// Un atribut cu valorile lui (ex. "Marime": Mare / Mic).
@immutable
class VariantGroup {
  const VariantGroup({required this.id, required this.name, required this.options});

  final int id;
  final String name;
  final List<VariantOption> options;
}

/// Selectorul de variante: cate un grup de butoane per atribut. Valorile
/// indisponibile se arata **dezactivate, nu ascunse** — altfel utilizatorul n-ar
/// intelege de ce lipsesc marimi pe care le vede pe site.
///
/// Fara grupuri = niciun pixel desenat: 354 din 619 produse reale n-au variante.
class VariantPicker extends StatelessWidget {
  const VariantPicker({super.key, required this.groups, this.onSelected});

  final List<VariantGroup> groups;

  /// `(attributeId, valueId)` — ecranul recere produsul cu varianta noua.
  final void Function(int attributeId, int valueId)? onSelected;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          Text(groups[index].name, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          // Wrap, nu Row: valorile romanesti pot fi lungi ("Mare cu falci zimtate
          // pentru arcuri groase") si multe; pe un ecran ingust un Row ar da
          // RenderFlex overflow, Wrap trece pe randul urmator.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in groups[index].options)
                VariantOptionChip(
                  option: option,
                  onTap: option.available && onSelected != null
                      ? () => onSelected!(groups[index].id, option.id)
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Un buton de valoare. Public ca testele sa poata verifica starea (selectat /
/// dezactivat) fara sa se agate de culori.
class VariantOptionChip extends StatelessWidget {
  const VariantOptionChip({super.key, required this.option, this.onTap});

  final VariantOption option;

  /// `null` = valoare indisponibila (sau selector fara handler): butonul se vede,
  /// dar nu raspunde la apasare.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unavailable = !option.available;
    final background = option.selected
        ? AppColors.primary
        : unavailable
            ? AppColors.background
            : AppColors.surface;
    final foreground = option.selected
        ? Colors.white
        : unavailable
            ? AppColors.textSecondary
            : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: option.selected ? AppColors.primary : AppColors.primaryLight,
          ),
        ),
        child: Text(
          option.label,
          style: AppTypography.body.copyWith(
            color: foreground,
            fontWeight: option.selected ? FontWeight.w700 : FontWeight.w500,
            decoration: unavailable ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

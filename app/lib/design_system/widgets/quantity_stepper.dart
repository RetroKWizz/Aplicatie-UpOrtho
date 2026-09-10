import 'package:flutter/material.dart';

import '../colors.dart';

/// Pasii de cantitate dintr-o linie de cos: minus, numarul, plus.
///
/// Nu tine stare proprie: cantitatea vine de sus, iar fiecare apasare cere serverului
/// noua cantitate. O stare locala ar arata un numar pe care serverul poate sa-l fi
/// ajustat deja (stoc insuficient), iar utilizatorul ar vedea alta cantitate decat
/// comanda reala.
///
/// Cat timp `busy` e adevarat, butoanele sunt inactive: doua apasari rapide ar trimite
/// doua cereri concurente pe aceeasi linie, iar cea intoarsa mai tarziu ar castiga.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.busy = false,
    this.minimum = 0,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final bool busy;

  /// Sub aceasta valoare butonul de minus e inactiv. `0` inseamna ca minusul de la 1
  /// sterge linia.
  final int minimum;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryLight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: quantity <= 1 ? Icons.delete_outline : Icons.remove,
            tooltip: quantity <= 1 ? 'Sterge din cos' : 'Scade cantitatea',
            onPressed: busy || quantity <= minimum ? null : () => onChanged(quantity - 1),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 34),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: 'Creste cantitatea',
            onPressed: busy ? null : () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      color: AppColors.primary,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
    );
  }
}

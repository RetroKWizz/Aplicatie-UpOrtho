import 'package:flutter/material.dart';

import '../api/models/product_badge.dart';
import '../design_system/colors.dart';

/// Culorile unei etichete de produs.
///
/// Cand serverul trimite culorile magazinului (hexazecimal, din eticheta temei) se
/// folosesc ele, ca eticheta din aplicatie sa arate ca aceea de pe site. Cand nu -
/// pe o baza fara tema - se cade pe numele de culoare din contract
/// (`orange`/`green`/`blue`/`purple`/`red`), tradus in paleta de brand.
///
/// Traducerea sta aici, la marginea dintre modelele de wire si design system:
/// widgeturile (`ProductCard` si urmatoarele) nu importa modele API, deci nu pot
/// sti de `ProductBadgeColor`. Ecranele de catalog si de produs desenau altfel
/// acelasi badge din doua copii ale aceluiasi `switch`.
Color productBadgeColor(ProductBadgeColor color) => switch (color) {
      ProductBadgeColor.orange => AppColors.accent,
      ProductBadgeColor.green => AppColors.success,
      ProductBadgeColor.blue => const Color(0xFF2E75D9),
      ProductBadgeColor.purple => AppColors.primary,
      ProductBadgeColor.red => AppColors.danger,
    };

/// Culoarea de fundal a unei etichete: cea a magazinului cand exista, altfel cea din
/// paleta.
Color productBadgeBackground(ProductBadge badge) =>
    _hex(badge.backgroundColor) ?? productBadgeColor(badge.color);

/// Culoarea textului unei etichete. Implicit alb, ca pe site.
Color productBadgeForeground(ProductBadge badge) => _hex(badge.textColor) ?? Colors.white;

/// `#RRGGBB` sau `#AARRGGBB` din datele serverului. O valoare pe care n-o putem citi
/// nu e o eroare: eticheta e decorativa, deci se cade pe paleta.
Color? _hex(String? value) {
  if (value == null) return null;
  final digits = value.replaceFirst('#', '').trim();
  if (digits.length != 6 && digits.length != 8) return null;
  final parsed = int.tryParse(digits, radix: 16);
  if (parsed == null) return null;
  return Color(digits.length == 6 ? 0xFF000000 | parsed : parsed);
}

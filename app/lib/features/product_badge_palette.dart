import 'package:flutter/material.dart';

import '../api/models/product_badge.dart';
import '../design_system/colors.dart';

/// Culorile de badge din contract (`orange`/`green`/`blue`/`purple`/`red`) traduse
/// in `Color` din paleta de brand.
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

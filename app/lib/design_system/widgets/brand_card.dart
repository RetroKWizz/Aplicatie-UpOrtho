import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';
import 'description_view.dart';

/// Chenarul de brand de pe pagina de produs: logo, nume si descriere.
///
/// Primeste doar tipuri simple (nu modelul API `ProductBrand`) — design system-ul nu
/// importa modele de wire; maparea contract -> parametri sta in ecran (vezi datoria
/// tehnica 1 din docs/DE-FACUT.md).
///
/// Fara nume nu se deseneaza nimic: un chenar cu un logo si nimic altceva n-ar spune
/// nimic. Logoul lipsa nu lasa gol — chenarul ramane doar cu numele si textul.
class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.name,
    this.description = const [],
    this.logoUrl,
    this.httpHeaders,
  });

  final String name;

  /// Textul de sub nume, in aceleasi blocuri ca descrierea produsului.
  final List<DescriptionBlockData> description;

  /// URL absolut al logoului. Ruta e autentificata, ca toate imaginile modulului,
  /// deci vine cu headerele ei — widgetul doar le transmite mai departe.
  final String? logoUrl;
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    if (name.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (logoUrl != null) ...[
                SizedBox(
                  width: 56,
                  height: 40,
                  child: CachedNetworkImage(
                    imageUrl: logoUrl!,
                    httpHeaders: httpHeaders,
                    fit: BoxFit.contain,
                    // Un logo care nu se incarca nu lasa o iconita de eroare in
                    // mijlocul chenarului: dispare, si ramane numele.
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Expanded: numele de brand poate fi lung si randul ar da overflow.
              Expanded(
                child: Text(name,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            DescriptionView(blocks: description),
          ],
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Categorie rapida de pe Acasa: iconita rotunda + nume, pentru lista orizontala.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.name, required this.iconUrl, this.onTap, this.httpHeaders});

  final String name;
  final String? iconUrl;
  final VoidCallback? onTap;
  /// Headere pentru cererea de imagine (ex. cookie de sesiune Odoo); null = fara headere.
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: iconUrl == null
                  ? const Icon(Icons.grid_view_rounded, color: AppColors.primary)
                  : CachedNetworkImage(
                      imageUrl: iconUrl!,
                      httpHeaders: httpHeaders,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const Icon(Icons.grid_view_rounded, color: AppColors.primary),
                    ),
            ),
            const SizedBox(height: 6),
            Text(name, style: AppTypography.caption, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

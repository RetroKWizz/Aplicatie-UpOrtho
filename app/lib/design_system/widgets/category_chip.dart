import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Categorie rapida de pe Acasa: iconita rotunda + nume, pentru lista orizontala.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.name, required this.iconUrl, this.onTap});

  final String name;
  final String? iconUrl;
  final VoidCallback? onTap;

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
                  : CachedNetworkImage(imageUrl: iconUrl!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            Text(name, style: AppTypography.caption, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

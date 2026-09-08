import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/models/banner.dart';
import '../colors.dart';
import '../typography.dart';

/// Card de banner: imagine (daca exista) peste gradient de brand, titlu/subtitlu/CTA.
/// `hero` = format lat, inaltime mare; altfel format de grila (promo).
class BannerCard extends StatelessWidget {
  const BannerCard({
    super.key,
    required this.banner,
    required this.imageUrl,
    this.onTap,
    this.hero = false,
    this.httpHeaders,
  });

  final AppBanner banner;
  /// URL absolut (clientul API il construieste); null = fara imagine.
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool hero;
  /// Headere pentru cererea de imagine (ex. cookie de sesiune Odoo); null = fara headere.
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: hero ? 16 / 9 : 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroGradient)),
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  httpHeaders: httpHeaders,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const SizedBox(),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x99000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banner.title, style: AppTypography.bannerTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(banner.subtitle!, style: AppTypography.bannerSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    if (banner.ctaText != null) ...[
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                        child: Text(banner.ctaText!, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                // Cardul promo (grid 2 coloane, childAspectRatio 4/3) e mult mai mic decat
                // hero-ul (16/9): un titlu de 2 randuri + subtitlu + buton nu incape mereu la
                // inaltimea fixa data de AspectRatio+Stack(fit: expand). LayoutBuilder ne da
                // latimea reala disponibila (ca Text-urile sa se poata infasura normal pe ea),
                // iar FittedBox(scaleDown) micsoreaza tot blocul UNIFORM doar daca nu incape pe
                // inaltime - niciodata nu il mareste. La hero (spatiu suficient) scale-ul ramane
                // 1.0, deci arata identic ca inainte; la promo cu text lung, se micsoreaza in loc
                // sa dea overflow. `maxLines` ramane si el mai strans pe forma promo, ca sa nu se
                // ajunga la un scale prea agresiv (text ilizibil de mic).
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              style: AppTypography.bannerTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (banner.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                banner.subtitle!,
                                style: AppTypography.bannerSubtitle,
                                maxLines: hero ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (banner.ctaText != null) ...[
                              SizedBox(height: hero ? 10 : 8),
                              FilledButton(
                                onPressed: onTap,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: hero ? 12 : 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(banner.ctaText!, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

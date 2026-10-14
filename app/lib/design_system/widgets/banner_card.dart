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
    // O imagine care poarta deja textul se arata singura: titlul si subtitlul scrise
    // peste ea se suprapuneau peste cele din poza. Cardul ramane apasabil, iar titlul
    // ramane eticheta pentru cititoarele de ecran.
    final imageCarriesText = banner.imageOnly && imageUrl != null;
    return Semantics(
      label: imageCarriesText ? banner.title : null,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: hero ? 16 / 9 : 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(gradient: context.colors.heroGradient),
                ),
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl!,
                    httpHeaders: httpHeaders,
                    // O poza pe care e scris textul se arata INTREAGA: taiata ca sa
                    // umple cardul, se pierd chiar cuvintele pentru care a fost facuta
                    // (pe staging, "Ortho Club" ramanea fara prima litera). Ce ramane
                    // pe margini e gradientul de brand. La un banner obisnuit taierea
                    // nu strica nimic, textul il scrie aplicatia peste.
                    fit: imageCarriesText ? BoxFit.contain : BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox(),
                  ),
                // Valul intunecat exista doar ca sa se citeasca textul peste imagine.
                // Fara text, el ar inchide degeaba o poza facuta cu grija.
                if (!imageCarriesText)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0x99000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                if (!imageCarriesText)
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
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth,
                            ),
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
                                      foregroundColor: context.colors.primary,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: hero ? 12 : 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      banner.ctaText!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
      ),
    );
  }
}

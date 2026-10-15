import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/models/banner.dart';
import '../colors.dart';
import '../typography.dart';

/// Banda lata de pe pagina de start a site-ului ("NOU la UpOrtho", "Descopera
/// produsele"): textul si butonul intr-o parte, poza produsului in cealalta, pe
/// fundal deschis.
///
/// Spre deosebire de `BannerCard`, aici textul NU se scrie peste poza: pozele de
/// produs ale magazinului sunt detaliate si pe fundal deschis, iar text alb peste
/// ele nu se citeste. Subtitlul urca deasupra titlului, ca pe site, unde face rolul
/// de supratitlu ("NOU la UpOrtho", "pana la -60%").
///
/// **Culorile sunt fixe pe ambele teme**, si asta e deliberat: banda e o reclama cu
/// identitatea ei, construita in jurul unor poze cu fundal gri deschis. Pe tema
/// intunecata, un text deschis peste acel gri n-ar avea contrast, iar violetul
/// deschis al temei intunecate (`#B079D6`) e facut pentru fundal aproape negru.
/// Poza nu se schimba cu tema; nici cadrul ei.
class FeatureBannerCard extends StatelessWidget {
  const FeatureBannerCard({
    super.key,
    required this.banner,
    required this.imageUrl,
    this.onTap,
    this.httpHeaders,
  });

  final AppBanner banner;

  /// URL absolut (clientul API il construieste); null = fara imagine.
  final String? imageUrl;
  final VoidCallback? onTap;
  final Map<String, String>? httpHeaders;

  /// Fundalul benzii: acelasi gri deschis pe care il au si pozele magazinului, ca
  /// marginea pozei sa nu se vada ca un dreptunghi lipit peste card.
  static const background = Color(0xFFEFEFF1);

  @override
  Widget build(BuildContext context) {
    // O poza pe care e scris deja textul se arata singura, pe toata banda - la fel
    // ca la hero si promo.
    final imageCarriesText = banner.imageOnly && imageUrl != null;

    return Semantics(
      label: imageCarriesText ? banner.title : null,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: background,
              child: imageCarriesText
                  ? _image(fit: BoxFit.contain)
                  : Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                            child: _text(context),
                          ),
                        ),
                        // Poza se arata INTREAGA, nu taiata: in spatiul ingust din
                        // dreapta, `cover` ar reteza tocmai produsul. Benzile care
                        // raman in jurul ei nu se vad - fundalul cardului e acelasi
                        // gri deschis ca al pozelor magazinului.
                        Expanded(flex: 4, child: _image(fit: BoxFit.contain)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _image({required BoxFit fit}) {
    if (imageUrl == null) return const SizedBox.shrink();
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      httpHeaders: httpHeaders,
      fit: fit,
      errorWidget: (_, _, _) => const SizedBox(),
    );
  }

  Widget _text(BuildContext context) {
    // FittedBox: pe un telefon ingust, un titlu de doua randuri plus buton nu incape
    // mereu la inaltimea data de `AspectRatio`. Blocul se micsoreaza uniform, nu se
    // reteaza - aceeasi solutie ca la cardul promo.
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (banner.subtitle case final String supratitlu
                  when supratitlu.isNotEmpty) ...[
                Text(
                  supratitlu,
                  style: AppTypography.caption(context).copyWith(
                    color: AppPalette.light.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              Text(
                banner.title,
                style: AppTypography.sectionTitle(context).copyWith(
                  color: AppPalette.light.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (banner.ctaText case final String cta when cta.isNotEmpty) ...[
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.light.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(cta, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

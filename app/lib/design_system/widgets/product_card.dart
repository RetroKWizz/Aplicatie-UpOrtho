import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Card de produs pentru grila de catalog. Strict presentational: primeste tot ce
/// afiseaza ca parametri simpli (siruri deja formatate, un URL, headere HTTP, o
/// culoare) - nu importa niciun model API, nu citeste niciun provider, nu stie de
/// sesiune. Spre deosebire de `BannerCard` (care primeste un `AppBanner` intreg -
/// vezi datoria tehnica din docs/DE-FACUT.md), acest widget nu repeta greseala.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.priceFormatted,
    this.code,
    this.imageUrl,
    this.httpHeaders,
    this.listAmountFormatted,
    this.discountLabel,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.ratingLabel,
    this.isFavorite,
    this.onToggleFavorite,
    this.onTap,
  });

  final String title;
  final String? code;
  /// URL absolut al imaginii; null = fara imagine (se afiseaza o iconita locala).
  final String? imageUrl;
  /// Headere pentru cererea de imagine (ex. cookie de sesiune Odoo); null = fara headere.
  final Map<String, String>? httpHeaders;

  /// Pretul curent, deja formatat de server (ex. "148,50 lei"). Singurul pret
  /// obligatoriu; pretul taiat si eticheta de reducere apar doar cand exista reducere.
  /// Pretul Ortho Club NU apare aici: pe site el se vede doar in pagina produsului,
  /// nu in grila, si cardul urmeaza site-ul.
  final String priceFormatted;
  /// Pretul dinainte de reducere, deja formatat; afisat taiat, langa pretul curent.
  final String? listAmountFormatted;
  /// Eticheta de reducere deja formatata (ex. "-55%"); apare ca insigna mica.
  final String? discountLabel;

  final String? badgeText;
  final Color? badgeColor;
  /// Culoarea textului etichetei; null = alb, ca pe site.
  final Color? badgeTextColor;

  /// Nota din recenzii, deja formatata de ecran (ex. "5.0"); null = produsul n-are
  /// recenzii si pastila nu se deseneaza, ca pe site.
  final String? ratingLabel;

  /// Starea inimioarei; null = cardul nu arata inimioara deloc (ex. produse
  /// similare, unde nu are ce cauta).
  final bool? isFavorite;
  final VoidCallback? onToggleFavorite;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zona de imagine: flex fix, nu AspectRatio - randamentul cardului
              // (2 Expanded intr-o Column cu inaltime finita, data de grila) nu
              // poate niciodata da overflow, indiferent de raportul de aspect ales
              // de ecran pentru grila.
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: AppColors.background),
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl!,
                        httpHeaders: httpHeaders,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                      )
                    else
                      const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                    if (badgeText != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _Pill(
                          text: badgeText!,
                          color: badgeColor ?? AppColors.accent,
                          textColor: badgeTextColor,
                          fontSize: 11,
                        ),
                      ),
                    if (ratingLabel != null)
                      Positioned(
                        top: 8,
                        right: isFavorite == null ? 8 : 44,
                        child: _RatingPill(label: ratingLabel!),
                      ),
                    if (isFavorite case final bool favorite)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: favorite ? 'Scoate de la favorite' : 'Adauga la favorite',
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color: favorite ? AppColors.danger : AppColors.textSecondary,
                          ),
                          onPressed: onToggleFavorite,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  // Titlurile din acest catalog sunt lungi ("Set bracketi metalici
                  // Atlas Mini .022") si continutul e variabil (badge/reducere
                  // optionale) - FittedBox(scaleDown) micsoreaza tot blocul
                  // UNIFORM doar daca nu incape pe inaltimea data de acest Expanded,
                  // niciodata nu il mareste. Aceeasi tehnica ca in BannerCard, pentru
                  // aceeasi clasa de defect (overflow de text intr-un card de grila).
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (code != null) ...[
                                const SizedBox(height: 2),
                                Text(code!, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                              const SizedBox(height: 6),
                              // Wrap, nu Row: pretul curent + pretul taiat + insigna
                              // de reducere impreuna pot depasi latimea unui card
                              // ingust de grila (2 coloane) - un Row fara copil
                              // flexibil ar da RenderFlex overflow (lovit direct de
                              // testul cu nume romanesc lung). Wrap trece pur si
                              // simplu pe randul urmator in loc sa dea eroare, iar
                              // FittedBox de mai sus absoarbe inaltimea suplimentara.
                              Wrap(
                                spacing: 6,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    priceFormatted,
                                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                  if (listAmountFormatted != null)
                                    Text(
                                      listAmountFormatted!,
                                      style: AppTypography.caption.copyWith(decoration: TextDecoration.lineThrough),
                                    ),
                                  if (discountLabel != null)
                                    _Pill(text: discountLabel!, color: AppColors.danger, fontSize: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastila cu nota din recenzii: steluta si nota, pe fundal alb, ca pe site.
class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: AppColors.accent),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.color,
    required this.fontSize,
    this.textColor,
  });
  final String text;
  final Color color;
  final Color? textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

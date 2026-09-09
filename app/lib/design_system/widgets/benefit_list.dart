import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Un beneficiu de magazin gata de afisat: simbolul, titlul si subtitlul.
///
/// Tip local de design system, nu modelul API `Benefit`: widgetul nu cunoaste lista
/// de iconite din Odoo si nu decodeaza nimic — primeste direct `IconData` (maparea
/// sta in ecran, ca la restul design system-ului, vezi datoria tehnica 1 din
/// docs/DE-FACUT.md).
///
/// `imageUrl` e un logo incarcat in Odoo (curier, sigla de card). Cand exista, se
/// arata el; altfel se deseneaza `icon`.
@immutable
class BenefitItem {
  const BenefitItem({required this.icon, required this.title, this.text, this.imageUrl});

  final IconData icon;
  final String title;
  final String? text;
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      other is BenefitItem &&
      other.icon == icon &&
      other.title == title &&
      other.text == text &&
      other.imageUrl == imageUrl;

  @override
  int get hashCode => Object.hash(icon, title, text, imageUrl);
}

/// Blocul de beneficii de sub butonul de cos: cate un rand pentru fiecare, cu simbol
/// la stanga.
///
/// Lista goala = niciun pixel desenat, ca toate sectiunile ecranului de produs.
class BenefitList extends StatelessWidget {
  const BenefitList({super.key, required this.items, this.httpHeaders});

  final List<BenefitItem> items;

  /// Headere pentru logourile incarcate in Odoo: ruta de imagine e autentificata, ca
  /// toate rutele de imagine ale modulului. Widgetul doar le transmite mai departe.
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

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
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BenefitSymbol(item: items[index], httpHeaders: httpHeaders),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(items[index].title,
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                        if (items[index].text != null && items[index].text!.isNotEmpty)
                          Text(items[index].text!, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Simbolul unui beneficiu: logoul incarcat in Odoo daca exista, altfel iconita.
/// Widget separat (si public) ca testele sa poata verifica pe care din doua l-a ales
/// randul, fara sa se agate de pixeli.
class _BenefitSymbol extends StatelessWidget {
  const _BenefitSymbol({required this.item, required this.httpHeaders});

  final BenefitItem item;
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    if (imageUrl == null) {
      return Icon(item.icon, size: 20, color: AppColors.primary);
    }
    return SizedBox(
      width: 28,
      height: 20,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        httpHeaders: httpHeaders,
        fit: BoxFit.contain,
        // Un logo care nu se incarca lasa randul cu iconita, nu cu o poza rupta.
        errorWidget: (_, _, _) => Icon(item.icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

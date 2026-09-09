import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Un tab: eticheta lui si continutul deja construit. Deliberat NU cunoaste niciun
/// model de wire — design system-ul primeste tipuri locale simple, iar maparea
/// contract -> tab sta in ecran (datoria tehnica 1 din docs/DE-FACUT.md).
///
/// Un tab fara continut nu se construieste deloc: filtrarea o face ecranul, care e
/// singurul care stie daca sectiunea are date.
@immutable
class ProductTabItem {
  const ProductTabItem({required this.label, required this.content});

  final String label;
  final Widget content;
}

/// Filele de jos ale paginii de produs (pe site: Descriere | Specificatii |
/// Documente | Recenzii), in locul sectiunilor stivuite una sub alta.
///
/// **Bara nu e un `Row`.** Cele patru etichete romanesti nu incap pe un rand de
/// 320px, iar un `Row` ar da RenderFlex overflow — greseala pe care proiectul asta
/// a mai facut-o. Etichetele stau intr-un `Wrap`: cand nu incap, trec pe randul
/// urmator si raman toate vizibile si apasabile. O bara cu derulare orizontala ar
/// fi ascuns taburi in afara ecranului, exact pe telefonul ingust unde conteaza cel
/// mai mult.
///
/// **Selectia e stare locala**, tinuta in acest widget: schimbarea tabului nu atinge
/// providerii, deci nu recere produsul si nu pierde cantitatile deja tastate in
/// tabelul de variante (care oricum sta deasupra taburilor si nu se demonteaza).
///
/// **Un singur tab nu e un tab**: cu o singura fila cu continut se deseneaza doar
/// continutul, fara bara — o eticheta singura ar fi doar zgomot. Zero file =
/// niciun pixel.
class ProductTabs extends StatefulWidget {
  const ProductTabs({super.key, required this.tabs});

  final List<ProductTabItem> tabs;

  @override
  State<ProductTabs> createState() => _ProductTabsState();
}

class _ProductTabsState extends State<ProductTabs> {
  int _selected = 0;

  @override
  void didUpdateWidget(ProductTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Lista de file se poate scurta intre doua randari (schimbarea variantei poate
    // aduce un produs fara documente). Fara asta, selectia ar arata catre un tab
    // care nu mai exista si randarea ar cadea cu RangeError.
    if (_selected >= widget.tabs.length) {
      _selected = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    if (tabs.isEmpty) return const SizedBox.shrink();
    if (tabs.length == 1) return tabs.single.content;

    final selected = _selected < tabs.length ? _selected : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < tabs.length; index++)
              _TabButton(
                label: tabs[index].label,
                selected: index == selected,
                onTap: () => setState(() => _selected = index),
              ),
          ],
        ),
        const SizedBox(height: 14),
        tabs[selected].content,
      ],
    );
  }
}

/// Eticheta unui tab: pastila plina cu violetul de brand cand e aleasa, contur
/// discret cand nu e.
class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.primaryLight,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/models/product_detail.dart';
import '../../api/same_origin.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/benefit_list.dart';
import '../../design_system/widgets/brand_card.dart';
import '../../design_system/widgets/description_view.dart';
import '../../design_system/widgets/document_list.dart';
import '../../design_system/widgets/image_gallery.dart';
import '../../design_system/widgets/price_tier_table.dart';
import '../../design_system/widgets/product_card.dart';
import '../../design_system/widgets/product_tabs.dart';
import '../../design_system/widgets/variant_order_table.dart';
import '../../design_system/widgets/variant_picker.dart';
import '../../providers.dart';
import '../cart/cart_controller.dart';
import '../description_blocks.dart';
import '../product_badge_palette.dart';
import 'document_controller.dart';
import 'product_controller.dart';

/// Pagina de produs. Ordinea sectiunilor e cea de pe uportho.ro (plan Faza 2,
/// Task 6): galerie, badge, titlu, stele, pret, praguri, praguri Ortho Club,
/// variante, disponibilitate, buton de cos, brand, beneficii, cod, apoi filele
/// Descriere | Specificatii | Documente | Recenzii si, sub ele, produsele similare.
///
/// Cele patru sectiuni de jos sunt **file**, ca pe site, nu sectiuni stivuite una
/// sub alta: stivuite faceau pagina incarcata. Filtrarea lor se face aici, in ecran
/// — `ProductTabs` primeste doar filele care chiar au continut, iar produsele
/// similare raman in afara lor, dedesubt, tot ca pe site.
///
/// **Fiecare sectiune fara date lipseste complet** — nu un chenar gol, nu un titlu
/// fara continut sub el. Nu e o subtilitate de stil: 354 din 619 produse reale
/// n-au variante, 214 n-au praguri de cantitate, 14 n-au descriere, deci ecranul
/// "sarac" e cazul obisnuit, nu exceptia. De aceea sectiunile se construiesc intr-o
/// lista si spatiul dintre ele vine din separator, nu din `Padding`-uri fixe care
/// ar lasa goluri in locul sectiunilor lipsa.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productControllerProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produs',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : 'Nu s-a putut incarca produsul.',
          onRetry: () => ref.read(productControllerProvider(productId).notifier).retry(),
        ),
        data: (value) => _ProductBody(productId: productId, state: value),
      ),
    );
  }
}

class _ProductBody extends ConsumerWidget {
  const _ProductBody({required this.productId, required this.state});

  final int productId;
  final ProductState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = state.detail;
    final api = ref.watch(apiClientProvider);
    final imageHeaders = ref.watch(imageHeadersProvider).value;

    // Galeria are nevoie de URL-uri absolute SI de cookie-ul de sesiune: rutele
    // `/products/<id>/gallery/<image_id>` sunt autentificate, ca toate rutele de
    // imagine ale modulului — fara header, pozele intorc 401 si galeria arata
    // iconita de eroare (greseala facuta deja de doua ori in acest proiect).
    // `images[].url` poate fi null (intrare video fara poza atasata).
    final galleryItems = [
      for (final image in detail.images)
        GalleryItem(
          imageUrl: image.url == null ? null : api.absoluteUrl(image.url!),
          videoUrl: image.videoUrl,
        ),
    ];
    final firstImageUrl =
        galleryItems.map((item) => item.imageUrl).nonNulls.firstOrNull;
    final galleryHeaders = firstImageUrl == null
        ? null
        : imageHeadersFor(firstImageUrl, apiBaseUrl: api.baseUrl, headers: imageHeaders);

    final variantGroups = [
      for (final attribute in detail.variants?.attributes ?? const <VariantAttribute>[])
        VariantGroup(
          id: attribute.id,
          name: attribute.name,
          options: [
            for (final value in attribute.values)
              VariantOption(
                id: value.id,
                label: value.name,
                selected: value.selected,
                available: value.available,
              ),
          ],
        ),
    ];

    // Logoul de brand e o ruta autentificata, ca toate imaginile modulului: URL
    // absolut plus cookie-ul de sesiune, altfel intoarce 401.
    final brand = detail.brand;
    final brandLogoUrl = brand?.logoUrl == null ? null : api.absoluteUrl(brand!.logoUrl!);

    // Beneficiile: logoul incarcat in Odoo cand exista (curier, sigla de card),
    // altfel iconita din lista fixa. Maparea iconita -> simbol de desenat sta aici,
    // in ecran: design system-ul nu cunoaste valorile din Odoo.
    final benefitItems = [
      for (final benefit in detail.benefits)
        BenefitItem(
          icon: _benefitIcons[benefit.icon] ?? Icons.info_outline,
          title: benefit.title,
          text: benefit.text,
          imageUrl: benefit.imageUrl == null ? null : api.absoluteUrl(benefit.imageUrl!),
        ),
    ];
    final firstBenefitImageUrl = benefitItems.map((item) => item.imageUrl).nonNulls.firstOrNull;
    final benefitHeaders = firstBenefitImageUrl == null
        ? null
        : imageHeadersFor(firstBenefitImageUrl, apiBaseUrl: api.baseUrl, headers: imageHeaders);

    final descriptionBlocks = [for (final block in detail.description) describeBlock(block)];
    final availabilityMessage = detail.availability?.message;

    // Filele de jos, in ordinea de pe site (Descriere | Specificatii | Documente |
    // Recenzii). Una fara continut nu ajunge in lista, deci nu exista nici ca
    // eticheta — cazul obisnuit pe catalogul real: doar 15 din 619 produse au
    // recenzii, documentele sunt rare, iar 14 produse n-au nici descriere. Cand
    // ramane o singura fila, `ProductTabs` ii arata doar continutul, fara bara.
    final tabs = <ProductTabItem>[
      if (hasBlockText(descriptionBlocks))
        ProductTabItem(
            label: 'Descriere', content: DescriptionView(blocks: descriptionBlocks)),
      if (detail.specs.isNotEmpty)
        ProductTabItem(label: 'Specificatii', content: _SpecTable(specs: detail.specs)),
      if (detail.documents.isNotEmpty)
        ProductTabItem(
          label: 'Documente',
          content: _DocumentsSection(productId: productId, documents: detail.documents),
        ),
      if (detail.reviews.isNotEmpty)
        ProductTabItem(label: 'Recenzii', content: _Reviews(reviews: detail.reviews)),
    ];

    final sections = <Widget>[
      if (galleryItems.isNotEmpty)
        ImageGallery(items: galleryItems, httpHeaders: galleryHeaders),
      _Heading(detail: detail),
      _PriceBlock(price: detail.price),
      // Cate un tabel per tabel trimis de server, in ordinea lui, cu titlul lui.
      // Ecranul nu stie niciun titlu si nu presupune cate tabele sunt: pe site pot fi
      // unul, doua sau niciunul, iar al doilea poarta un nume de campanie. Un tabel
      // care nu spune nimic nou (un singur rand, egal cu pretul de deasupra) nu mai
      // ajunge pana aici — il lasa afara serverul, care are si sumele si valutele.
      for (final table in detail.priceTables)
        PriceTierTable(
          title: table.title,
          note: [for (final block in table.note) describeBlock(block)],
          entries: _tiers(table.entries),
        ),
      // Tabelul de comanda pe variante inlocuieste selectorul: cand fiecare varianta
      // are randul ei, cu pretul si cantitatea ei, selectorul de atribute n-ar mai
      // spune nimic in plus. Selectorul ramane pentru cazul in care serverul trimite
      // atribute fara randuri (produs cu o singura varianta activa).
      if (detail.variantRows.isNotEmpty)
        _VariantOrderSection(productId: productId, state: state)
      else if (variantGroups.isNotEmpty)
        _VariantSection(productId: productId, groups: variantGroups, state: state),
      if (availabilityMessage != null && availabilityMessage.isNotEmpty)
        _Availability(message: availabilityMessage, inStock: detail.availability!.inStock),
      _CartButton(state: state),
      // Chenarul de brand si beneficiile stau deasupra descrierii, ca pe site.
      if (brand != null)
        BrandCard(
          name: brand.name,
          description: [for (final block in brand.description) describeBlock(block)],
          logoUrl: brandLogoUrl,
          httpHeaders: brandLogoUrl == null
              ? null
              : imageHeadersFor(brandLogoUrl, apiBaseUrl: api.baseUrl, headers: imageHeaders),
        ),
      if (benefitItems.isNotEmpty)
        BenefitList(items: benefitItems, httpHeaders: benefitHeaders),
      if (detail.defaultCode != null && detail.defaultCode!.isNotEmpty)
        Text('Cod: ${detail.defaultCode}', style: AppTypography.caption),
      if (tabs.isNotEmpty) ProductTabs(tabs: tabs),
      // Produsele similare raman in afara filelor, dedesubt, ca pe site.
      if (detail.similar.isNotEmpty)
        _Section(title: 'Produse similare', child: _SimilarList(products: detail.similar)),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) => sections[index],
    );
  }

  /// Praguri -> intrari de tabel. Sumele raman sirurile formatate de server;
  /// aplicatia nu compune si nu calculeaza niciodata un pret.
  List<PriceTierEntry> _tiers(List<PriceTier> tiers) => [
        for (final tier in tiers)
          PriceTierEntry(label: tier.label, priceFormatted: tier.price.formatted),
      ];

}

/// Iconita desenata pentru fiecare valoare din lista fixa a Odoo. E rezerva: cand
/// beneficiul are un logo incarcat, se arata logoul.
const _benefitIcons = {
  BenefitIcon.club: Icons.card_membership_outlined,
  BenefitIcon.delivery: Icons.local_shipping_outlined,
  BenefitIcon.returns: Icons.assignment_return_outlined,
  BenefitIcon.payment: Icons.lock_outline,
  BenefitIcon.info: Icons.info_outline,
};

class _Heading extends StatelessWidget {
  const _Heading({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    final badge = detail.badge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null) ...[
          _Pill(text: badge.text, color: productBadgeColor(badge.color)),
          const SizedBox(height: 8),
        ],
        Text(detail.name, style: AppTypography.title),
        if (detail.rating.count > 0) ...[
          const SizedBox(height: 6),
          _RatingRow(rating: detail.rating),
        ],
      ],
    );
  }
}

/// Stelele si numarul de recenzii. Media nu se scrie ca numar: stelele o arata,
/// iar planul cere "stele + numar recenzii".
class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating});

  final ProductRating rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stars(value: rating.average),
        const SizedBox(width: 6),
        Text(
          rating.count == 1 ? '1 recenzie' : '${rating.count} recenzii',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, this.size = 16});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 1; index <= 5; index++)
          Icon(
            value >= index
                ? Icons.star_rounded
                : value >= index - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: AppColors.accent,
          ),
      ],
    );
  }
}

/// Pretul curent, pretul taiat, procentul de reducere si mentiunea de taxe. Toate
/// sirurile vin de la server; "-20%" se compune din `discount_pct`, care e tot un
/// camp de contract, nu un calcul local.
class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.price});

  final Price price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wrap, nu Row: pe un ecran ingust pretul + pretul taiat + insigna pot
        // depasi latimea, iar un Row fara copil flexibil ar da RenderFlex overflow.
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              price.formatted,
              style: AppTypography.title.copyWith(color: AppColors.primary, fontSize: 24),
            ),
            if (price.listFormatted != null)
              Text(
                price.listFormatted!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            if (price.discountPct != null)
              _Pill(text: '-${price.discountPct}%', color: AppColors.danger),
          ],
        ),
        if (price.withVat) ...[
          const SizedBox(height: 4),
          const Text('Taxe incluse', style: AppTypography.caption),
        ],
      ],
    );
  }
}

/// Tabelul de comanda pe variante: Atribute | Pret | Cantitate | Subtotal, plus
/// totalul de sub el.
///
/// Toate sumele vin de la server. Pretul unitar al unui rand e cel din ultimul
/// raspuns de preturi (acolo se vede pragul atins de cantitatea CUMULATA a tuturor
/// randurilor, deci o apasare pe un rand poate schimba pretul celorlalte), si abia
/// daca acela lipseste se cade pe pretul de la o bucata din detaliul produsului. La fel si
/// subtotalurile cu totalul: pana la primul raspuns de preturi se folosesc sumele de
/// pornire (cantitate zero) trimise chiar in detaliul produsului. Daca nici acelea
/// nu exista (server mai vechi), coloana ramane pe liniuta — ecranul nu are cum sa
/// scrie "0,00 lei" fara sa faca aritmetica pe bani, ceea ce ii e interzis
/// (CLAUDE.md).
///
/// Cat timp o cerere de preturi e in aer, cifrele ramase pe ecran sunt cele
/// dinainte: tabelul nu clipeste la fiecare apasare pe plus.
class _VariantOrderSection extends ConsumerWidget {
  const _VariantOrderSection({required this.productId, required this.state});

  final int productId;
  final ProductState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = {
      for (final line in state.prices?.lines ?? const <VariantPriceLine>[]) line.variantId: line,
    };

    final rows = [
      for (final row in state.detail.variantRows)
        VariantOrderRow(
          id: row.variantId,
          attributes: [for (final attribute in row.attributes) '${attribute.name}: ${attribute.value}'],
          code: row.defaultCode,
          stockLabel: _stockLabel(row.availability),
          inStock: row.availability?.inStock ?? true,
          priceFormatted: (lines[row.variantId]?.price ?? row.price).formatted,
          subtotalFormatted: (lines[row.variantId]?.subtotal ?? row.subtotal)?.formatted,
          qty: state.quantities[row.variantId] ?? 0,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VariantOrderTable(
          rows: rows,
          totalFormatted: (state.prices?.total ?? state.detail.variantTotal)?.formatted,
          // Steperul ramane activ si cat timp se recalculeaza: asta e tot rostul
          // debounce-ului din controller.
          onQuantityChanged: (variantId, quantity) =>
              ref.read(productControllerProvider(productId).notifier).setQuantity(variantId, quantity),
          footnote: state.pricesError,
        ),
        if (state.isPricing) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }

  /// Linia de stoc a randului. `availability` null inseamna ca magazinul nu arata
  /// disponibilitate pentru produsul asta — atunci randul n-are linie de stoc deloc.
  /// Cand exista mesaj, se arata mesajul serverului; altfel doar starea.
  static String? _stockLabel(ProductAvailability? availability) {
    if (availability == null) return null;
    final message = availability.message;
    if (message != null && message.isNotEmpty) return message;
    return availability.inStock ? 'In stoc' : 'Stoc epuizat';
  }
}

class _VariantSection extends ConsumerWidget {
  const _VariantSection({required this.productId, required this.groups, required this.state});

  final int productId;
  final List<VariantGroup> groups;
  final ProductState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VariantPicker(
          groups: groups,
          // Ecranul NU deduce local pretul variantei: cere serverului produsul cu
          // varianta aleasa si arata ce raspunde el.
          onSelected: state.isSwitchingVariant
              ? null
              : (_, valueId) =>
                  ref.read(productControllerProvider(productId).notifier).selectVariantValue(valueId),
        ),
        if (state.isSwitchingVariant) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (state.variantError != null) ...[
          const SizedBox(height: 8),
          Text(state.variantError!,
              style: AppTypography.caption.copyWith(color: AppColors.danger)),
        ],
      ],
    );
  }
}

class _Availability extends StatelessWidget {
  const _Availability({required this.message, required this.inStock});

  final String message;
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          inStock ? Icons.check_circle_outline : Icons.schedule,
          size: 18,
          color: inStock ? AppColors.success : AppColors.accent,
        ),
        const SizedBox(width: 8),
        // Expanded: mesajele reale sunt propozitii intregi ("Precomanda. Livrare
        // incepand cu 1 August") si fara el randul ar da overflow.
        Expanded(child: Text(message, style: AppTypography.body)),
      ],
    );
  }
}

/// Butonul de cos.
///
/// Cand produsul are tabel de variante, se adauga TOATE randurile cu cantitate mai
/// mare ca zero, intr-o singura cerere - la fel ca pe site, unde tabelul se trimite
/// dintr-o data. Pragurile de pret se aplica pe cantitatea cumulata a tabelului, deci
/// randurile trimise separat ar putea fi pretuite altfel decat le-a vazut clientul.
///
/// Fara tabel (produs cu o singura varianta) se adauga o bucata din varianta curenta.
class _CartButton extends ConsumerStatefulWidget {
  const _CartButton({required this.state});

  final ProductState state;

  @override
  ConsumerState<_CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends ConsumerState<_CartButton> {
  bool _sending = false;

  /// Ce se trimite: randurile comandate din tabel, sau varianta curenta cu o bucata.
  Map<int, int> get _lines {
    final ordered = {
      for (final entry in widget.state.quantities.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
    if (ordered.isNotEmpty) return ordered;
    if (widget.state.detail.variantRows.isNotEmpty) return const {};
    final variantId = widget.state.detail.variantId;
    return variantId == null ? const {} : {variantId: 1};
  }

  Future<void> _add() async {
    final lines = _lines;
    if (lines.isEmpty) return;
    setState(() => _sending = true);
    try {
      final warnings = await ref.read(cartControllerProvider.notifier).add(lines);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(warnings.isEmpty ? 'Adaugat in cos.' : warnings.join(' ')),
        action: SnackBarAction(label: 'Vezi cosul', onPressed: () => context.go('/cart')),
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error is ApiException ? error.message : 'Nu s-a putut adauga in cos.'),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLines = _lines.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: hasLines && !_sending ? _add : null,
          child: _sending
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Adauga in cos'),
        ),
        // Butonul dezactivat spune de ce e dezactivat, ca sa nu para stricat.
        if (!hasLines) ...[
          const SizedBox(height: 6),
          Text(
            widget.state.detail.variantRows.isNotEmpty
                ? 'Alege cantitatea din tabel'
                : 'Produsul nu se poate comanda acum',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Fila "Documente". Sectiune separata, cu providerul ei, ca starea de descarcare
/// (randul care lucreaza, mesajul de eroare) sa reconstruiasca doar lista de
/// documente, nu toata pagina de produs — altfel o apasare pe o fisa tehnica ar
/// reconstrui galeria si tabelele de pret.
///
/// Aici se face si maparea model -> element de design system: `DocumentList` nu
/// cunoaste modelele API.
class _DocumentsSection extends ConsumerWidget {
  const _DocumentsSection({required this.productId, required this.documents});

  final int productId;
  final List<ProductDocument> documents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiClientProvider);
    final state = ref.watch(documentsControllerProvider(productId));

    final items = [
      for (final document in documents)
        () {
          // URL absolut: cererea de descarcare are nevoie de host, nu de o cale
          // relativa. E ruta autentificata a modulului, deci fisierul vine prin
          // ApiClient, cu cookie-ul de sesiune — nu prin browserul telefonului.
          final url = api.absoluteUrl(document.url);
          return DocumentItem(
            name: document.name,
            fileName: document.fileName,
            url: url,
            busy: state.isBusy(url),
          );
        }(),
    ];

    return DocumentList(
      items: items,
      error: state.error,
      onOpen: (item) => ref
          .read(documentsControllerProvider(productId).notifier)
          .open(url: item.url, fileName: item.fileName ?? item.name),
    );
  }
}

class _SpecTable extends StatelessWidget {
  const _SpecTable({required this.specs});

  final List<ProductSpec> specs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < specs.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doua Expanded, nu latimi fixe: numele si valorile atributelor
                // romanesti sunt lungi si variabile.
                Expanded(
                  flex: 2,
                  child: Text(specs[index].name, style: AppTypography.caption),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(specs[index].value, style: AppTypography.body),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.reviews});

  final List<ProductReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < reviews.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _Stars(value: reviews[index].rating.toDouble(), size: 14),
                    const SizedBox(width: 6),
                    // Numele e singurul text de lungime necontrolata din rand.
                    Expanded(
                      child: Text(
                        reviews[index].author ?? 'Client UpOrtho',
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (reviews[index].date != null)
                      Text(reviews[index].date!, style: AppTypography.caption),
                  ],
                ),
                if (reviews[index].text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(reviews[index].text, style: AppTypography.body),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Produsele similare, in aceeasi forma ca in catalog: acelasi model `Product`,
/// acelasi `ProductCard`. Apasarea deschide detaliul produsului respectiv.
class _SimilarList extends ConsumerWidget {
  const _SimilarList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiClientProvider);
    final imageHeaders = ref.watch(imageHeadersProvider).value;

    return SizedBox(
      // Inaltime fixa: `ProductCard` isi imparte inaltimea intre poza si text cu
      // doua `Expanded`, deci are nevoie de o inaltime marginita de la parinte.
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          final imageUrl = product.imageUrl == null ? null : api.absoluteUrl(product.imageUrl!);
          return SizedBox(
            width: 160,
            child: ProductCard(
              title: product.name,
              code: product.defaultCode,
              imageUrl: imageUrl,
              httpHeaders: imageUrl == null
                  ? null
                  : imageHeadersFor(imageUrl, apiBaseUrl: api.baseUrl, headers: imageHeaders),
              priceFormatted: product.price.formatted,
              listAmountFormatted: product.price.listFormatted,
              discountLabel:
                  product.price.discountPct == null ? null : '-${product.price.discountPct}%',
              badgeText: product.badge?.text,
              badgeColor: product.badge == null ? null : productBadgeColor(product.badge!.color),
              onTap: () => context.push('/catalog/${product.id}'),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.sectionTitle),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reincearca')),
          ],
        ),
      ),
    );
  }
}

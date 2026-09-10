import '../api/models/description_block.dart';
import '../design_system/widgets/description_view.dart';

/// Maparea blocurilor de contract (`DescriptionBlock`, model API) pe datele de
/// afisare ale design system-ului (`DescriptionBlockData`).
///
/// Sta aici, nu intr-un ecran: acelasi HTML convertit de server ajunge in pagina de
/// produs (descriere, nota tabelelor de pret, descrierea brandului) si in checkout
/// (instructiunile de plata ale magazinului). Doua mapari paralele s-ar putea
/// desincroniza la urmatorul tip de bloc adaugat pe server.
List<DescriptionBlockData> describeBlocks(List<DescriptionBlock> blocks) =>
    [for (final block in blocks) describeBlock(block)];

DescriptionBlockData describeBlock(DescriptionBlock block) => DescriptionBlockData(
      style: switch (block.type) {
        DescriptionBlockType.heading => DescriptionBlockStyle.heading,
        DescriptionBlockType.paragraph => DescriptionBlockStyle.paragraph,
        DescriptionBlockType.bullets => DescriptionBlockStyle.bullets,
      },
      spans: describeSpans(block.spans),
      bullets: [for (final bullet in block.items) describeSpans(bullet.spans)],
    );

List<DescriptionSpanData> describeSpans(List<DescriptionSpan> spans) => [
      for (final span in spans)
        DescriptionSpanData(text: span.text, bold: span.bold, italic: span.italic),
    ];

/// `DescriptionView` ascunde singura blocurile fara text, dar titlul de sectiune e
/// desenat de ecran - fara verificarea asta, un continut format doar din blocuri
/// goale ar lasa un titlu suspendat peste nimic.
bool hasBlockText(List<DescriptionBlockData> blocks) => blocks.any((block) =>
    block.spans.any((span) => span.text.isNotEmpty) ||
    block.bullets.any((bullet) => bullet.any((span) => span.text.isNotEmpty)));

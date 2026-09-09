import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Tipurile de bloc de descriere pe care le deseneaza `DescriptionView`.
enum DescriptionBlockStyle { heading, paragraph, bullets }

/// O bucata de text cu formatarea ei. Tip local de design system (nu modelul API
/// `DescriptionSpan`): maparea contract -> date de afisare sta in ecran.
@immutable
class DescriptionSpanData {
  const DescriptionSpanData({required this.text, this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;

  @override
  bool operator ==(Object other) =>
      other is DescriptionSpanData && other.text == text && other.bold == bold && other.italic == italic;

  @override
  int get hashCode => Object.hash(text, bold, italic);
}

/// Un bloc: titlu sau paragraf (`spans`), ori lista cu buline (`bullets`, cate o
/// lista de span-uri per element).
@immutable
class DescriptionBlockData {
  const DescriptionBlockData({
    required this.style,
    this.spans = const [],
    this.bullets = const [],
  });

  final DescriptionBlockStyle style;
  final List<DescriptionSpanData> spans;
  final List<List<DescriptionSpanData>> bullets;
}

/// Descrierea produsului, randata din blocuri. **Fara HTML**: serverul trimite
/// deja blocuri si span-uri tocmai pentru ca aplicatia nu are motor HTML si nu
/// vrem sa introducem unul.
///
/// Lista goala (sau blocuri fara text) = niciun pixel desenat.
class DescriptionView extends StatelessWidget {
  const DescriptionView({super.key, required this.blocks});

  final List<DescriptionBlockData> blocks;

  static const _headingStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  @override
  Widget build(BuildContext context) {
    final rendered = <Widget>[];
    for (final block in blocks) {
      final widget = _buildBlock(block);
      if (widget != null) {
        if (rendered.isNotEmpty) rendered.add(const SizedBox(height: 10));
        rendered.add(widget);
      }
    }
    if (rendered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rendered,
    );
  }

  Widget? _buildBlock(DescriptionBlockData block) {
    switch (block.style) {
      case DescriptionBlockStyle.heading:
        return _text(block.spans, _headingStyle);
      case DescriptionBlockStyle.paragraph:
        return _text(block.spans, AppTypography.body);
      case DescriptionBlockStyle.bullets:
        final items = <Widget>[];
        for (final bullet in block.bullets) {
          final line = _text(bullet, AppTypography.body);
          if (line == null) continue;
          items.add(Padding(
            padding: EdgeInsets.only(top: items.isEmpty ? 0 : 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•', style: AppTypography.body),
                const SizedBox(width: 8),
                // Expanded: fara el, un element de lista lung ar impinge randul
                // peste latimea disponibila si ar da RenderFlex overflow pe un
                // ecran ingust.
                Expanded(child: line),
              ],
            ),
          ));
        }
        if (items.isEmpty) return null;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: items);
    }
  }

  /// `Text.rich` cu cate un `TextSpan` per bucata: bold si italic se aplica pe
  /// span-ul lor, nu pe tot paragraful. Un bloc fara text nu deseneaza un rand gol.
  Widget? _text(List<DescriptionSpanData> spans, TextStyle style) {
    final visible = spans.where((span) => span.text.isNotEmpty).toList();
    if (visible.isEmpty) return null;
    return Text.rich(
      TextSpan(
        children: [
          for (final span in visible)
            TextSpan(
              text: span.text,
              style: TextStyle(
                fontWeight: span.bold ? FontWeight.w700 : null,
                fontStyle: span.italic ? FontStyle.italic : null,
              ),
            ),
        ],
      ),
      style: style,
    );
  }
}

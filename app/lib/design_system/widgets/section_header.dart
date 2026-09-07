import 'package:flutter/material.dart';

import '../typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title, style: AppTypography.sectionTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

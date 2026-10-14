import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'theme_controller.dart';

/// Ecranul "Aspect": alegerea temei.
///
/// Alegerea ramane pe telefon, nu in cont - doi oameni care intra pe acelasi cont de
/// cabinet pot avea fiecare ce vor. Schimbarea se vede pe loc, fara repornire.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aspect')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Option(
            choice: AppThemeChoice.system,
            selected: choice,
            description: 'Se face intunecat cand si telefonul e intunecat',
            preview: const _SystemPreview(),
          ),
          _Option(
            choice: AppThemeChoice.light,
            selected: choice,
            description: 'Alb, cum arata acum',
            preview: const _ThemePreview(palette: AppPalette.light),
          ),
          _Option(
            choice: AppThemeChoice.dark,
            selected: choice,
            description: 'Odihnitor seara, consuma mai putina baterie',
            preview: const _ThemePreview(palette: AppPalette.dark),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
            child: Text(
              'Alegerea ramane pe telefonul tau, nu in cont.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends ConsumerWidget {
  const _Option({
    required this.choice,
    required this.selected,
    required this.description,
    required this.preview,
  });

  final AppThemeChoice choice;
  final AppThemeChoice selected;
  final String description;
  final Widget preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = choice == selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ref.read(themeControllerProvider.notifier).choose(choice),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Radio-ul e doar desenat: tot randul e apasabil, iar `Semantics` de
                // mai jos spune cititoarelor de ecran care optiune e aleasa.
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                preview,
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    selected: isSelected,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(choice.label,
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(description, style: AppTypography.caption),
                      ],
                    ),
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

/// Un patrat cu fundalul si accentul temei, ca sa se vada alegerea, nu doar numele ei.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.6)),
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: palette.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

/// Jumatate luminos, jumatate intunecat: asa arata "urmeaza telefonul".
class _SystemPreview extends StatelessWidget {
  const _SystemPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Expanded(child: ColoredBox(color: AppPalette.light.background, child: const SizedBox.expand())),
            Expanded(child: ColoredBox(color: AppPalette.dark.background, child: const SizedBox.expand())),
          ],
        ),
      ),
    );
  }
}

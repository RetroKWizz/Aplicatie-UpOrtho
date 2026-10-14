import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/colors.dart';
import 'design_system/theme.dart';
import 'features/settings/theme_controller.dart';
import 'router.dart';

class UpOrthoApp extends ConsumerWidget {
  const UpOrthoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'UpOrtho',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(themeControllerProvider).themeMode,
      // Paleta pe care o citesc ecranele prin `AppColors` se pune AICI, deasupra
      // tuturor rutelor: `builder` ruleaza inaintea arborelui de sub el, deci la
      // momentul in care se construieste primul ecran paleta e deja cea potrivita.
      // Pe tema de sistem, `Theme.of(context).brightness` e singurul loc din care se
      // afla ce a ales telefonul.
      builder: (context, child) {
        AppColors.use(Theme.of(context).brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
        return child ?? const SizedBox.shrink();
      },
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

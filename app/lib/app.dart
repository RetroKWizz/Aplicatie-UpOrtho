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
      title: 'Ortho Club',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(themeControllerProvider).themeMode,
      // Paleta intra in arbore AICI, deasupra tuturor rutelor. `AppThemeScope` e un
      // InheritedWidget, deci la schimbarea temei Flutter reconstruieste exact
      // ecranele care citesc culori - cu o globala, Scaffold-ul se facea intunecat
      // dar cardurile ramaneau luminoase. Pe tema de sistem,
      // `Theme.of(context).brightness` e singurul loc din care se afla ce a ales
      // telefonul.
      builder: (context, child) => AppThemeScope(
        palette: Theme.of(context).brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

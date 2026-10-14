import 'package:flutter/material.dart';

import 'colors.dart';

/// Tema aplicatiei, pentru o paleta data.
///
/// Culorile nu se scriu aici de doua ori: tot ce tine de suprafata si de text vine
/// din `palette`, aceeasi pe care o folosesc si ecranele prin `AppColors`.
ThemeData buildAppTheme(AppPalette palette, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: palette.primary,
    brightness: brightness,
    primary: palette.primary,
    surface: palette.surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.background,
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.primary,
        // Pe tema intunecata violetul e deschis, deci textul alb peste el s-ar citi
        // prost: pe fundal deschis scrie cu culoarea textului de fundal.
        foregroundColor: brightness == Brightness.dark ? const Color(0xFF1B1B23) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
    dividerTheme: DividerThemeData(
      color: brightness == Brightness.dark ? const Color(0xFF2A2A34) : const Color(0xFFEEF0F5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      indicatorColor: palette.primary.withValues(alpha: 0.13),
    ),
  );
}

ThemeData buildLightTheme() => buildAppTheme(AppPalette.light, Brightness.light);
ThemeData buildDarkTheme() => buildAppTheme(AppPalette.dark, Brightness.dark);

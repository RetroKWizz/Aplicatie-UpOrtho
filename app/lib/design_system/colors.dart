import 'package:flutter/material.dart';

/// Paleta unei teme. Valorile de brand (primary, primaryLight, background,
/// textPrimary) ale temei luminoase sunt citite din foaia de stil publica a site-ului
/// uportho.ro (web.assets_frontend.min.css, variabilele de tema Odoo --o-color-1..5).
/// Nu se modifica dupa gust — daca par "gresite" fata de o alta sursa, verifica din
/// nou site-ul inainte de a le schimba.
@immutable
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.heroGradient,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final LinearGradient heroGradient;

  static const light = AppPalette(
    primary: Color(0xFF78449B), // --o-color-1 / --primary de pe site
    primaryDark: Color(0xFF5B3376),
    primaryLight: Color(0xFFBA9FCC), // --o-color-2 / --secondary de pe site
    background: Color(0xFFF9FAFE), // --o-color-3 de pe site
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF232F3E), // --o-color-5 de pe site
    textSecondary: Color(0xFF6E6E73),
    heroGradient: LinearGradient(
      colors: [Color(0xFF78449B), Color(0xFF5B3376)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Tema intunecata. **Violetul de brand se deschide aici**: `#78449B` pe un fundal
  /// aproape negru nu trece pragul de contrast si se citeste prost, mai ales la text
  /// mic. `#B079D6` e acelasi violet, doar luminat cat sa fie lizibil — e chiar
  /// nuanta din sigla Ortho Club, deci nu iese din brand.
  static const dark = AppPalette(
    primary: Color(0xFFB079D6),
    primaryDark: Color(0xFF8A57AE),
    primaryLight: Color(0xFF4A3860),
    background: Color(0xFF101016),
    surface: Color(0xFF1B1B23),
    textPrimary: Color(0xFFECECF1),
    textSecondary: Color(0xFF9A9AA6),
    heroGradient: LinearGradient(
      colors: [Color(0xFF55306F), Color(0xFF2B1B3A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

/// Culorile folosite de ecrane.
///
/// Cele care tin de suprafata si de text vin din paleta temei curente, pusa de
/// `UpOrthoApp` inainte sa se construiasca orice ecran (`AppColors.use`). Sunt
/// getteri, nu constante: o constanta n-ar putea sa se schimbe la trecerea pe
/// intuneric, iar alternativa — a trece paleta prin `context` in toate cele peste
/// doua sute de locuri — ar fi insemnat sa rescriem fiecare ecran.
///
/// `accent`, `success` si `danger` raman fixe: sunt culori cu INTELES (oferta, bine,
/// eroare), nu culori de fundal, iar intelesul nu se schimba cu tema.
abstract final class AppColors {
  static AppPalette _palette = AppPalette.light;

  /// Schimba paleta. O cheama doar radacina aplicatiei, inainte de a construi arborele.
  static void use(AppPalette palette) => _palette = palette;

  static AppPalette get palette => _palette;

  static Color get primary => _palette.primary;
  static Color get primaryDark => _palette.primaryDark;
  static Color get primaryLight => _palette.primaryLight;
  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static LinearGradient get heroGradient => _palette.heroGradient;

  /// Portocaliu, rol FUNCTIONAL: oferte/etichete. Nu vine de pe site — site-ul nu
  /// defineste un accent.
  static const accent = Color(0xFFF28C28);
  static const success = Color(0xFF2E9E5B);
  static const danger = Color(0xFFD93B3B);
}

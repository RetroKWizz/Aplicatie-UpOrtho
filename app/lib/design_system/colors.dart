import 'package:flutter/material.dart';

/// Paleta UpOrtho: valorile de brand (primary, primaryLight, background, textPrimary)
/// sunt citite din foaia de stil publica a site-ului uportho.ro
/// (web.assets_frontend.min.css, variabilele de tema Odoo --o-color-1..5).
/// Nu se modifica dupa gust — daca par "gresite" fata de o alta sursa, verifica
/// din nou site-ul inainte de a le schimba.
/// `accent` nu vine de pe site (site-ul nu defineste un accent) — este o alegere
/// functionala deliberata pentru oferte/etichete.
abstract final class AppColors {
  static const primary = Color(0xFF78449B); // --o-color-1 / --primary de pe site
  static const primaryDark = Color(0xFF5B3376); // nuanta mai inchisa, pentru gradient
  static const primaryLight = Color(0xFFBA9FCC); // --o-color-2 / --secondary de pe site
  static const accent = Color(0xFFF28C28); // portocaliu, rol FUNCTIONAL: oferte/etichete
  static const background = Color(0xFFF9FAFE); // --o-color-3 de pe site
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF232F3E); // --o-color-5 de pe site
  static const textSecondary = Color(0xFF6E6E73);
  static const success = Color(0xFF2E9E5B);
  static const danger = Color(0xFFD93B3B);
  static const heroGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

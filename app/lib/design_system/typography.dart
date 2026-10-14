import 'package:flutter/material.dart';

import 'colors.dart';

/// Stilurile de text ale aplicatiei.
///
/// Fiecare primeste contextul: culoarea textului vine din paleta temei, iar paleta se
/// ia din arbore (`AppThemeScope`), nu dintr-o globala — doar asa ecranul se
/// reconstruieste cand se schimba tema.
abstract final class AppTypography {
  static TextStyle title(BuildContext context) => TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700, color: context.colors.textPrimary, height: 1.2);

  static TextStyle sectionTitle(BuildContext context) => TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.textPrimary);

  static TextStyle body(BuildContext context) =>
      TextStyle(fontSize: 15, color: context.colors.textPrimary, height: 1.35);

  static TextStyle caption(BuildContext context) =>
      TextStyle(fontSize: 13, color: context.colors.textSecondary);

  /// Textul scris PESTE o imagine de banner ramane alb in ambele teme: fundalul lui
  /// e poza si valul intunecat, nu suprafata aplicatiei.
  static const bannerTitle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15);
  static const bannerSubtitle =
      TextStyle(fontSize: 14, color: Colors.white70, height: 1.3);
}

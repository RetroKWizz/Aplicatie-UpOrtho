import 'package:flutter/material.dart';

import 'colors.dart';

/// Stilurile de text ale aplicatiei.
///
/// Getteri, nu constante: culoarea textului vine din paleta temei curente, iar o
/// constanta ar fi ramas inghetata pe tema luminoasa. Dimensiunile si grosimile sunt
/// aceleasi in ambele teme — se schimba doar culoarea.
abstract final class AppTypography {
  static TextStyle get title => TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2);
  static TextStyle get sectionTitle =>
      TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get body =>
      TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.35);
  static TextStyle get caption => TextStyle(fontSize: 13, color: AppColors.textSecondary);

  /// Textul scris PESTE o imagine de banner ramane alb in ambele teme: fundalul lui
  /// e poza si valul intunecat, nu suprafata aplicatiei.
  static const bannerTitle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15);
  static const bannerSubtitle =
      TextStyle(fontSize: 14, color: Colors.white70, height: 1.3);
}

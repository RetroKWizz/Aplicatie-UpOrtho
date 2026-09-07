import 'package:flutter/material.dart';

import 'colors.dart';

abstract final class AppTypography {
  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2);
  static const sectionTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const body = TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.35);
  static const caption = TextStyle(fontSize: 13, color: AppColors.textSecondary);
  static const bannerTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15);
  static const bannerSubtitle = TextStyle(fontSize: 14, color: Colors.white70, height: 1.3);
}

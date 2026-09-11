import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/product_badge.dart';
import 'package:uportho_app/design_system/colors.dart';
import 'package:uportho_app/features/product_badge_palette.dart';

void main() {
  test('culorile magazinului se folosesc asa cum vin', () {
    const badge = ProductBadge(
      text: 'pana la -40%',
      backgroundColor: '#f47c0b',
      textColor: '#FFFFFF',
    );

    expect(productBadgeBackground(badge), const Color(0xFFF47C0B));
    expect(productBadgeForeground(badge), const Color(0xFFFFFFFF));
  });

  test('fara culori de la magazin se cade pe paleta de brand', () {
    const badge = ProductBadge(text: 'Nou', color: ProductBadgeColor.green);

    expect(productBadgeBackground(badge), AppColors.success);
    expect(productBadgeForeground(badge), Colors.white);
  });

  test('o culoare pe care nu o putem citi nu strica eticheta', () {
    const badge = ProductBadge(
      text: 'Nou',
      color: ProductBadgeColor.purple,
      backgroundColor: 'albastru',
    );

    expect(productBadgeBackground(badge), AppColors.primary);
  });
}

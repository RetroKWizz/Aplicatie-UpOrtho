import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/colors.dart';
import '../cart/cart_controller.dart';

/// Un tab din bara de jos.
class _Tab {
  const _Tab({required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _tabs = [
  _Tab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Acasa'),
  _Tab(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Catalog'),
  _Tab(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag, label: 'Cos'),
  _Tab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Cont'),
];

/// Tab bar-ul aplicatiei. Toate cele patru taburi sunt reale: Acasa, Catalog, Cos si
/// Cont.
///
/// Bara pluteste peste continut, pe sticla mata: continutul se vede trecand pe sub ea,
/// deci ecranul pare mai inalt decat e. De aceea ecranele primesc dedesubt o margine
/// cat bara (`extendBody` + `MediaQuery` cu padding de jos marit) - altfel ultimul
/// rand al unei liste ar ramane pentru totdeauna sub sticla.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  /// Inaltimea barei plutitoare, fara marginea de siguranta de jos a telefonului.
  static const barHeight = 64.0;
  static const _bottomMargin = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cate bucati sunt in cos, pentru pastila de pe tabul "Cos". Cosul se citeste o
    // singura data pentru toata aplicatia: acelasi provider il foloseste si ecranul
    // de cos, si checkout-ul.
    final cartQuantity = ref.watch(cartQuantityProvider);
    final media = MediaQuery.of(context);
    final reserved = barHeight + _bottomMargin + media.padding.bottom;

    return Scaffold(
      extendBody: true,
      body: MediaQuery(
        data: media.copyWith(
          padding: media.padding.copyWith(bottom: reserved),
          viewPadding: media.viewPadding.copyWith(bottom: reserved),
        ),
        child: navigationShell,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, _bottomMargin + media.padding.bottom),
        child: _GlassBar(
          currentIndex: navigationShell.currentIndex,
          cartQuantity: cartQuantity,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.currentIndex,
    required this.cartQuantity,
    required this.onTap,
  });

  final int currentIndex;
  final int cartQuantity;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ShellScreen.barHeight / 2),
      child: BackdropFilter(
        // Sticla mata: ce trece pe sub bara se vede neclar, nu dispare. Fara blur,
        // bara ar fi doar un dreptunghi semi-transparent si textul de sub ea s-ar
        // citi prin el.
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: ShellScreen.barHeight,
          decoration: BoxDecoration(
            // Sticla ia culoarea suprafetei temei: alba pe luminos, aproape neagra pe
            // intunecat. O sticla alba peste un ecran intunecat ar fi aratat ca o
            // bucata de hartie lipita pe el.
            color: context.colors.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(ShellScreen.barHeight / 2),
            border: Border.all(
              color: context.colors.textPrimary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var index = 0; index < _tabs.length; index++)
                Expanded(
                  child: _GlassTab(
                    tab: _tabs[index],
                    selected: index == currentIndex,
                    badgeCount: index == 2 ? cartQuantity : 0,
                    onTap: () => onTap(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTab extends StatelessWidget {
  const _GlassTab({
    required this.tab,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.primary : context.colors.textSecondary;
    final icon = Icon(selected ? tab.activeIcon : tab.icon, size: 22, color: color);
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              // Pastila sub tabul activ: se vede de la distanta unde esti, fara sa
              // depinzi de deosebirea dintre doua nuante de violet.
              color: selected ? context.colors.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                badgeCount > 0
                    ? Badge.count(count: badgeCount, child: icon)
                    : icon,
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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

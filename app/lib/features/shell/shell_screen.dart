import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cart/cart_controller.dart';

/// Tab bar-ul aplicatiei. Toate cele patru taburi sunt reale: Acasa, Catalog, Cos
/// (Faza 3) si Cont (Faza 4).
class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cate bucati sunt in cos, pentru pastila de pe tabul "Cos". Cosul se citeste o
    // singura data pentru toata aplicatia: acelasi provider il foloseste si ecranul
    // de cos, si checkout-ul.
    final cartQuantity = ref.watch(cartQuantityProvider);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index,
            initialLocation: index == navigationShell.currentIndex),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Acasa'),
          const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Catalog'),
          NavigationDestination(
            icon: Badge.count(
              count: cartQuantity,
              isLabelVisible: cartQuantity > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge.count(
              count: cartQuantity,
              isLabelVisible: cartQuantity > 0,
              child: const Icon(Icons.shopping_bag),
            ),
            label: 'Cos',
          ),
          const NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Cont'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'api/models/checkout.dart';
import 'features/account/account_screen.dart';
import 'features/account/invoices_screen.dart';
import 'features/account/order_detail_screen.dart';
import 'features/account/orders_screen.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/checkout/order_confirmed_screen.dart';
import 'features/home/home_screen.dart';
import 'features/product/product_screen.dart';
import 'features/shell/shell_screen.dart';

/// Notifica GoRouter cand se schimba starea de auth, ca sa re-evalueze redirect-ul.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading && !auth.hasValue) return null; // inca restauram sesiunea
      final signedIn = auth.value is SignedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!signedIn && !onLogin) return '/login';
      if (signedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => ShellScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/catalog',
              builder: (_, state) {
                final categoryId = int.tryParse(state.uri.queryParameters['category_id'] ?? '');
                return CatalogScreen(initialCategoryId: categoryId);
              },
              routes: [
                // Pagina de produs, ca ruta copil: ramane in tabul Catalog (bara
                // de jos nu dispare) si butonul de inapoi duce la grila, nu la
                // Acasa. Un produs similar apasat din pagina curenta se deschide
                // peste ea, tot pe aceasta ruta.
                GoRoute(
                  path: ':id',
                  // Un id nenumeric (link stricat, deep link ciudat) nu are voie
                  // sa arunce in `int.parse`: se cade inapoi pe catalog.
                  redirect: (_, state) =>
                      int.tryParse(state.pathParameters['id'] ?? '') == null ? '/catalog' : null,
                  builder: (_, state) =>
                      ProductScreen(productId: int.parse(state.pathParameters['id']!)),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/cart',
              builder: (_, _) => const CartScreen(),
              routes: [
                // Checkout-ul si confirmarea raman in tabul "Cos": butonul de inapoi
                // duce la cos, nu la Acasa, iar bara de jos nu dispare.
                GoRoute(path: 'checkout', builder: (_, _) => const CheckoutScreen()),
                GoRoute(
                  path: 'confirmed/:id',
                  redirect: (_, state) =>
                      int.tryParse(state.pathParameters['id'] ?? '') == null ? '/cart' : null,
                  builder: (_, state) => OrderConfirmedScreen(
                    orderId: int.parse(state.pathParameters['id']!),
                    // `extra` poarta doar instructiunile de plata offline, care nu
                    // sunt un camp al comenzii. Ecranul citeste comanda de la server,
                    // deci un `extra` pierdut (deep link, reintrare) nu-l strica.
                    confirmation: state.extra is CheckoutConfirmation
                        ? state.extra! as CheckoutConfirmation
                        : null,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/account',
              builder: (_, _) => const AccountScreen(),
              routes: [
                GoRoute(
                  path: 'orders',
                  builder: (_, _) => const OrdersScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      redirect: (_, state) =>
                          int.tryParse(state.pathParameters['id'] ?? '') == null
                              ? '/account/orders'
                              : null,
                      builder: (_, state) =>
                          OrderDetailScreen(orderId: int.parse(state.pathParameters['id']!)),
                    ),
                  ],
                ),
                GoRoute(path: 'invoices', builder: (_, _) => const InvoicesScreen()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/profile.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../auth/auth_controller.dart';
import 'account_controller.dart';
import 'addresses_screen.dart';
import 'favorites_screen.dart';
import 'ortho_club_card.dart';
import 'password_screen.dart';
import '../settings/appearance_screen.dart';
import '../settings/theme_controller.dart';
import 'payment_methods_screen.dart';
import 'profile_screen.dart';

/// Ecranul "Contul meu": starea de membru Ortho Club, apoi drumurile spre comenzi,
/// facturi, adrese si datele contului.
///
/// Ecranul nu mai arata liste scurte de comenzi/facturi/adrese, ci cate sunt si o
/// sageata spre lista intreaga: continutul lor are oricum ecran propriu, iar aici
/// trei liste trunchiate una sub alta impingeau tot ce conteaza sub pliu.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.value is SignedIn ? (auth.value! as SignedIn).user : null;
    final club = ref.watch(profileProvider).value?.club;
    final orders = ref.watch(ordersProvider).value;
    final invoices = ref.watch(invoicesProvider).value;
    final addresses = ref.watch(addressesProvider).value;
    final loyaltyCards =
        ref.watch(loyaltyProvider).value ?? const <LoyaltyCard>[];
    final cards = ref.watch(paymentMethodsProvider).value;
    final theme = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contul meu')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(ordersProvider);
          ref.invalidate(invoicesProvider);
          ref.invalidate(addressesProvider);
          ref.invalidate(loyaltyProvider);
          ref.invalidate(paymentMethodsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(user.name, style: AppTypography.title(context)),
              ),
            // Blocul de club lipseste cu totul pe un cont care n-a avut niciodata
            // abonament; serverul trimite atunci `null`.
            if (club case final club?) ...[
              OrthoClubCard(club: club),
              const SizedBox(height: 12),
            ],
            _MenuCard(
              items: [
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Comenzi',
                  trailingText: orders?.total.toString(),
                  onTap: () => context.go('/account/orders'),
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: 'Facturi',
                  trailingText: invoices?.total.toString(),
                  onTap: () => context.go('/account/invoices'),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'Adrese',
                  trailingText: addresses?.length.toString(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.favorite_border,
                  label: 'Favorite',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MenuCard(
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Datele contului',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.credit_card,
                  label: 'Cardurile mele',
                  trailingText: cards?.length.toString(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.brightness_6_outlined,
                  label: 'Aspect',
                  trailingText: theme.label,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  label: 'Schimba parola',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PasswordScreen()),
                  ),
                ),
              ],
            ),
            if (loyaltyCards.isNotEmpty) ...[
              const SizedBox(height: 12),
              _LoyaltyCards(cards: loyaltyCards),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Iesi din cont'),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Numarul din dreapta (cate comenzi, cate facturi). Lipseste cat timp lista inca
  /// se incarca - un "0" aratat pe loc ar fi o minciuna scurta, dar tot minciuna.
  final String? trailingText;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    // `Material`, nu un `Container` colorat: ListTile isi deseneaza fundalul si
    // cercul de apasare pe cel mai apropiat Material, iar un DecoratedBox peste el
    // le-ar ascunde (Flutter chiar da assert pe asta).
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              const Divider(height: 1, indent: 52, color: Color(0xFFEEF0F5)),
            ListTile(
              leading: Icon(item.icon, color: context.colors.primary),
              title: Text(
                item.label,
                style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.trailingText case final String text)
                    Text(text, style: AppTypography.caption(context)),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
              onTap: item.onTap,
            ),
          ],
        ],
      ),
    );
  }
}

/// Cardurile de fidelitate: vouchere si carduri cadou. Sectiunea lipseste complet
/// cand contul n-are niciunul - un titlu peste nimic n-ajuta.
class _LoyaltyCards extends StatelessWidget {
  const _LoyaltyCards({required this.cards});

  final List<LoyaltyCard> cards;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carduri si vouchere',
              style: AppTypography.sectionTitle(context),
            ),
            for (final card in cards)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.card_giftcard,
                  color: context.colors.primary,
                ),
                title: Text(card.program),
                subtitle: card.code == null ? null : Text('Cod: ${card.code}'),
                trailing: Text(
                  card.pointsDisplay,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

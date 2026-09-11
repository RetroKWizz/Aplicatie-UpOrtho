import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/models/account.dart';
import '../../design_system/colors.dart';
import '../auth/auth_controller.dart';
import 'account_controller.dart';
import 'address_form_screen.dart';
import 'favorites_screen.dart';
import 'password_screen.dart';
import 'profile_screen.dart';

/// Ecranul "Contul meu": cine e conectat, comenzile recente, facturile si adresele.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.value is SignedIn ? (auth.value! as SignedIn).user : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Contul meu')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
          ref.invalidate(invoicesProvider);
          ref.invalidate(addressesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (profile != null)
              _ProfileCard(
                name: profile.name,
                email: profile.email,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.favorite_border, color: AppColors.primary),
                    title: const Text('Favorite'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Schimba parola'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PasswordScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LoyaltyCards(),
            const SizedBox(height: 16),
            _RecentOrders(),
            const SizedBox(height: 16),
            _Invoices(),
            const SizedBox(height: 16),
            _Addresses(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Iesi din cont'),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.email, required this.onTap});
  final String name;
  final String? email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: email == null ? null : Text(email!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                if (action case final Widget action) action,
              ],
            ),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }
}

/// Cardurile de fidelitate: Ortho Club, carduri cadou, vouchere. Sectiunea lipseste
/// complet cand contul n-are niciun card cu puncte - un titlu peste nimic n-ajuta.
class _LoyaltyCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(loyaltyProvider).value ?? const [];
    if (cards.isEmpty) return const SizedBox.shrink();
    return _SectionCard(
      title: 'Ortho Club si vouchere',
      child: Column(
        children: [
          for (final card in cards)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.card_giftcard, color: AppColors.primary),
              title: Text(card.program),
              subtitle: card.code == null ? null : Text('Cod: ${card.code}'),
              trailing: Text(
                card.pointsDisplay,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentOrders extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return _SectionCard(
      title: 'Comenzile mele',
      action: TextButton(
        onPressed: () => context.go('/account/orders'),
        child: const Text('Vezi toate'),
      ),
      child: orders.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => _InlineError(
          message: error is ApiException ? error.message : 'Comenzile nu s-au putut incarca.',
          onRetry: () => ref.invalidate(ordersProvider),
        ),
        data: (page) => page.orders.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nu ai comenzi inca.'),
              )
            : Column(
                children: [
                  for (final order in page.orders.take(3))
                    OrderTile(order: order, onTap: () => context.go('/account/orders/${order.id}')),
                ],
              ),
      ),
    );
  }
}

/// Un rand de comanda, folosit si in "Contul meu" si in lista completa de comenzi.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, required this.onTap});
  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(order.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text([
        if (order.date case final String date) date,
        order.stateLabel,
      ].join(' • ')),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(order.total.formatted, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (order.invoiceCount > 0)
            const Text('cu factura',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _Invoices extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    return _SectionCard(
      title: 'Facturi',
      action: TextButton(
        onPressed: () => context.go('/account/invoices'),
        child: const Text('Vezi toate'),
      ),
      child: invoices.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => _InlineError(
          message: error is ApiException ? error.message : 'Facturile nu s-au putut incarca.',
          onRetry: () => ref.invalidate(invoicesProvider),
        ),
        data: (page) => page.invoices.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nu ai facturi inca.'),
              )
            : Column(
                children: [
                  for (final invoice in page.invoices.take(3))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(invoice.name),
                      subtitle: Text([
                        if (invoice.date case final String date) date,
                        if (invoice.paymentStateLabel case final String label) label,
                      ].join(' • ')),
                      trailing: Text(invoice.total.formatted,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Addresses extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    return _SectionCard(
      title: 'Adrese',
      action: PopupMenuButton<String>(
        tooltip: 'Adauga adresa',
        onSelected: (kind) => Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => AddressFormScreen(kind: kind)),
        ),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'delivery', child: Text('Adresa de livrare')),
          PopupMenuItem(value: 'invoice', child: Text('Adresa de facturare')),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Adauga', style: TextStyle(color: AppColors.primary)),
        ),
      ),
      child: addresses.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => _InlineError(
          message: error is ApiException ? error.message : 'Adresele nu s-au putut incarca.',
          onRetry: () => ref.invalidate(addressesProvider),
        ),
        data: (list) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final address in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(address.name),
                subtitle: address.oneLine.isEmpty ? null : Text(address.oneLine),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () async {
                  await Navigator.of(context).push<bool>(MaterialPageRoute(
                    builder: (_) => AddressFormScreen(
                      kind: address.type == 'invoice' ? 'invoice' : 'delivery',
                      addressId: address.id,
                    ),
                  ));
                  ref.invalidate(addressesProvider);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.danger))),
          TextButton(onPressed: onRetry, child: const Text('Reincearca')),
        ],
      ),
    );
  }
}

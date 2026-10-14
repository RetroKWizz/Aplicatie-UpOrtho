import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/account.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'account_controller.dart';
import 'address_form_screen.dart';

/// Adresele contului, impartite ca pe site: facturare si livrare. Impartirea vine de
/// la server, dupa regula magazinului - aceeasi adresa poate aparea in amandoua.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adrese'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Adauga adresa',
            onSelected: (kind) async {
              await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => AddressFormScreen(kind: kind)),
              );
              ref.invalidate(addressesProvider);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delivery', child: Text('Adresa de livrare')),
              PopupMenuItem(value: 'invoice', child: Text('Adresa de facturare')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Adauga', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ],
      ),
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is ApiException ? error.message : 'Adresele nu s-au putut incarca.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: AppColors.danger),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(addressesProvider),
                  child: const Text('Reincearca'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Nu ai nicio adresa salvata.', style: AppTypography.body),
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ..._group(context, ref, 'Facturare', list.where((a) => a.forBilling)),
                  ..._group(context, ref, 'Livrare', list.where((a) => a.forDelivery)),
                ],
              ),
      ),
    );
  }

  List<Widget> _group(
      BuildContext context, WidgetRef ref, String title, Iterable<Address> addresses) {
    if (addresses.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
      ),
      for (final address in addresses)
        ListTile(
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
    ];
  }
}

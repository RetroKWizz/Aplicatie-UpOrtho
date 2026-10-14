import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/account.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'account_controller.dart';
import 'address_form_screen.dart';

/// Adresele contului, in doua liste ca pe site: facturare si livrare.
///
/// Aceeasi adresa poate fi in amandoua - partenerul principal al contului chiar este
/// - si atunci apare in ambele sectiuni. Ca sa nu para o dublura, fiecare sectiune
/// are titlu mare cu iconita si numar, iar fiecare adresa poarta etichetele rolurilor
/// pe care i le da serverul (`for_billing` / `for_delivery`, calculate cu regula
/// magazinului). Asa se vede si in ce lista esti, si la ce mai e buna adresa.
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
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  ..._section(
                    context,
                    ref,
                    title: 'Adrese de facturare',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.primary,
                    addresses: list.where((a) => a.forBilling).toList(),
                  ),
                  ..._section(
                    context,
                    ref,
                    title: 'Adrese de livrare',
                    icon: Icons.local_shipping_outlined,
                    color: _deliveryColor,
                    addresses: list.where((a) => a.forDelivery).toList(),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Address> addresses,
  }) {
    if (addresses.isEmpty) return const [];
    return [
      _SectionHeader(title: title, icon: icon, color: color, count: addresses.length),
      for (final address in addresses)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AddressCard(
            address: address,
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
        ),
    ];
  }
}

/// Verdele etichetei si al titlului de livrare. Inchis cat sa treaca contrastul pe
/// alb, nu verdele "de succes" al paletei.
const _deliveryColor = Color(0xFF1C6B3A);

/// Capul unei liste: iconita colorata, titlul si cate adrese sunt, apoi o linie.
/// Titlul e singurul lucru care spune in ce lista te uiti, deci nu e un rand mic si
/// gri ca inainte - acolo s-a pierdut.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: AppTypography.sectionTitle),
              ),
              Text('$count', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: const Color(0xFFE7E1EE)),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onTap});

  final Address address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (address.forBilling)
                          const _RoleTag(
                            label: 'Facturare',
                            icon: Icons.receipt_long_outlined,
                            color: AppColors.primary,
                          ),
                        if (address.forDelivery)
                          const _RoleTag(
                            label: 'Livrare',
                            icon: Icons.local_shipping_outlined,
                            color: _deliveryColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.name,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (address.oneLine.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(address.oneLine, style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eticheta unui rol. Culoarea nu e singurul semn: fiecare are si iconita si textul
/// ei, ca rolurile sa se distinga si fara distingerea culorilor.
class _RoleTag extends StatelessWidget {
  const _RoleTag({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

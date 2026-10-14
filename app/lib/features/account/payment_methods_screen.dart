import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/profile.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'account_controller.dart';

/// Cardurile salvate ale contului.
///
/// Doar de citit, deliberat: cardul se salveaza platind, iar stergerea lui ramane pe
/// site. E o actiune de care nu te poti razgandi, si nu se face dintr-o apasare
/// gresita pe telefon. Intr-un cabinet cu mai multi utilizatori, cardul salvat de unul
/// se poate folosi de toti - exact ca pe site.
class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(paymentMethodsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cardurile mele')),
      body: cards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is ApiException ? error.message : 'Cardurile nu s-au putut incarca.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: AppColors.danger),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(paymentMethodsProvider),
                  child: const Text('Reincearca'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Nu ai niciun card salvat.\nUn card se salveaza cand platesti cu el.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  for (final card in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CardTile(card: card),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Cardurile se salveaza cand platesti cu ele si se sterg din contul '
                      'de pe site. Datele cardului nu trec niciodata prin aplicatie.',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final PaymentMethodCard card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.credit_card, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.name,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(card.provider, style: AppTypography.caption),
                ],
              ),
            ),
            // Un card de la un provider in mod test nu incaseaza bani reali. Se spune,
            // ca nimeni sa nu creada ca a platit cu el.
            if (card.isTest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'test',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A5200)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

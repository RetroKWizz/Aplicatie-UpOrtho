import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/models/checkout.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/description_view.dart';
import '../account/account_controller.dart';
import '../description_blocks.dart';

/// Ecranul de dupa trimiterea comenzii.
///
/// Starea comenzii se citeste de la server (`GET /orders/<id>`), nu se presupune din
/// raspunsul de confirmare: la plata cu cardul, ce s-a intamplat efectiv se stie abia
/// dupa ce providerul a raspuns, iar WebView-ul se poate inchide si fara plata.
///
/// `confirmation` e doar pentru instructiunile de plata offline (datele contului
/// bancar, conditiile de ramburs), care nu sunt un camp al comenzii.
class OrderConfirmedScreen extends ConsumerWidget {
  const OrderConfirmedScreen({super.key, required this.orderId, this.confirmation});

  final int orderId;
  final CheckoutConfirmation? confirmation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comanda trimisa'),
        automaticallyImplyLeading: false,
      ),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Body(
          title: 'Comanda a fost trimisa.',
          subtitle: error is ApiException
              ? error.message
              : 'Starea comenzii nu s-a putut citi acum. O gasesti in Contul meu.',
          confirmation: confirmation,
          orderId: orderId,
        ),
        data: (data) => _Body(
          title: 'Comanda ${data.name} a fost trimisa.',
          subtitle: data.stateLabel,
          confirmation: confirmation,
          orderId: orderId,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.title,
    required this.subtitle,
    required this.confirmation,
    required this.orderId,
  });

  final String title;
  final String subtitle;
  final CheckoutConfirmation? confirmation;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final payment = confirmation?.payment;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        if (payment != null && payment.isOffline && payment.instructions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.method ?? 'Plata',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  DescriptionView(blocks: describeBlocks(payment.instructions)),
                  if (payment.reference case final String reference) ...[
                    const SizedBox(height: 8),
                    Text('Referinta platii: $reference',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/account/orders/$orderId'),
          child: const Text('Vezi comanda'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/catalog'),
          child: const Text('Inapoi la catalog'),
        ),
      ],
    );
  }
}

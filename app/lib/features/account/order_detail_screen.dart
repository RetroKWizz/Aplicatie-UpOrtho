import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/account.dart';
import '../../design_system/colors.dart';
import 'account_controller.dart';
import 'invoice_download_controller.dart';

/// Detaliul unei comenzi: liniile, totalurile, adresele, facturile si platile.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text(order.value?.name ?? 'Comanda')),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 12),
                Text(
                  error is ApiException ? error.message : 'Comanda nu s-a putut incarca.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                  child: const Text('Reincearca'),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _OrderBody(order: data),
      ),
    );
  }
}

class _OrderBody extends ConsumerWidget {
  const _OrderBody({required this.order});
  final OrderDetail order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(invoiceDownloadProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(order.stateLabel,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            if (order.date case final String date)
              Text(date, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 16),
        for (final line in order.lines)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(line.name),
            subtitle: Text([
              if (line.variantName case final String variant) variant,
              '${line.quantity} x ${line.unitPrice.formatted}',
            ].join(' • ')),
            trailing: Text(line.subtotal.formatted,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        const Divider(),
        _Row(label: 'Produse', value: order.amounts.untaxed.formatted),
        _Row(label: 'TVA', value: order.amounts.tax.formatted),
        if (order.amounts.delivery.amount > 0)
          _Row(label: 'Transport', value: order.amounts.delivery.formatted),
        _Row(label: 'Total', value: order.amounts.total.formatted, emphasized: true),
        if (order.deliveryMethod case final String method) ...[
          const SizedBox(height: 16),
          _Block(title: 'Livrare', lines: [method]),
        ],
        if (order.deliveryAddress case final Address address)
          _Block(title: 'Adresa de livrare', lines: [address.name, address.oneLine]),
        if (order.invoiceAddress case final Address address)
          _Block(title: 'Adresa de facturare', lines: [address.name, address.oneLine]),
        if (order.payments.isNotEmpty)
          _Block(
            title: 'Plata',
            lines: [for (final payment in order.payments) '${payment.provider} — ${payment.amount.formatted}'],
          ),
        if (order.invoices.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Facturi', style: TextStyle(fontWeight: FontWeight.w700)),
          for (final invoice in order.invoices)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(invoice.name),
              subtitle: Text(invoice.paymentStateLabel ?? invoice.stateLabel),
              trailing: downloads.isBusy(invoice.id)
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
              onTap: () => ref.read(invoiceDownloadProvider.notifier).open(
                    invoiceId: invoice.id,
                    url: invoice.pdfUrl,
                    name: invoice.name,
                  ),
            ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
      fontSize: emphasized ? 17 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          for (final line in lines)
            if (line.isNotEmpty)
              Text(line, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

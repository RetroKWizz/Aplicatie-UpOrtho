import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/account.dart';
import '../../design_system/colors.dart';
import 'account_controller.dart';
import 'invoice_download_controller.dart';

/// Lista de facturi. Un tap descarca PDF-ul prin sesiunea aplicatiei si il deschide
/// cu vizualizatorul telefonului.
class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    final downloads = ref.watch(invoiceDownloadProvider);

    ref.listen(invoiceDownloadProvider, (previous, next) {
      final message = next.error;
      if (message != null && message != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Facturi')),
      body: invoices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : 'Facturile nu s-au putut incarca.',
          onRetry: () => ref.invalidate(invoicesProvider),
        ),
        data: (page) => page.invoices.isEmpty
            ? const Center(child: Text('Nu ai facturi inca.'))
            : ListView.separated(
                itemCount: page.invoices.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final invoice = page.invoices[index];
                  return _InvoiceTile(
                    invoice: invoice,
                    busy: downloads.isBusy(invoice.id),
                    onTap: () => ref.read(invoiceDownloadProvider.notifier).open(
                          invoiceId: invoice.id,
                          url: invoice.pdfUrl,
                          name: invoice.name,
                        ),
                  );
                },
              ),
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.busy, required this.onTap});
  final Invoice invoice;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(invoice.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text([
        if (invoice.date case final String date) date,
        if (invoice.paymentStateLabel case final String label) label,
      ].join(' • ')),
      trailing: busy
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(invoice.total.formatted,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.primary),
              ],
            ),
      onTap: busy ? null : onTap,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reincearca')),
          ],
        ),
      ),
    );
  }
}

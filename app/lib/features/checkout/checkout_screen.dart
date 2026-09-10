import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/models/checkout.dart';
import '../../design_system/colors.dart';
import '../../providers.dart';
import '../cart/cart_controller.dart';
import 'checkout_controller.dart';
import 'payment_webview_screen.dart';

/// Ecranul de checkout: adresa, metoda de livrare, metoda de plata, trimitere.
///
/// Fiecare alegere merge la server si intoarce checkout-ul intreg recalculat -
/// ecranul nu deduce nimic local. Alegerea altei adrese poate scoate curierul deja
/// ales, iar alegerea altui curier poate schimba metodele de plata permise (magazinul
/// leaga providerii de curier).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentOption? _selectedPayment;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizare comanda')),
      body: checkout.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CheckoutError(
          message: error is ApiException ? error.message : 'Checkout-ul nu s-a putut incarca.',
          onRetry: () => ref.read(checkoutControllerProvider.notifier).reload(),
        ),
        data: _buildBody,
      ),
    );
  }

  Widget _buildBody(Checkout checkout) {
    final selected = _resolveSelection(checkout);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: 'Adresa de livrare',
                child: _AddressPicker(
                  checkout: checkout,
                  onPick: (id) => _run(
                    () => ref.read(checkoutControllerProvider.notifier).chooseDeliveryAddress(id),
                  ),
                ),
              ),
              if (checkout.deliveryRequired)
                _Section(
                  title: 'Metoda de livrare',
                  child: _DeliveryPicker(
                    checkout: checkout,
                    onPick: (id) => _run(
                      () => ref.read(checkoutControllerProvider.notifier).chooseDeliveryMethod(id),
                    ),
                  ),
                ),
              _Section(
                title: 'Metoda de plata',
                child: _PaymentPicker(
                  options: checkout.paymentOptions,
                  selected: selected,
                  onPick: (option) => setState(() => _selectedPayment = option),
                ),
              ),
              for (final blocker in checkout.blockers)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          blocker.message,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _CheckoutFooter(
          checkout: checkout,
          canSend: checkout.blockers.isEmpty && selected != null && !_sending,
          sending: _sending,
          onSend: selected == null ? null : () => _confirm(selected),
        ),
      ],
    );
  }

  /// Metoda de plata aleasa, verificata contra listei curente: dupa o schimbare de
  /// curier, magazinul poate sa nu mai ofere metoda selectata inainte, iar un buton
  /// care ar trimite-o oricum ar primi 422 de la server.
  PaymentOption? _resolveSelection(Checkout checkout) {
    final selected = _selectedPayment;
    if (selected != null) {
      final match = checkout.paymentOptions.where(
        (o) => o.paymentMethodId == selected.paymentMethodId && o.providerId == selected.providerId,
      );
      if (match.isNotEmpty) return match.first;
    }
    return checkout.paymentOptions.length == 1 ? checkout.paymentOptions.first : null;
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error is ApiException ? error.message : 'Actiunea nu a reusit.')),
      );
    }
  }

  Future<void> _confirm(PaymentOption option) async {
    setState(() => _sending = true);
    try {
      final confirmation = await ref.read(checkoutControllerProvider.notifier).confirm(option);
      if (!mounted) return;
      if (confirmation.payment.isOffline) {
        context.go('/cart/confirmed/${confirmation.orderId}', extra: confirmation);
        return;
      }
      await _payInWebView(confirmation);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error is ApiException ? error.message : 'Comanda nu a putut fi trimisa.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Plata cu cardul: pagina de plata a magazinului, in aplicatie, cu aceeasi sesiune.
  /// La intoarcere se citeste starea reala a comenzii de la server - nu se presupune
  /// din faptul ca WebView-ul s-a inchis.
  Future<void> _payInWebView(CheckoutConfirmation confirmation) async {
    final api = ref.read(apiClientProvider);
    final sessionId = await ref.read(sessionStoreProvider).read();
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          baseUrl: api.baseUrl,
          path: confirmation.payment.url ?? '/shop/payment',
          returnUrlPrefix: confirmation.payment.returnUrlPrefix ?? '/shop/confirmation',
          sessionId: sessionId,
        ),
      ),
    );
    if (!mounted) return;
    await ref.read(cartControllerProvider.notifier).refresh();
    if (!mounted) return;
    context.go('/cart/confirmed/${confirmation.orderId}', extra: confirmation);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AddressPicker extends StatelessWidget {
  const _AddressPicker({required this.checkout, required this.onPick});
  final Checkout checkout;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioGroup<int>(
        groupValue: checkout.addresses.deliveryId,
        onChanged: (id) {
          if (id != null) onPick(id);
        },
        child: Column(
          children: [
            for (final address in checkout.addresses.available)
              RadioListTile<int>(
                value: address.id,
                title: Text(address.name),
                subtitle: address.oneLine.isEmpty ? null : Text(address.oneLine),
              ),
            if (checkout.addresses.available.length <= 1)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Adresele se adauga si se modifica din contul de pe uportho.ro.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryPicker extends StatelessWidget {
  const _DeliveryPicker({required this.checkout, required this.onPick});
  final Checkout checkout;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    if (checkout.deliveryMethods.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nu exista metoda de livrare pentru aceasta adresa.'),
        ),
      );
    }
    return Card(
      child: RadioGroup<int>(
        groupValue: checkout.selectedDeliveryMethodId,
        onChanged: (id) {
          if (id != null) onPick(id);
        },
        child: Column(
          children: [
            for (final method in checkout.deliveryMethods)
              RadioListTile<int>(
                value: method.id,
                // Un curier al carui tarif nu s-a putut calcula ramane vizibil, dar nu
                // se poate alege: `enabled: false` il lasa in lista cu motivul dedesubt,
                // exact ca pe site.
                enabled: method.available,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(method.name)),
                    Text(
                      method.free ? 'Gratuit' : method.price.formatted,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                subtitle: switch ((method.available, method.error, method.description)) {
                  (false, final String error, _) => Text(
                    error,
                    style: const TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                  (false, _, _) => const Text(
                    'Indisponibil pentru aceasta adresa',
                    style: TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                  (_, _, final String description) => Text(description),
                  _ => null,
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPicker extends StatelessWidget {
  const _PaymentPicker({required this.options, required this.selected, required this.onPick});
  final List<PaymentOption> options;
  final PaymentOption? selected;
  final ValueChanged<PaymentOption> onPick;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nu exista metode de plata disponibile pentru aceasta comanda.'),
        ),
      );
    }
    final byKey = {for (final option in options) _key(option): option};
    return Card(
      child: RadioGroup<String>(
        groupValue: selected == null ? null : _key(selected!),
        onChanged: (key) {
          final option = byKey[key];
          if (option != null) onPick(option);
        },
        child: Column(
          children: [
            for (final option in options)
              RadioListTile<String>(
                value: _key(option),
                title: Text(option.name),
                subtitle: Text(
                  option.isOffline
                      ? option.providerName
                      : '${option.providerName} — se plateste in pagina securizata a magazinului',
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Cheia care identifica o optiune in grup: metoda de plata singura nu ajunge -
  /// aceeasi metoda ("Card") poate fi oferita de mai multi provideri.
  static String _key(PaymentOption option) => '${option.providerId}-${option.paymentMethodId}';
}

class _CheckoutFooter extends StatelessWidget {
  const _CheckoutFooter({
    required this.checkout,
    required this.canSend,
    required this.sending,
    required this.onSend,
  });

  final Checkout checkout;
  final bool canSend;
  final bool sending;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final amounts = checkout.cart.amounts;
    return Material(
      elevation: 8,
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total de plata',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    amounts.total.formatted,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSend ? onSend : null,
                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Trimite comanda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutError extends StatelessWidget {
  const _CheckoutError({required this.message, required this.onRetry});
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

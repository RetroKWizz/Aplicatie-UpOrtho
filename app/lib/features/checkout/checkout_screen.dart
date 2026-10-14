import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/models/checkout.dart';
import '../../design_system/colors.dart';
import '../../providers.dart';
import '../account/account_controller.dart';
import '../account/address_form_screen.dart';
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

/// Un pas din finalizare. Lista se compune din checkout: cand magazinul nu cere
/// livrare (doar ridicare, produse fara transport), pasul de livrare nu exista deloc.
enum _Step { adrese, livrare, plata }

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentOption? _selectedPayment;
  bool _sending = false;

  /// Pasul la care se uita clientul acum. Nu se sare inainte peste un pas necompletat,
  /// dar inapoi se poate oricand, din capul paginii sau din "Schimba".
  _Step _step = _Step.adrese;

  List<_Step> _steps(Checkout checkout) => [
        _Step.adrese,
        if (checkout.deliveryRequired) _Step.livrare,
        _Step.plata,
      ];

  static String _stepLabel(_Step step) => switch (step) {
        _Step.adrese => 'Adrese',
        _Step.livrare => 'Livrare',
        _Step.plata => 'Plata',
      };

  /// Daca pasul e completat. De asta atarna si butonul de jos, si bifa verde din cap.
  bool _done(_Step step, Checkout checkout, PaymentOption? selected) => switch (step) {
        _Step.adrese =>
          checkout.addresses.deliveryId != null && checkout.addresses.invoiceId != null,
        _Step.livrare => checkout.selectedDeliveryMethodId != null,
        _Step.plata => selected != null && checkout.blockers.isEmpty,
      };

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
    final steps = _steps(checkout);
    // Pasul curent poate sa nu mai existe dupa un raspuns nou de la server (ex.
    // livrarea devine inutila): atunci cadem pe ultimul pas care exista.
    final step = steps.contains(_step) ? _step : steps.last;
    final index = steps.indexOf(step);
    final isLast = index == steps.length - 1;
    final done = _done(step, checkout, selected);

    return Column(
      children: [
        _StepHeader(
          steps: [for (final s in steps) _stepLabel(s)],
          current: index,
          doneUpTo: [
            for (final s in steps) _done(s, checkout, selected),
          ],
          onTap: (tapped) => setState(() => _step = steps[tapped]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ce s-a ales deja ramane scris sus, cu "Schimba" - altfel, la pasul de
              // plata, nu mai stii unde pleaca marfa.
              if (step != _Step.adrese)
                _ChosenSummary(
                  checkout: checkout,
                  showDelivery: step == _Step.plata && checkout.deliveryRequired,
                  onChangeAddresses: () => setState(() => _step = _Step.adrese),
                  onChangeDelivery: () => setState(() => _step = _Step.livrare),
                ),
              if (step == _Step.adrese) ...[
                _Section(
                  title: 'Adresa de livrare',
                  child: _AddressPicker(
                    // Ca pe site: la livrare se aleg doar adresele pe care magazinul le
                    // accepta acolo.
                    addresses: checkout.addresses.available.where((a) => a.forDelivery).toList(),
                    selectedId: checkout.addresses.deliveryId,
                    addLabel: 'Adauga adresa de livrare',
                    onPick: (id) => _run(
                      () => ref.read(checkoutControllerProvider.notifier).chooseDeliveryAddress(id),
                    ),
                    onAdd: () => _addAddress('delivery'),
                  ),
                ),
                _Section(
                  title: 'Adresa de facturare',
                  child: _AddressPicker(
                    addresses: checkout.addresses.available.where((a) => a.forBilling).toList(),
                    selectedId: checkout.addresses.invoiceId,
                    addLabel: 'Adauga adresa de facturare',
                    onPick: (id) => _run(
                      () => ref.read(checkoutControllerProvider.notifier).chooseInvoiceAddress(id),
                    ),
                    onAdd: () => _addAddress('invoice'),
                  ),
                ),
              ],
              if (step == _Step.livrare)
                _Section(
                  title: 'Cum primesti comanda',
                  child: _DeliveryPicker(
                    checkout: checkout,
                    onPick: (id) => _run(
                      () => ref.read(checkoutControllerProvider.notifier).chooseDeliveryMethod(id),
                    ),
                  ),
                ),
              if (step == _Step.plata)
                _Section(
                  title: 'Metoda de plata',
                  child: _PaymentPicker(
                    options: checkout.paymentOptions,
                    selected: selected,
                    onPick: (option) => setState(() => _selectedPayment = option),
                  ),
                ),
              // Blocajul pentru plata e deja scris in sectiunea ei; repetat aici, acelasi
              // mesaj aparea de doua ori pe ecran.
              for (final blocker in
                  checkout.blockers.where((b) => b.code != 'no_payment_method'))
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
          label: isLast ? 'Trimite comanda' : 'Continua',
          canSend: done && !_sending && (!isLast || checkout.blockers.isEmpty),
          sending: _sending && isLast,
          onSend: !done
              ? null
              : isLast
                  ? (selected == null ? null : () => _confirm(selected))
                  : () => setState(() => _step = steps[index + 1]),
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
        (o) =>
            o.paymentMethodId == selected.paymentMethodId &&
            o.providerId == selected.providerId &&
            o.tokenId == selected.tokenId,
      );
      if (match.isNotEmpty) return match.first;
    }
    return checkout.paymentOptions.length == 1 ? checkout.paymentOptions.first : null;
  }

  /// Adresa noua se adauga din chiar acest ecran: pe site, clientul o poate crea in
  /// pasul de checkout, nu doar din contul lui. Dupa salvare se reciteste checkout-ul,
  /// ca noua adresa sa apara in lista si sa poata fi aleasa imediat.
  Future<void> _addAddress(String kind) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddressFormScreen(kind: kind)),
    );
    if (saved != true || !mounted) return;
    ref.invalidate(addressesProvider);
    await _run(() => ref.read(checkoutControllerProvider.notifier).reload());
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
      // Plata cu cardul salvat s-a facut deja pe server. Daca nu a trecut (3-D Secure,
      // fonduri, card expirat), serverul raspunde `webview` si mergem in pagina de
      // plata a magazinului, ca pe site.
      if (confirmation.payment.isOffline || confirmation.payment.isPaidByCard) {
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
  const _AddressPicker({
    required this.addresses,
    required this.selectedId,
    required this.addLabel,
    required this.onPick,
    required this.onAdd,
  });
  final List<Address> addresses;
  final int? selectedId;
  final String addLabel;
  final ValueChanged<int> onPick;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioGroup<int>(
        groupValue: selectedId,
        onChanged: (id) {
          if (id != null) onPick(id);
        },
        child: Column(
          children: [
            for (final address in addresses)
              RadioListTile<int>(
                value: address.id,
                title: Text(address.name),
                subtitle: address.oneLine.isEmpty ? null : Text(address.oneLine),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(addLabel),
                  onPressed: onAdd,
                ),
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
  /// Cheia care identifica o optiune in grupul de radio-butoane.
  ///
  /// Metoda si providerul nu ajung: acelasi provider ofera si cardul nou, si fiecare
  /// card salvat, toate cu acelasi `payment_method_id`. Fara token in cheie, doua
  /// randuri diferite primeau aceeasi valoare, Flutter le vedea pe amandoua selectate,
  /// iar apasarea pe cardul salvat alegea de fapt cardul nou.
  static String _key(PaymentOption option) =>
      '${option.providerId}-${option.paymentMethodId}-${option.tokenId ?? 0}';
}

class _CheckoutFooter extends StatelessWidget {
  const _CheckoutFooter({
    required this.checkout,
    required this.label,
    required this.canSend,
    required this.sending,
    required this.onSend,
  });

  final Checkout checkout;
  final String label;
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
                      : Text(label),
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

/// Capul paginii de finalizare: pasii, cu bifa pe cei completati.
///
/// Un pas deja completat se poate apasa, ca sa te intorci; unul mai departe decat ai
/// ajuns nu - butonul de jos e singurul drum inainte, si el se aprinde doar cand
/// pasul curent chiar e completat.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.steps,
    required this.current,
    required this.doneUpTo,
    required this.onTap,
  });

  final List<String> steps;
  final int current;
  final List<bool> doneUpTo;
  final ValueChanged<int> onTap;

  static const _green = Color(0xFF1C6B3A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: doneUpTo[index - 1] ? _green.withValues(alpha: 0.25) : const Color(0xFFEEF0F5),
                  ),
                ),
              _StepChip(
                label: steps[index],
                number: index + 1,
                done: doneUpTo[index] && index != current,
                current: index == current,
                onTap: index < current || doneUpTo[index] ? () => onTap(index) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.label,
    required this.number,
    required this.done,
    required this.current,
    required this.onTap,
  });

  final String label;
  final int number;
  final bool done;
  final bool current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? _StepHeader._green
        : current
            ? AppColors.primary
            : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done || current ? color : const Color(0xFFEEF0F5),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: current ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: done || current ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ce s-a ales la pasii de dinainte, scris scurt, cu "Schimba" langa fiecare.
class _ChosenSummary extends StatelessWidget {
  const _ChosenSummary({
    required this.checkout,
    required this.showDelivery,
    required this.onChangeAddresses,
    required this.onChangeDelivery,
  });

  final Checkout checkout;
  final bool showDelivery;
  final VoidCallback onChangeAddresses;
  final VoidCallback onChangeDelivery;

  Address? _byId(int? id) {
    if (id == null) return null;
    for (final address in checkout.addresses.available) {
      if (address.id == id) return address;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final delivery = _byId(checkout.addresses.deliveryId);
    final invoice = _byId(checkout.addresses.invoiceId);
    final method = checkout.deliveryMethods
        .where((m) => m.id == checkout.selectedDeliveryMethodId)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (delivery != null)
              _SummaryBlock(
                icon: Icons.location_on_outlined,
                label: 'Livrare la',
                title: delivery.name,
                subtitle: delivery.oneLine,
                onChange: onChangeAddresses,
              ),
            if (invoice != null) ...[
              if (delivery != null) const Divider(height: 18),
              _SummaryBlock(
                icon: Icons.receipt_long_outlined,
                label: 'Factura pe',
                title: invoice.name,
                subtitle: invoice.oneLine,
                onChange: onChangeAddresses,
              ),
            ],
            if (showDelivery && method != null) ...[
              const Divider(height: 18),
              _SummaryBlock(
                icon: Icons.local_shipping_outlined,
                label: 'Cum primesti',
                title: method.name,
                subtitle: method.free ? 'Gratuit' : method.price.formatted,
                onChange: onChangeDelivery,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.onChange,
  });

  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Schimba', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
      ],
    );
  }
}

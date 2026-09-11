import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/models/cart.dart';
import '../../api/same_origin.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/quantity_stepper.dart';
import '../../providers.dart';
import 'cart_controller.dart';

/// Ecranul de cos. Toate sumele sunt siruri venite de la server; ecranul nu inmulteste
/// si nu aduna nimic (CLAUDE.md).
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  /// Linia pe care ruleaza chiar acum o cerere. Cat timp e setata, pasii de cantitate
  /// ai acelei linii sunt inactivi - doua apasari rapide ar trimite doua cereri
  /// concurente, iar cea intoarsa a doua ar suprascrie rezultatul celeilalte.
  int? _busyLineId;

  Future<void> _change(CartLine line, int quantity) async {
    setState(() => _busyLineId = line.id);
    try {
      await ref
          .read(cartControllerProvider.notifier)
          .setQuantity(variantId: line.variantId, quantity: quantity, lineId: line.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error is ApiException ? error.message : 'Nu s-a putut actualiza cosul.'),
      ));
    } finally {
      if (mounted) setState(() => _busyLineId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cosul meu')),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CartError(
          message: error is ApiException ? error.message : 'Cosul nu s-a putut incarca.',
          onRetry: () => ref.read(cartControllerProvider.notifier).refresh(),
        ),
        data: (data) => data.isEmpty ? const _EmptyCart() : _CartBody(
          cart: data,
          busyLineId: _busyLineId,
          onQuantityChanged: _change,
        ),
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.cart, required this.busyLineId, required this.onQuantityChanged});

  final Cart cart;
  final int? busyLineId;
  final void Function(CartLine line, int quantity) onQuantityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiClientProvider);
    final headers = ref.watch(imageHeadersProvider).value;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              if (cart.freeDelivery case final FreeDeliveryProgress progress)
                _FreeDeliveryBanner(progress: progress),
              for (final line in cart.lines)
                _CartLineTile(
                  line: line,
                  imageUrl: line.imageUrl == null ? null : api.absoluteUrl(line.imageUrl!),
                  headersFor: (url) =>
                      imageHeadersFor(url, apiBaseUrl: api.baseUrl, headers: headers),
                  busy: busyLineId == line.id,
                  onChanged: (quantity) => onQuantityChanged(line, quantity),
                ),
            ],
          ),
        ),
        _CartSummary(cart: cart),
      ],
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.imageUrl,
    required this.headersFor,
    required this.busy,
    required this.onChanged,
  });

  final CartLine line;
  final String? imageUrl;
  final Map<String, String>? Function(String) headersFor;
  final bool busy;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: imageUrl == null
                  ? const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary)
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      httpHeaders: headersFor(imageUrl),
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (line.variantName case final String variant)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(variant,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  const SizedBox(height: 4),
                  // Pretul pe bucata, cu cel dinainte de reducere taiat langa el -
                  // exact ce arata si cosul de pe site cand linia are reducere.
                  Row(
                    children: [
                      Text('${line.unitPrice.formatted} / buc',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      if (line.unitPrice.listFormatted case final String struck) ...[
                        const SizedBox(width: 6),
                        Text(struck,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            )),
                      ],
                    ],
                  ),
                  if (line.warning case final String warning)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(warning,
                          style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityStepper(
                        quantity: line.quantity,
                        busy: busy,
                        onChanged: onChanged,
                      ),
                      Text(line.subtotal.formatted,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Mai ai X lei pana la livrare gratuita", cu bara de progres. Pragul si sumele vin
/// de la server (le calculeaza tema magazinului), nu din aplicatie.
class _FreeDeliveryBanner extends StatelessWidget {
  const _FreeDeliveryBanner({required this.progress});
  final FreeDeliveryProgress progress;

  @override
  Widget build(BuildContext context) {
    final reached = progress.reached;
    return Card(
      color: reached ? AppColors.success.withValues(alpha: 0.10) : AppColors.primaryLight.withValues(alpha: 0.20),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(reached ? Icons.local_shipping : Icons.local_shipping_outlined,
                color: reached ? AppColors.success : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reached
                    ? 'Ai livrare gratuita.'
                    : 'Mai ai ${progress.remaining.formatted} pana la livrare gratuita.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});
  final Cart cart;

  @override
  Widget build(BuildContext context) {
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
              _SummaryRow(label: 'Produse', value: cart.amounts.untaxed.formatted),
              _SummaryRow(label: 'TVA', value: cart.amounts.tax.formatted),
              if (cart.amounts.delivery.amount > 0)
                _SummaryRow(label: 'Transport', value: cart.amounts.delivery.formatted),
              const Divider(),
              _SummaryRow(label: 'Total', value: cart.amounts.total.formatted, emphasized: true),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/cart/checkout'),
                  child: const Text('Continua comanda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
      fontSize: emphasized ? 18 : 14,
      color: AppColors.textPrimary,
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('Cosul este gol.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/catalog'),
            child: const Text('Vezi catalogul'),
          ),
        ],
      ),
    );
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message, required this.onRetry});
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

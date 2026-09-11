import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../api/same_origin.dart';
import '../../design_system/colors.dart';
import '../../design_system/widgets/product_card.dart';
import '../../providers.dart';
import '../favorites/favorites_controller.dart';
import '../product_badge_palette.dart';
import '../product_rating_label.dart';

/// Produsele puse la favorite din aplicatie.
///
/// Magazinul nu are o lista de favorite, deci aceasta e a aplicatiei si e legata de
/// cont, nu de telefon: se vede de pe orice dispozitiv pe care te conectezi.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesControllerProvider);
    final api = ref.watch(apiClientProvider);
    final imageHeaders = ref.watch(imageHeadersProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is ApiException ? error.message : 'Favoritele nu s-au putut incarca.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(favoritesControllerProvider),
                  child: const Text('Reincearca'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          if (state.products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nu ai produse favorite inca. Apasa inimioara de pe un produs ca sa il '
                  'gasesti mai usor data viitoare.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final imageUrl =
                  product.imageUrl == null ? null : api.absoluteUrl(product.imageUrl!);
              return ProductCard(
                title: product.name,
                code: product.defaultCode,
                imageUrl: imageUrl,
                httpHeaders: imageUrl == null
                    ? null
                    : imageHeadersFor(imageUrl, apiBaseUrl: api.baseUrl, headers: imageHeaders),
                priceFormatted: product.price.formatted,
                listAmountFormatted: product.price.listFormatted,
                discountLabel:
                    product.price.discountPct == null ? null : '-${product.price.discountPct}%',
                badgeText: product.badge?.text,
                badgeColor: product.badge == null ? null : productBadgeBackground(product.badge!),
                badgeTextColor:
                    product.badge == null ? null : productBadgeForeground(product.badge!),
                ratingLabel: productRatingLabel(product.rating),
                isFavorite: true,
                onToggleFavorite: () =>
                    ref.read(favoritesControllerProvider.notifier).toggle(product.id),
                onTap: () => context.push('/catalog/${product.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

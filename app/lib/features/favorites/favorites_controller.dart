import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_client.dart';
import '../../api/models/product.dart';
import '../../providers.dart';
import '../auth/auth_controller.dart';

/// Produsele favorite ale contului.
///
/// Magazinul nu are lista de favorite (modulul Odoo care o aduce nu e instalat), deci
/// lista traieste in modulul aplicatiei, legata de cont: intr-un cabinet cu mai multi
/// utilizatori, toti vad aceleasi favorite.
class FavoritesRepository {
  FavoritesRepository(this._api);
  final ApiClient _api;

  Future<FavoritesState> fetch() async => FavoritesState.fromJson(await _api.get('/favorites'));

  Future<FavoritesState> add(int productId) async => FavoritesState.fromJson(
      await _api.post('/favorites', body: {'product_id': productId}));

  Future<FavoritesState> remove(int productId) async =>
      FavoritesState.fromJson(await _api.deleteJson('/favorites/$productId'));
}

/// Lista de favorite plus id-urile ei, ca ecranele sa poata colora inimioara fara sa
/// mai intrebe serverul pentru fiecare produs.
class FavoritesState {
  const FavoritesState({required this.products, required this.ids});

  factory FavoritesState.fromJson(Map<String, dynamic> json) {
    final products = json['products'] as List? ?? const [];
    final ids = json['ids'] as List? ?? const [];
    return FavoritesState(
      products: [
        for (final item in products) Product.fromJson((item as Map).cast<String, dynamic>())
      ],
      ids: {for (final id in ids) id as int},
    );
  }

  final List<Product> products;
  final Set<int> ids;

  static const empty = FavoritesState(products: [], ids: {});
}

final favoritesRepositoryProvider =
    Provider<FavoritesRepository>((ref) => FavoritesRepository(ref.watch(apiClientProvider)));

/// Favoritele contului conectat.
///
/// Asteapta autentificarea inainte de a cere ceva: fara asta, al doilea cont care se
/// logheaza pe acelasi telefon ar vedea favoritele primului (vezi gotcha 3 din
/// CLAUDE.md).
class FavoritesController extends AsyncNotifier<FavoritesState> {
  @override
  Future<FavoritesState> build() async {
    final auth = await ref.watch(authControllerProvider.future);
    if (auth is! SignedIn) return FavoritesState.empty;
    return ref.read(favoritesRepositoryProvider).fetch();
  }

  bool isFavorite(int productId) => state.value?.ids.contains(productId) ?? false;

  /// Pune sau scoate produsul de la favorite. Inimioara se coloreaza din raspunsul
  /// serverului, nu inainte de el: altfel un apel picat ar lasa ecranul sa arate
  /// altceva decat are contul.
  Future<void> toggle(int productId) async {
    final repository = ref.read(favoritesRepositoryProvider);
    final favorite = isFavorite(productId);
    state = await AsyncValue.guard(
        () => favorite ? repository.remove(productId) : repository.add(productId));
  }
}

final favoritesControllerProvider = AsyncNotifierProvider<FavoritesController, FavoritesState>(
  FavoritesController.new,
  retry: (retryCount, error) => null,
);

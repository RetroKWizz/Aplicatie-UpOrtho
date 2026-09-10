import '../../api/api_client.dart';
import '../../api/models/cart.dart';

/// Repository pentru cos: `GET /cart` si `POST /cart/lines`.
///
/// Cosul e al serverului, nu al aplicatiei: fiecare modificare intoarce cosul
/// INTREG, nu doar linia atinsa. O singura cantitate schimbata poate trece un prag de
/// pret si rescrie subtotalurile tuturor liniilor aceluiasi produs, plus transportul
/// si progresul catre livrarea gratuita - de aceea ecranul se redeseneaza din
/// raspuns, niciodata din calcule locale.
class CartRepository {
  CartRepository(this._api);
  final ApiClient _api;

  Future<Cart> fetchCart() async => Cart.fromJson(await _api.get('/cart'));

  /// Adauga peste ce e deja in cos (butonul "Adauga in cos"). `quantities` are
  /// varianta ca cheie si cate bucati se adauga ca valoare; se trimit toate randurile
  /// tabelului de variante intr-o singura cerere.
  Future<Cart> addLines(Map<int, int> quantities) => _send([
        for (final entry in quantities.entries)
          if (entry.value > 0) {'variant_id': entry.key, 'add_qty': entry.value},
      ]);

  /// Fixeaza cantitatea unei linii (pasii +/- din ecranul de cos). `quantity` 0
  /// sterge linia.
  ///
  /// `add_qty` si `set_qty` sunt campuri diferite tocmai ca acelasi numar sa nu
  /// insemne lucruri diferite in cele doua ecrane.
  Future<Cart> setQuantity({required int variantId, required int quantity, int? lineId}) =>
      _send([
        {
          'variant_id': variantId,
          'set_qty': quantity,
          if (lineId case final int id) 'line_id': id,
        }
      ]);

  Future<Cart> removeLine({required int variantId, int? lineId}) =>
      setQuantity(variantId: variantId, quantity: 0, lineId: lineId);

  Future<Cart> _send(List<Map<String, dynamic>> lines) async =>
      Cart.fromJson(await _api.post('/cart/lines', body: {'lines': lines}));
}

import '../../api/api_client.dart';
import '../../api/models/product_detail.dart';

/// Repository pentru pagina de produs: `GET /products/<id>`. Nu stie de UI si nu
/// tine stare — varianta selectata vine ca parametru la fiecare apel, fiindca
/// serverul recalculeaza pret, cod si galerie pentru varianta ceruta.
class ProductRepository {
  ProductRepository(this._api);
  final ApiClient _api;

  /// Fara `variantId`, serverul intoarce combinatia implicita aleasa de Odoo.
  Future<ProductDetail> getProduct(int id, {int? variantId}) async {
    final path = variantId == null ? '/products/$id' : '/products/$id?variant_id=$variantId';
    return ProductDetail.fromJson(await _api.get(path));
  }
}

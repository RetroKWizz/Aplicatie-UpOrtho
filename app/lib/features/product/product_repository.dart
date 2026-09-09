import '../../api/api_client.dart';
import '../../api/models/product_detail.dart';

/// Repository pentru pagina de produs: `GET /products/<id>`. Nu stie de UI si nu
/// tine stare — varianta selectata vine ca parametru la fiecare apel, fiindca
/// serverul recalculeaza pret, cod si galerie pentru varianta ceruta.
class ProductRepository {
  ProductRepository(this._api);
  final ApiClient _api;

  /// Fara `values` si fara `variantId`, serverul intoarce combinatia implicita
  /// aleasa de Odoo.
  ///
  /// `values` e combinatia de valori de atribut (`product.template.attribute.value`),
  /// exact lista pe care serverul o trimite pe fiecare valoare din selector; el
  /// rezolva singur varianta, completeaza o combinatie partiala si cade pe cea mai
  /// apropiata combinatie posibila. Cand e dat, bate `variantId` (si pe server).
  Future<ProductDetail> getProduct(int id, {int? variantId, List<int>? values}) async {
    final query = switch ((values, variantId)) {
      (final List<int> v, _) when v.isNotEmpty => '?values=${v.join(',')}',
      (_, final int id) => '?variant_id=$id',
      _ => '',
    };
    return ProductDetail.fromJson(await _api.get('/products/$id$query'));
  }
}

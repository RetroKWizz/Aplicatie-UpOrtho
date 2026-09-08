import '../../api/api_client.dart';
import '../../api/models/catalog_category.dart';
import '../../api/models/products_response.dart';

/// Repository pentru catalog: `/categories` si `/products`. Nu stie despre UI,
/// paginare sau filtre active - primeste totul ca parametri, o data pe apel.
class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<List<CatalogCategory>> fetchCategories() async {
    final items = await _api.getList('/categories');
    return items.map((item) => CatalogCategory.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ProductsResponse> fetchProducts({
    int? categoryId,
    String? query,
    required int offset,
    required int limit,
  }) async {
    // Ordine fixa a parametrilor de query, ca sirul cerut sa fie deterministic
    // (testele il compara literal contra apelurilor inregistrate de FakeTransport).
    final parts = <String>[];
    if (categoryId != null) parts.add('category_id=$categoryId');
    if (query != null && query.trim().isNotEmpty) {
      parts.add('q=${Uri.encodeQueryComponent(query.trim())}');
    }
    parts.add('offset=$offset');
    parts.add('limit=$limit');
    final json = await _api.get('/products?${parts.join('&')}');
    return ProductsResponse.fromJson(json);
  }
}

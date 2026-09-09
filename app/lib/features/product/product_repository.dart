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

  /// Preturile tabelului de variante pentru cantitatile alese:
  /// `POST /products/<id>/prices` cu `{variant_id, qty}` pe fiecare rand.
  ///
  /// Serverul intoarce pretul unitar **la cantitatea cumulata a tuturor liniilor**
  /// (pragurile listei se aplica pe totalul din tabel, ca pe site), subtotalul
  /// fiecarei linii si totalul, toate gata formatate. Aplicatia nu inmulteste nimic:
  /// pragul face ca subtotalul sa nu fie pretul afisat inainte inmultit cu cantitatea
  /// (vezi CLAUDE.md).
  ///
  /// Se trimit TOATE randurile tabelului, inclusiv cele cu cantitatea zero: ele intra
  /// in cumul cu 0, dar isi primesc pretul unitar recalculat la noul total.
  ///
  /// `quantities` pastreaza ordinea randurilor (`Map` in Dart e ordonat dupa
  /// inserare), deci raspunsul vine in aceeasi ordine ca tabelul.
  Future<VariantPrices> priceVariants(int id, Map<int, int> quantities) async {
    final body = {
      'lines': [
        for (final entry in quantities.entries) {'variant_id': entry.key, 'qty': entry.value},
      ],
    };
    return VariantPrices.fromJson(await _api.post('/products/$id/prices', body: body));
  }
}

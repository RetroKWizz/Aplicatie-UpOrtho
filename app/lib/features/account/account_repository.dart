import '../../api/api_client.dart';
import '../../api/models/account.dart';

/// Repository pentru contul clientului: comenzi, facturi si adrese.
class AccountRepository {
  AccountRepository(this._api);
  final ApiClient _api;

  Future<OrdersPage> fetchOrders({int offset = 0, int limit = 20}) async =>
      OrdersPage.fromJson(await _api.get('/orders?offset=$offset&limit=$limit'));

  Future<OrderDetail> fetchOrder(int id) async =>
      OrderDetail.fromJson(await _api.get('/orders/$id'));

  Future<InvoicesPage> fetchInvoices({int offset = 0, int limit = 20}) async =>
      InvoicesPage.fromJson(await _api.get('/invoices?offset=$offset&limit=$limit'));

  Future<List<Address>> fetchAddresses() async {
    final data = await _api.getList('/addresses');
    return [for (final item in data) Address.fromJson(item as Map<String, dynamic>)];
  }
}

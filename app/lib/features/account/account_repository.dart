import '../../api/api_client.dart';
import '../../api/models/account.dart';
import '../../api/models/address_options.dart';
import '../../api/models/profile.dart';

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

  /// Datele contului, plus ce campuri sunt obligatorii si care se pot modifica.
  Future<AccountProfileResponse> fetchProfile() async =>
      AccountProfileResponse.fromJson(await _api.get('/account/profile'));

  /// Modifica datele contului. Se trimit doar campurile schimbate: cele netrimise
  /// raman cum sunt, iar unul trimis gol e o cerere de stergere, refuzata de server
  /// daca e obligatoriu.
  Future<AccountProfile> updateProfile(Map<String, dynamic> values) async {
    final body = await _api.post('/account/profile', body: {'values': values});
    return AccountProfile.fromJson((body['profile'] as Map).cast<String, dynamic>());
  }

  /// Cardurile de fidelitate ale contului (Ortho Club, carduri cadou, vouchere).
  Future<List<LoyaltyCard>> fetchLoyaltyCards() async {
    final data = await _api.getList('/loyalty');
    return [for (final item in data) LoyaltyCard.fromJson(item as Map<String, dynamic>)];
  }

  /// Ce cere formularul de adresa: campurile obligatorii si listele legate.
  ///
  /// Judetele vin cand se stie tara, orasele cand se stie judetul — ecranul cere din
  /// nou la fiecare pas, ca sa nu aducem mii de inregistrari pe telefon.
  Future<AddressOptions> fetchAddressOptions({int? countryId, int? stateId}) async {
    final query = [
      if (countryId != null) 'country_id=$countryId',
      if (stateId != null) 'state_id=$stateId',
    ].join('&');
    return AddressOptions.fromJson(
        await _api.get('/addresses/options${query.isEmpty ? '' : '?$query'}'));
  }

  /// O adresa a contului, cu id-urile de tara, judet si oras de care are nevoie
  /// formularul de editare.
  Future<AddressFormValues> fetchAddress(int id) async {
    final body = await _api.get('/addresses/$id');
    return AddressFormValues.fromJson((body['address'] as Map).cast<String, dynamic>());
  }

  /// Modifica o adresa existenta. Tipul adresei nu se trimite: e cel pe care il are
  /// deja inregistrarea, ca in magazin.
  Future<List<Address>> updateAddress({
    required int id,
    required Map<String, dynamic> values,
  }) async {
    final body = await _api.post('/addresses/$id', body: {'values': values});
    final list = body['addresses'] as List? ?? const [];
    return [for (final item in list) Address.fromJson((item as Map).cast<String, dynamic>())];
  }

  /// Schimba parola contului. Verificarile sunt ale portalului Odoo; la esec vine 422
  /// cu mesajul lui.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post('/account/password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  /// Adauga o adresa. `kind` e 'delivery' sau 'invoice'.
  ///
  /// Validarea e a magazinului: la esec, serverul intoarce 422 cu lista campurilor
  /// gresite in `details.fields`, iar ecranul le marcheaza pe fiecare.
  Future<List<Address>> createAddress({
    required String kind,
    required Map<String, dynamic> values,
  }) async {
    final body = await _api.post('/addresses', body: {'kind': kind, 'values': values});
    final list = body['addresses'] as List? ?? const [];
    return [for (final item in list) Address.fromJson((item as Map).cast<String, dynamic>())];
  }
}

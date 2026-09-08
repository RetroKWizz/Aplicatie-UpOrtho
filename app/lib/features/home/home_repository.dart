import '../../api/api_client.dart';
import '../../api/models/home_response.dart';

/// Repository pentru ecranul Acasa: stie doar despre apelul /home, nimic despre UI.
class HomeRepository {
  HomeRepository(this._api);
  final ApiClient _api;

  Future<HomeResponse> fetch() async => HomeResponse.fromJson(await _api.get('/home'));
}

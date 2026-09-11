import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_options.freezed.dart';
part 'address_options.g.dart';

/// O tara din formularul de adresa. `stateRequired` si `zipRequired` vin din Odoo si
/// decid ce campuri devin obligatorii — nu se ghicesc in aplicatie.
@freezed
abstract class AddressCountry with _$AddressCountry {
  const factory AddressCountry({
    required int id,
    required String name,
    String? code,
    @JsonKey(name: 'state_required') @Default(false) bool stateRequired,
    @JsonKey(name: 'zip_required') @Default(false) bool zipRequired,
  }) = _AddressCountry;

  factory AddressCountry.fromJson(Map<String, dynamic> json) => _$AddressCountryFromJson(json);
}

@freezed
abstract class AddressState with _$AddressState {
  const factory AddressState({required int id, required String name, String? code}) =
      _AddressState;

  factory AddressState.fromJson(Map<String, dynamic> json) => _$AddressStateFromJson(json);
}

@freezed
abstract class AddressCity with _$AddressCity {
  const factory AddressCity({required int id, required String name, String? zip}) = _AddressCity;

  factory AddressCity.fromJson(Map<String, dynamic> json) => _$AddressCityFromJson(json);
}

/// Ce campuri sunt obligatorii, separat pentru livrare si pentru facturare. Lista vine
/// de la magazin, deci include si ce adauga modulele clientului (orasul ca lista).
@freezed
abstract class AddressRequired with _$AddressRequired {
  const factory AddressRequired({
    @Default([]) List<String> delivery,
    @Default([]) List<String> invoice,
  }) = _AddressRequired;

  factory AddressRequired.fromJson(Map<String, dynamic> json) => _$AddressRequiredFromJson(json);
}

/// Tot ce trebuie ca sa desenezi formularul de adresa noua.
@freezed
abstract class AddressOptions with _$AddressOptions {
  const factory AddressOptions({
    @Default([]) List<AddressCountry> countries,
    @JsonKey(name: 'default_country_id') int? defaultCountryId,
    @Default([]) List<AddressState> states,
    @Default([]) List<AddressCity> cities,
    required AddressRequired required,
    /// Pe bazele clientului orasul e o inregistrare legata; pe altele e text liber.
    /// Ecranul afiseaza o lista sau un camp de text dupa valoarea asta.
    @JsonKey(name: 'city_is_list') @Default(false) bool cityIsList,
  }) = _AddressOptions;

  factory AddressOptions.fromJson(Map<String, dynamic> json) => _$AddressOptionsFromJson(json);
}

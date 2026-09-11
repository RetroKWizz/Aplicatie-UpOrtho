import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Datele contului, asa cum le arata si portalul de pe site.
///
/// `canEditVat` vine de la Odoo: dupa ce s-au emis documente contabile pe cont, codul
/// fiscal si tara nu mai pot fi schimbate. Ecranul dezactiveaza campurile in loc sa
/// lase clientul sa scrie si sa primeasca eroare la salvare.
@freezed
abstract class AccountProfile with _$AccountProfile {
  const factory AccountProfile({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? mobile,
    String? function,
    String? street,
    String? street2,
    String? city,
    String? zip,
    @JsonKey(name: 'state_id') int? stateId,
    String? state,
    @JsonKey(name: 'country_id') int? countryId,
    String? country,
    String? vat,
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'can_edit_vat') @Default(true) bool canEditVat,
  }) = _AccountProfile;

  factory AccountProfile.fromJson(Map<String, dynamic> json) => _$AccountProfileFromJson(json);
}

/// Profilul plus ce campuri cere si ce campuri lasa portalul sa fie modificate. Listele
/// vin de la server, deci includ automat si ce adauga modulele clientului.
@freezed
abstract class AccountProfileResponse with _$AccountProfileResponse {
  const factory AccountProfileResponse({
    required AccountProfile profile,
    @Default([]) List<String> required,
    @Default([]) List<String> editable,
  }) = _AccountProfileResponse;

  factory AccountProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountProfileResponseFromJson(json);
}

/// Un card de fidelitate: Ortho Club, card cadou sau voucher.
///
/// `pointsDisplay` e textul compus de Odoo — un program pe bani scrie "250,00 lei",
/// unul pe puncte scrie "150 puncte". Aplicatia nu formateaza niciodata bani.
@freezed
abstract class LoyaltyCard with _$LoyaltyCard {
  const factory LoyaltyCard({
    required int id,
    required String program,
    @JsonKey(name: 'program_type') String? programType,
    String? code,
    @Default(0) double points,
    @JsonKey(name: 'points_display') required String pointsDisplay,
    @JsonKey(name: 'expiration_date') String? expirationDate,
  }) = _LoyaltyCard;

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => _$LoyaltyCardFromJson(json);
}

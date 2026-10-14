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

/// Abonamentul Ortho Club al contului, asa cum il vede Odoo. Doar de citit: se
/// cumpara si se reinnoieste pe site, aplicatia nu-l poate schimba.
///
/// `member` e raspunsul serverului la intrebarea "e valabil AZI", nu bifa din Odoo:
/// bifa nu se stinge cand trece data. `endDateLabel` vine scris in cuvinte ("31
/// decembrie 2026"), ca si preturile - aplicatia nu formateaza.
@freezed
abstract class OrthoClub with _$OrthoClub {
  const factory OrthoClub({
    @Default(false) bool member,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'end_date_label') String? endDateLabel,
    String? pricelist,
  }) = _OrthoClub;

  factory OrthoClub.fromJson(Map<String, dynamic> json) => _$OrthoClubFromJson(json);
}

/// Profilul plus ce campuri cere si ce campuri lasa portalul sa fie modificate. Listele
/// vin de la server, deci includ automat si ce adauga modulele clientului.
///
/// `club` lipseste (`null`) pe o baza fara modulul de abonamente al clientului si pe
/// un cont care n-a avut niciodata abonament - ecranul nu arata atunci nimic.
@freezed
abstract class AccountProfileResponse with _$AccountProfileResponse {
  const factory AccountProfileResponse({
    required AccountProfile profile,
    OrthoClub? club,
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

/// Un card salvat al contului. Nicio informatie de card nu trece prin aplicatie:
/// `name` e textul compus de provider ("VISA **** 4242"), iar tokenul din spate ramane
/// la el. Cardurile se adauga platind si se sterg de pe site.
@freezed
abstract class PaymentMethodCard with _$PaymentMethodCard {
  const factory PaymentMethodCard({
    required int id,
    required String name,
    required String provider,
    @JsonKey(name: 'is_test') @Default(false) bool isTest,
  }) = _PaymentMethodCard;

  factory PaymentMethodCard.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodCardFromJson(json);
}

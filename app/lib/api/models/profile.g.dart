// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountProfile _$AccountProfileFromJson(Map<String, dynamic> json) =>
    _AccountProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      function: json['function'] as String?,
      street: json['street'] as String?,
      street2: json['street2'] as String?,
      city: json['city'] as String?,
      zip: json['zip'] as String?,
      stateId: (json['state_id'] as num?)?.toInt(),
      state: json['state'] as String?,
      countryId: (json['country_id'] as num?)?.toInt(),
      country: json['country'] as String?,
      vat: json['vat'] as String?,
      companyName: json['company_name'] as String?,
      canEditVat: json['can_edit_vat'] as bool? ?? true,
    );

Map<String, dynamic> _$AccountProfileToJson(_AccountProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'mobile': instance.mobile,
      'function': instance.function,
      'street': instance.street,
      'street2': instance.street2,
      'city': instance.city,
      'zip': instance.zip,
      'state_id': instance.stateId,
      'state': instance.state,
      'country_id': instance.countryId,
      'country': instance.country,
      'vat': instance.vat,
      'company_name': instance.companyName,
      'can_edit_vat': instance.canEditVat,
    };

_AccountProfileResponse _$AccountProfileResponseFromJson(
  Map<String, dynamic> json,
) => _AccountProfileResponse(
  profile: AccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
  required:
      (json['required'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  editable:
      (json['editable'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AccountProfileResponseToJson(
  _AccountProfileResponse instance,
) => <String, dynamic>{
  'profile': instance.profile,
  'required': instance.required,
  'editable': instance.editable,
};

_LoyaltyCard _$LoyaltyCardFromJson(Map<String, dynamic> json) => _LoyaltyCard(
  id: (json['id'] as num).toInt(),
  program: json['program'] as String,
  programType: json['program_type'] as String?,
  code: json['code'] as String?,
  points: (json['points'] as num?)?.toDouble() ?? 0,
  pointsDisplay: json['points_display'] as String,
  expirationDate: json['expiration_date'] as String?,
);

Map<String, dynamic> _$LoyaltyCardToJson(_LoyaltyCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'program': instance.program,
      'program_type': instance.programType,
      'code': instance.code,
      'points': instance.points,
      'points_display': instance.pointsDisplay,
      'expiration_date': instance.expirationDate,
    };

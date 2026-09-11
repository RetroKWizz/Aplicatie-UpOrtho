// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddressCountry _$AddressCountryFromJson(Map<String, dynamic> json) =>
    _AddressCountry(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String?,
      stateRequired: json['state_required'] as bool? ?? false,
      zipRequired: json['zip_required'] as bool? ?? false,
    );

Map<String, dynamic> _$AddressCountryToJson(_AddressCountry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'state_required': instance.stateRequired,
      'zip_required': instance.zipRequired,
    };

_AddressState _$AddressStateFromJson(Map<String, dynamic> json) =>
    _AddressState(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$AddressStateToJson(_AddressState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
    };

_AddressCity _$AddressCityFromJson(Map<String, dynamic> json) => _AddressCity(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  zip: json['zip'] as String?,
);

Map<String, dynamic> _$AddressCityToJson(_AddressCity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'zip': instance.zip,
    };

_AddressRequired _$AddressRequiredFromJson(
  Map<String, dynamic> json,
) => _AddressRequired(
  delivery:
      (json['delivery'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  invoice:
      (json['invoice'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AddressRequiredToJson(_AddressRequired instance) =>
    <String, dynamic>{
      'delivery': instance.delivery,
      'invoice': instance.invoice,
    };

_AddressOptions _$AddressOptionsFromJson(Map<String, dynamic> json) =>
    _AddressOptions(
      countries:
          (json['countries'] as List<dynamic>?)
              ?.map((e) => AddressCountry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      defaultCountryId: (json['default_country_id'] as num?)?.toInt(),
      states:
          (json['states'] as List<dynamic>?)
              ?.map((e) => AddressState.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cities:
          (json['cities'] as List<dynamic>?)
              ?.map((e) => AddressCity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      required: AddressRequired.fromJson(
        json['required'] as Map<String, dynamic>,
      ),
      cityIsList: json['city_is_list'] as bool? ?? false,
    );

Map<String, dynamic> _$AddressOptionsToJson(_AddressOptions instance) =>
    <String, dynamic>{
      'countries': instance.countries,
      'default_country_id': instance.defaultCountryId,
      'states': instance.states,
      'cities': instance.cities,
      'required': instance.required,
      'city_is_list': instance.cityIsList,
    };

_AddressFormValues _$AddressFormValuesFromJson(Map<String, dynamic> json) =>
    _AddressFormValues(
      id: (json['id'] as num).toInt(),
      kind: json['kind'] as String,
      name: json['name'] as String?,
      street: json['street'] as String?,
      street2: json['street2'] as String?,
      city: json['city'] as String?,
      cityId: (json['city_id'] as num?)?.toInt(),
      zip: json['zip'] as String?,
      stateId: (json['state_id'] as num?)?.toInt(),
      countryId: (json['country_id'] as num?)?.toInt(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      vat: json['vat'] as String?,
      companyName: json['company_name'] as String?,
      canEditName: json['can_edit_name'] as bool? ?? true,
      canEditVat: json['can_edit_vat'] as bool? ?? true,
    );

Map<String, dynamic> _$AddressFormValuesToJson(_AddressFormValues instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'name': instance.name,
      'street': instance.street,
      'street2': instance.street2,
      'city': instance.city,
      'city_id': instance.cityId,
      'zip': instance.zip,
      'state_id': instance.stateId,
      'country_id': instance.countryId,
      'phone': instance.phone,
      'email': instance.email,
      'vat': instance.vat,
      'company_name': instance.companyName,
      'can_edit_name': instance.canEditName,
      'can_edit_vat': instance.canEditVat,
    };

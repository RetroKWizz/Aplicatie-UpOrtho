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

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountProfile {

 int get id; String get name; String? get email; String? get phone; String? get mobile; String? get function; String? get street; String? get street2; String? get city; String? get zip;@JsonKey(name: 'state_id') int? get stateId; String? get state;@JsonKey(name: 'country_id') int? get countryId; String? get country; String? get vat;@JsonKey(name: 'company_name') String? get companyName;@JsonKey(name: 'can_edit_vat') bool get canEditVat;
/// Create a copy of AccountProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountProfileCopyWith<AccountProfile> get copyWith => _$AccountProfileCopyWithImpl<AccountProfile>(this as AccountProfile, _$identity);

  /// Serializes this AccountProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.mobile, _this.mobile) || other.mobile == _this.mobile)&&(identical(other.function, _this.function) || other.function == _this.function)&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.street2, _this.street2) || other.street2 == _this.street2)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.zip, _this.zip) || other.zip == _this.zip)&&(identical(other.stateId, _this.stateId) || other.stateId == _this.stateId)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.countryId, _this.countryId) || other.countryId == _this.countryId)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.vat, _this.vat) || other.vat == _this.vat)&&(identical(other.companyName, _this.companyName) || other.companyName == _this.companyName)&&(identical(other.canEditVat, _this.canEditVat) || other.canEditVat == _this.canEditVat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountProfile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.mobile,_this.function,_this.street,_this.street2,_this.city,_this.zip,_this.stateId,_this.state,_this.countryId,_this.country,_this.vat,_this.companyName,_this.canEditVat);
}

@override
String toString() {
  final _this = this as AccountProfile;
  return 'AccountProfile(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, mobile: ${_this.mobile}, function: ${_this.function}, street: ${_this.street}, street2: ${_this.street2}, city: ${_this.city}, zip: ${_this.zip}, stateId: ${_this.stateId}, state: ${_this.state}, countryId: ${_this.countryId}, country: ${_this.country}, vat: ${_this.vat}, companyName: ${_this.companyName}, canEditVat: ${_this.canEditVat})';
}


}

/// @nodoc
abstract mixin class $AccountProfileCopyWith<$Res>  {
  factory $AccountProfileCopyWith(AccountProfile value, $Res Function(AccountProfile) _then) = _$AccountProfileCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? email, String? phone, String? mobile, String? function, String? street, String? street2, String? city, String? zip,@JsonKey(name: 'state_id') int? stateId, String? state,@JsonKey(name: 'country_id') int? countryId, String? country, String? vat,@JsonKey(name: 'company_name') String? companyName,@JsonKey(name: 'can_edit_vat') bool canEditVat
});




}
/// @nodoc
class _$AccountProfileCopyWithImpl<$Res>
    implements $AccountProfileCopyWith<$Res> {
  _$AccountProfileCopyWithImpl(this._self, this._then);

  final AccountProfile _self;
  final $Res Function(AccountProfile) _then;

/// Create a copy of AccountProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? mobile = freezed,Object? function = freezed,Object? street = freezed,Object? street2 = freezed,Object? city = freezed,Object? zip = freezed,Object? stateId = freezed,Object? state = freezed,Object? countryId = freezed,Object? country = freezed,Object? vat = freezed,Object? companyName = freezed,Object? canEditVat = null,}) {
  return _then(AccountProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,function: freezed == function ? _self.function : function // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,street2: freezed == street2 ? _self.street2 : street2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as int?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as int?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,canEditVat: null == canEditVat ? _self.canEditVat : canEditVat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountProfile].
extension AccountProfilePatterns on AccountProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountProfile value)  $default,){
final _that = this;
switch (_that) {
case _AccountProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountProfile value)?  $default,){
final _that = this;
switch (_that) {
case _AccountProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  String? phone,  String? mobile,  String? function,  String? street,  String? street2,  String? city,  String? zip, @JsonKey(name: 'state_id')  int? stateId,  String? state, @JsonKey(name: 'country_id')  int? countryId,  String? country,  String? vat, @JsonKey(name: 'company_name')  String? companyName, @JsonKey(name: 'can_edit_vat')  bool canEditVat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.mobile,_that.function,_that.street,_that.street2,_that.city,_that.zip,_that.stateId,_that.state,_that.countryId,_that.country,_that.vat,_that.companyName,_that.canEditVat);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  String? phone,  String? mobile,  String? function,  String? street,  String? street2,  String? city,  String? zip, @JsonKey(name: 'state_id')  int? stateId,  String? state, @JsonKey(name: 'country_id')  int? countryId,  String? country,  String? vat, @JsonKey(name: 'company_name')  String? companyName, @JsonKey(name: 'can_edit_vat')  bool canEditVat)  $default,) {final _that = this;
switch (_that) {
case _AccountProfile():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.mobile,_that.function,_that.street,_that.street2,_that.city,_that.zip,_that.stateId,_that.state,_that.countryId,_that.country,_that.vat,_that.companyName,_that.canEditVat);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? email,  String? phone,  String? mobile,  String? function,  String? street,  String? street2,  String? city,  String? zip, @JsonKey(name: 'state_id')  int? stateId,  String? state, @JsonKey(name: 'country_id')  int? countryId,  String? country,  String? vat, @JsonKey(name: 'company_name')  String? companyName, @JsonKey(name: 'can_edit_vat')  bool canEditVat)?  $default,) {final _that = this;
switch (_that) {
case _AccountProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.mobile,_that.function,_that.street,_that.street2,_that.city,_that.zip,_that.stateId,_that.state,_that.countryId,_that.country,_that.vat,_that.companyName,_that.canEditVat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountProfile implements AccountProfile {
  const _AccountProfile({required this.id, required this.name, this.email, this.phone, this.mobile, this.function, this.street, this.street2, this.city, this.zip, @JsonKey(name: 'state_id') this.stateId, this.state, @JsonKey(name: 'country_id') this.countryId, this.country, this.vat, @JsonKey(name: 'company_name') this.companyName, @JsonKey(name: 'can_edit_vat') this.canEditVat = true});
  factory _AccountProfile.fromJson(Map<String, dynamic> json) => _$AccountProfileFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  String? mobile;
@override final  String? function;
@override final  String? street;
@override final  String? street2;
@override final  String? city;
@override final  String? zip;
@override@JsonKey(name: 'state_id') final  int? stateId;
@override final  String? state;
@override@JsonKey(name: 'country_id') final  int? countryId;
@override final  String? country;
@override final  String? vat;
@override@JsonKey(name: 'company_name') final  String? companyName;
@override@JsonKey(name: 'can_edit_vat') final  bool canEditVat;

/// Create a copy of AccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountProfileCopyWith<_AccountProfile> get copyWith => __$AccountProfileCopyWithImpl<_AccountProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.function, function) || other.function == function)&&(identical(other.street, street) || other.street == street)&&(identical(other.street2, street2) || other.street2 == street2)&&(identical(other.city, city) || other.city == city)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.stateId, stateId) || other.stateId == stateId)&&(identical(other.state, state) || other.state == state)&&(identical(other.countryId, countryId) || other.countryId == countryId)&&(identical(other.country, country) || other.country == country)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.canEditVat, canEditVat) || other.canEditVat == canEditVat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,mobile,function,street,street2,city,zip,stateId,state,countryId,country,vat,companyName,canEditVat);
}

@override
String toString() {
    return 'AccountProfile(id: $id, name: $name, email: $email, phone: $phone, mobile: $mobile, function: $function, street: $street, street2: $street2, city: $city, zip: $zip, stateId: $stateId, state: $state, countryId: $countryId, country: $country, vat: $vat, companyName: $companyName, canEditVat: $canEditVat)';
}


}

/// @nodoc
abstract mixin class _$AccountProfileCopyWith<$Res> implements $AccountProfileCopyWith<$Res> {
  factory _$AccountProfileCopyWith(_AccountProfile value, $Res Function(_AccountProfile) _then) = __$AccountProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? email, String? phone, String? mobile, String? function, String? street, String? street2, String? city, String? zip,@JsonKey(name: 'state_id') int? stateId, String? state,@JsonKey(name: 'country_id') int? countryId, String? country, String? vat,@JsonKey(name: 'company_name') String? companyName,@JsonKey(name: 'can_edit_vat') bool canEditVat
});




}
/// @nodoc
class __$AccountProfileCopyWithImpl<$Res>
    implements _$AccountProfileCopyWith<$Res> {
  __$AccountProfileCopyWithImpl(this._self, this._then);

  final _AccountProfile _self;
  final $Res Function(_AccountProfile) _then;

/// Create a copy of AccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? mobile = freezed,Object? function = freezed,Object? street = freezed,Object? street2 = freezed,Object? city = freezed,Object? zip = freezed,Object? stateId = freezed,Object? state = freezed,Object? countryId = freezed,Object? country = freezed,Object? vat = freezed,Object? companyName = freezed,Object? canEditVat = null,}) {
  return _then(_AccountProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,function: freezed == function ? _self.function : function // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,street2: freezed == street2 ? _self.street2 : street2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as int?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as int?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,canEditVat: null == canEditVat ? _self.canEditVat : canEditVat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AccountProfileResponse {

 AccountProfile get profile; List<String> get required; List<String> get editable;
/// Create a copy of AccountProfileResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountProfileResponseCopyWith<AccountProfileResponse> get copyWith => _$AccountProfileResponseCopyWithImpl<AccountProfileResponse>(this as AccountProfileResponse, _$identity);

  /// Serializes this AccountProfileResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountProfileResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountProfileResponse&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.required, _this.required)&&const DeepCollectionEquality().equals(other.editable, _this.editable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountProfileResponse;
  return Object.hash(runtimeType,_this.profile,const DeepCollectionEquality().hash(_this.required),const DeepCollectionEquality().hash(_this.editable));
}

@override
String toString() {
  final _this = this as AccountProfileResponse;
  return 'AccountProfileResponse(profile: ${_this.profile}, required: ${_this.required}, editable: ${_this.editable})';
}


}

/// @nodoc
abstract mixin class $AccountProfileResponseCopyWith<$Res>  {
  factory $AccountProfileResponseCopyWith(AccountProfileResponse value, $Res Function(AccountProfileResponse) _then) = _$AccountProfileResponseCopyWithImpl;
@useResult
$Res call({
 AccountProfile profile, List<String> required, List<String> editable
});


$AccountProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$AccountProfileResponseCopyWithImpl<$Res>
    implements $AccountProfileResponseCopyWith<$Res> {
  _$AccountProfileResponseCopyWithImpl(this._self, this._then);

  final AccountProfileResponse _self;
  final $Res Function(AccountProfileResponse) _then;

/// Create a copy of AccountProfileResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? required = null,Object? editable = null,}) {
  return _then(AccountProfileResponse(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as AccountProfile,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as List<String>,editable: null == editable ? _self.editable : editable // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of AccountProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountProfileCopyWith<$Res> get profile {
  
  return $AccountProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountProfileResponse].
extension AccountProfileResponsePatterns on AccountProfileResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountProfileResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountProfileResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountProfileResponse value)  $default,){
final _that = this;
switch (_that) {
case _AccountProfileResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountProfileResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AccountProfileResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountProfile profile,  List<String> required,  List<String> editable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountProfileResponse() when $default != null:
return $default(_that.profile,_that.required,_that.editable);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountProfile profile,  List<String> required,  List<String> editable)  $default,) {final _that = this;
switch (_that) {
case _AccountProfileResponse():
return $default(_that.profile,_that.required,_that.editable);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountProfile profile,  List<String> required,  List<String> editable)?  $default,) {final _that = this;
switch (_that) {
case _AccountProfileResponse() when $default != null:
return $default(_that.profile,_that.required,_that.editable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountProfileResponse implements AccountProfileResponse {
  const _AccountProfileResponse({required this.profile,  List<String> required = const [],  List<String> editable = const []}): _required = required,_editable = editable;
  factory _AccountProfileResponse.fromJson(Map<String, dynamic> json) => _$AccountProfileResponseFromJson(json);

@override final  AccountProfile profile;
 final  List<String> _required;
@override@JsonKey() List<String> get required {
  if (_required is EqualUnmodifiableListView) return _required;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_required);
}

 final  List<String> _editable;
@override@JsonKey() List<String> get editable {
  if (_editable is EqualUnmodifiableListView) return _editable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_editable);
}


/// Create a copy of AccountProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountProfileResponseCopyWith<_AccountProfileResponse> get copyWith => __$AccountProfileResponseCopyWithImpl<_AccountProfileResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountProfileResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountProfileResponse&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.required, _required)&&const DeepCollectionEquality().equals(other.editable, _editable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(_required),const DeepCollectionEquality().hash(_editable));
}

@override
String toString() {
    return 'AccountProfileResponse(profile: $profile, required: $required, editable: $editable)';
}


}

/// @nodoc
abstract mixin class _$AccountProfileResponseCopyWith<$Res> implements $AccountProfileResponseCopyWith<$Res> {
  factory _$AccountProfileResponseCopyWith(_AccountProfileResponse value, $Res Function(_AccountProfileResponse) _then) = __$AccountProfileResponseCopyWithImpl;
@override @useResult
$Res call({
 AccountProfile profile, List<String> required, List<String> editable
});


@override $AccountProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$AccountProfileResponseCopyWithImpl<$Res>
    implements _$AccountProfileResponseCopyWith<$Res> {
  __$AccountProfileResponseCopyWithImpl(this._self, this._then);

  final _AccountProfileResponse _self;
  final $Res Function(_AccountProfileResponse) _then;

/// Create a copy of AccountProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? required = null,Object? editable = null,}) {
  return _then(_AccountProfileResponse(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as AccountProfile,required: null == required ? _self._required : required // ignore: cast_nullable_to_non_nullable
as List<String>,editable: null == editable ? _self._editable : editable // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of AccountProfileResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountProfileCopyWith<$Res> get profile {
  
  return $AccountProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$LoyaltyCard {

 int get id; String get program;@JsonKey(name: 'program_type') String? get programType; String? get code; double get points;@JsonKey(name: 'points_display') String get pointsDisplay;@JsonKey(name: 'expiration_date') String? get expirationDate;
/// Create a copy of LoyaltyCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoyaltyCardCopyWith<LoyaltyCard> get copyWith => _$LoyaltyCardCopyWithImpl<LoyaltyCard>(this as LoyaltyCard, _$identity);

  /// Serializes this LoyaltyCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoyaltyCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoyaltyCard&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.program, _this.program) || other.program == _this.program)&&(identical(other.programType, _this.programType) || other.programType == _this.programType)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.pointsDisplay, _this.pointsDisplay) || other.pointsDisplay == _this.pointsDisplay)&&(identical(other.expirationDate, _this.expirationDate) || other.expirationDate == _this.expirationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoyaltyCard;
  return Object.hash(runtimeType,_this.id,_this.program,_this.programType,_this.code,_this.points,_this.pointsDisplay,_this.expirationDate);
}

@override
String toString() {
  final _this = this as LoyaltyCard;
  return 'LoyaltyCard(id: ${_this.id}, program: ${_this.program}, programType: ${_this.programType}, code: ${_this.code}, points: ${_this.points}, pointsDisplay: ${_this.pointsDisplay}, expirationDate: ${_this.expirationDate})';
}


}

/// @nodoc
abstract mixin class $LoyaltyCardCopyWith<$Res>  {
  factory $LoyaltyCardCopyWith(LoyaltyCard value, $Res Function(LoyaltyCard) _then) = _$LoyaltyCardCopyWithImpl;
@useResult
$Res call({
 int id, String program,@JsonKey(name: 'program_type') String? programType, String? code, double points,@JsonKey(name: 'points_display') String pointsDisplay,@JsonKey(name: 'expiration_date') String? expirationDate
});




}
/// @nodoc
class _$LoyaltyCardCopyWithImpl<$Res>
    implements $LoyaltyCardCopyWith<$Res> {
  _$LoyaltyCardCopyWithImpl(this._self, this._then);

  final LoyaltyCard _self;
  final $Res Function(LoyaltyCard) _then;

/// Create a copy of LoyaltyCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? program = null,Object? programType = freezed,Object? code = freezed,Object? points = null,Object? pointsDisplay = null,Object? expirationDate = freezed,}) {
  return _then(LoyaltyCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,program: null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,programType: freezed == programType ? _self.programType : programType // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,pointsDisplay: null == pointsDisplay ? _self.pointsDisplay : pointsDisplay // ignore: cast_nullable_to_non_nullable
as String,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoyaltyCard].
extension LoyaltyCardPatterns on LoyaltyCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoyaltyCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoyaltyCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoyaltyCard value)  $default,){
final _that = this;
switch (_that) {
case _LoyaltyCard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoyaltyCard value)?  $default,){
final _that = this;
switch (_that) {
case _LoyaltyCard() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String program, @JsonKey(name: 'program_type')  String? programType,  String? code,  double points, @JsonKey(name: 'points_display')  String pointsDisplay, @JsonKey(name: 'expiration_date')  String? expirationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoyaltyCard() when $default != null:
return $default(_that.id,_that.program,_that.programType,_that.code,_that.points,_that.pointsDisplay,_that.expirationDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String program, @JsonKey(name: 'program_type')  String? programType,  String? code,  double points, @JsonKey(name: 'points_display')  String pointsDisplay, @JsonKey(name: 'expiration_date')  String? expirationDate)  $default,) {final _that = this;
switch (_that) {
case _LoyaltyCard():
return $default(_that.id,_that.program,_that.programType,_that.code,_that.points,_that.pointsDisplay,_that.expirationDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String program, @JsonKey(name: 'program_type')  String? programType,  String? code,  double points, @JsonKey(name: 'points_display')  String pointsDisplay, @JsonKey(name: 'expiration_date')  String? expirationDate)?  $default,) {final _that = this;
switch (_that) {
case _LoyaltyCard() when $default != null:
return $default(_that.id,_that.program,_that.programType,_that.code,_that.points,_that.pointsDisplay,_that.expirationDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoyaltyCard implements LoyaltyCard {
  const _LoyaltyCard({required this.id, required this.program, @JsonKey(name: 'program_type') this.programType, this.code, this.points = 0, @JsonKey(name: 'points_display') required this.pointsDisplay, @JsonKey(name: 'expiration_date') this.expirationDate});
  factory _LoyaltyCard.fromJson(Map<String, dynamic> json) => _$LoyaltyCardFromJson(json);

@override final  int id;
@override final  String program;
@override@JsonKey(name: 'program_type') final  String? programType;
@override final  String? code;
@override@JsonKey() final  double points;
@override@JsonKey(name: 'points_display') final  String pointsDisplay;
@override@JsonKey(name: 'expiration_date') final  String? expirationDate;

/// Create a copy of LoyaltyCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoyaltyCardCopyWith<_LoyaltyCard> get copyWith => __$LoyaltyCardCopyWithImpl<_LoyaltyCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoyaltyCardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoyaltyCard&&(identical(other.id, id) || other.id == id)&&(identical(other.program, program) || other.program == program)&&(identical(other.programType, programType) || other.programType == programType)&&(identical(other.code, code) || other.code == code)&&(identical(other.points, points) || other.points == points)&&(identical(other.pointsDisplay, pointsDisplay) || other.pointsDisplay == pointsDisplay)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,program,programType,code,points,pointsDisplay,expirationDate);
}

@override
String toString() {
    return 'LoyaltyCard(id: $id, program: $program, programType: $programType, code: $code, points: $points, pointsDisplay: $pointsDisplay, expirationDate: $expirationDate)';
}


}

/// @nodoc
abstract mixin class _$LoyaltyCardCopyWith<$Res> implements $LoyaltyCardCopyWith<$Res> {
  factory _$LoyaltyCardCopyWith(_LoyaltyCard value, $Res Function(_LoyaltyCard) _then) = __$LoyaltyCardCopyWithImpl;
@override @useResult
$Res call({
 int id, String program,@JsonKey(name: 'program_type') String? programType, String? code, double points,@JsonKey(name: 'points_display') String pointsDisplay,@JsonKey(name: 'expiration_date') String? expirationDate
});




}
/// @nodoc
class __$LoyaltyCardCopyWithImpl<$Res>
    implements _$LoyaltyCardCopyWith<$Res> {
  __$LoyaltyCardCopyWithImpl(this._self, this._then);

  final _LoyaltyCard _self;
  final $Res Function(_LoyaltyCard) _then;

/// Create a copy of LoyaltyCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? program = null,Object? programType = freezed,Object? code = freezed,Object? points = null,Object? pointsDisplay = null,Object? expirationDate = freezed,}) {
  return _then(_LoyaltyCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,program: null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,programType: freezed == programType ? _self.programType : programType // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,pointsDisplay: null == pointsDisplay ? _self.pointsDisplay : pointsDisplay // ignore: cast_nullable_to_non_nullable
as String,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

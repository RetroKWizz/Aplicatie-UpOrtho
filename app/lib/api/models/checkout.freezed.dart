// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Address {

 int get id; String get name; String? get street; String? get street2; String? get city; String? get zip; String? get state; String? get country; String? get phone; String? get email; String? get vat; String? get type;/// In care din cele doua liste ale magazinului intra adresa. O adresa poate fi
/// in amandoua (partenerul principal al contului, sau un contact de tip "altul").
@JsonKey(name: 'for_billing') bool get forBilling;@JsonKey(name: 'for_delivery') bool get forDelivery;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Address;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.street2, _this.street2) || other.street2 == _this.street2)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.zip, _this.zip) || other.zip == _this.zip)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.vat, _this.vat) || other.vat == _this.vat)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.forBilling, _this.forBilling) || other.forBilling == _this.forBilling)&&(identical(other.forDelivery, _this.forDelivery) || other.forDelivery == _this.forDelivery));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Address;
  return Object.hash(runtimeType,_this.id,_this.name,_this.street,_this.street2,_this.city,_this.zip,_this.state,_this.country,_this.phone,_this.email,_this.vat,_this.type,_this.forBilling,_this.forDelivery);
}

@override
String toString() {
  final _this = this as Address;
  return 'Address(id: ${_this.id}, name: ${_this.name}, street: ${_this.street}, street2: ${_this.street2}, city: ${_this.city}, zip: ${_this.zip}, state: ${_this.state}, country: ${_this.country}, phone: ${_this.phone}, email: ${_this.email}, vat: ${_this.vat}, type: ${_this.type}, forBilling: ${_this.forBilling}, forDelivery: ${_this.forDelivery})';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? street, String? street2, String? city, String? zip, String? state, String? country, String? phone, String? email, String? vat, String? type,@JsonKey(name: 'for_billing') bool forBilling,@JsonKey(name: 'for_delivery') bool forDelivery
});




}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? street = freezed,Object? street2 = freezed,Object? city = freezed,Object? zip = freezed,Object? state = freezed,Object? country = freezed,Object? phone = freezed,Object? email = freezed,Object? vat = freezed,Object? type = freezed,Object? forBilling = null,Object? forDelivery = null,}) {
  return _then(Address(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,street2: freezed == street2 ? _self.street2 : street2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,forBilling: null == forBilling ? _self.forBilling : forBilling // ignore: cast_nullable_to_non_nullable
as bool,forDelivery: null == forDelivery ? _self.forDelivery : forDelivery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? street,  String? street2,  String? city,  String? zip,  String? state,  String? country,  String? phone,  String? email,  String? vat,  String? type, @JsonKey(name: 'for_billing')  bool forBilling, @JsonKey(name: 'for_delivery')  bool forDelivery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.name,_that.street,_that.street2,_that.city,_that.zip,_that.state,_that.country,_that.phone,_that.email,_that.vat,_that.type,_that.forBilling,_that.forDelivery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? street,  String? street2,  String? city,  String? zip,  String? state,  String? country,  String? phone,  String? email,  String? vat,  String? type, @JsonKey(name: 'for_billing')  bool forBilling, @JsonKey(name: 'for_delivery')  bool forDelivery)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.id,_that.name,_that.street,_that.street2,_that.city,_that.zip,_that.state,_that.country,_that.phone,_that.email,_that.vat,_that.type,_that.forBilling,_that.forDelivery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? street,  String? street2,  String? city,  String? zip,  String? state,  String? country,  String? phone,  String? email,  String? vat,  String? type, @JsonKey(name: 'for_billing')  bool forBilling, @JsonKey(name: 'for_delivery')  bool forDelivery)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.name,_that.street,_that.street2,_that.city,_that.zip,_that.state,_that.country,_that.phone,_that.email,_that.vat,_that.type,_that.forBilling,_that.forDelivery);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Address extends Address {
  const _Address({required this.id, required this.name, this.street, this.street2, this.city, this.zip, this.state, this.country, this.phone, this.email, this.vat, this.type, @JsonKey(name: 'for_billing') this.forBilling = true, @JsonKey(name: 'for_delivery') this.forDelivery = true}): super._();
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? street;
@override final  String? street2;
@override final  String? city;
@override final  String? zip;
@override final  String? state;
@override final  String? country;
@override final  String? phone;
@override final  String? email;
@override final  String? vat;
@override final  String? type;
/// In care din cele doua liste ale magazinului intra adresa. O adresa poate fi
/// in amandoua (partenerul principal al contului, sau un contact de tip "altul").
@override@JsonKey(name: 'for_billing') final  bool forBilling;
@override@JsonKey(name: 'for_delivery') final  bool forDelivery;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.street, street) || other.street == street)&&(identical(other.street2, street2) || other.street2 == street2)&&(identical(other.city, city) || other.city == city)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.type, type) || other.type == type)&&(identical(other.forBilling, forBilling) || other.forBilling == forBilling)&&(identical(other.forDelivery, forDelivery) || other.forDelivery == forDelivery));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,street,street2,city,zip,state,country,phone,email,vat,type,forBilling,forDelivery);
}

@override
String toString() {
    return 'Address(id: $id, name: $name, street: $street, street2: $street2, city: $city, zip: $zip, state: $state, country: $country, phone: $phone, email: $email, vat: $vat, type: $type, forBilling: $forBilling, forDelivery: $forDelivery)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? street, String? street2, String? city, String? zip, String? state, String? country, String? phone, String? email, String? vat, String? type,@JsonKey(name: 'for_billing') bool forBilling,@JsonKey(name: 'for_delivery') bool forDelivery
});




}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? street = freezed,Object? street2 = freezed,Object? city = freezed,Object? zip = freezed,Object? state = freezed,Object? country = freezed,Object? phone = freezed,Object? email = freezed,Object? vat = freezed,Object? type = freezed,Object? forBilling = null,Object? forDelivery = null,}) {
  return _then(_Address(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,street2: freezed == street2 ? _self.street2 : street2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,forBilling: null == forBilling ? _self.forBilling : forBilling // ignore: cast_nullable_to_non_nullable
as bool,forDelivery: null == forDelivery ? _self.forDelivery : forDelivery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CheckoutAddresses {

@JsonKey(name: 'delivery_id') int? get deliveryId;@JsonKey(name: 'invoice_id') int? get invoiceId; List<Address> get available;
/// Create a copy of CheckoutAddresses
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutAddressesCopyWith<CheckoutAddresses> get copyWith => _$CheckoutAddressesCopyWithImpl<CheckoutAddresses>(this as CheckoutAddresses, _$identity);

  /// Serializes this CheckoutAddresses to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutAddresses;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutAddresses&&(identical(other.deliveryId, _this.deliveryId) || other.deliveryId == _this.deliveryId)&&(identical(other.invoiceId, _this.invoiceId) || other.invoiceId == _this.invoiceId)&&const DeepCollectionEquality().equals(other.available, _this.available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutAddresses;
  return Object.hash(runtimeType,_this.deliveryId,_this.invoiceId,const DeepCollectionEquality().hash(_this.available));
}

@override
String toString() {
  final _this = this as CheckoutAddresses;
  return 'CheckoutAddresses(deliveryId: ${_this.deliveryId}, invoiceId: ${_this.invoiceId}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $CheckoutAddressesCopyWith<$Res>  {
  factory $CheckoutAddressesCopyWith(CheckoutAddresses value, $Res Function(CheckoutAddresses) _then) = _$CheckoutAddressesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'delivery_id') int? deliveryId,@JsonKey(name: 'invoice_id') int? invoiceId, List<Address> available
});




}
/// @nodoc
class _$CheckoutAddressesCopyWithImpl<$Res>
    implements $CheckoutAddressesCopyWith<$Res> {
  _$CheckoutAddressesCopyWithImpl(this._self, this._then);

  final CheckoutAddresses _self;
  final $Res Function(CheckoutAddresses) _then;

/// Create a copy of CheckoutAddresses
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deliveryId = freezed,Object? invoiceId = freezed,Object? available = null,}) {
  return _then(CheckoutAddresses(
deliveryId: freezed == deliveryId ? _self.deliveryId : deliveryId // ignore: cast_nullable_to_non_nullable
as int?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as int?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as List<Address>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutAddresses].
extension CheckoutAddressesPatterns on CheckoutAddresses {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutAddresses value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutAddresses() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutAddresses value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutAddresses():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutAddresses value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutAddresses() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'delivery_id')  int? deliveryId, @JsonKey(name: 'invoice_id')  int? invoiceId,  List<Address> available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutAddresses() when $default != null:
return $default(_that.deliveryId,_that.invoiceId,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'delivery_id')  int? deliveryId, @JsonKey(name: 'invoice_id')  int? invoiceId,  List<Address> available)  $default,) {final _that = this;
switch (_that) {
case _CheckoutAddresses():
return $default(_that.deliveryId,_that.invoiceId,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'delivery_id')  int? deliveryId, @JsonKey(name: 'invoice_id')  int? invoiceId,  List<Address> available)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutAddresses() when $default != null:
return $default(_that.deliveryId,_that.invoiceId,_that.available);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutAddresses implements CheckoutAddresses {
  const _CheckoutAddresses({@JsonKey(name: 'delivery_id') this.deliveryId, @JsonKey(name: 'invoice_id') this.invoiceId,  List<Address> available = const []}): _available = available;
  factory _CheckoutAddresses.fromJson(Map<String, dynamic> json) => _$CheckoutAddressesFromJson(json);

@override@JsonKey(name: 'delivery_id') final  int? deliveryId;
@override@JsonKey(name: 'invoice_id') final  int? invoiceId;
 final  List<Address> _available;
@override@JsonKey() List<Address> get available {
  if (_available is EqualUnmodifiableListView) return _available;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_available);
}


/// Create a copy of CheckoutAddresses
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutAddressesCopyWith<_CheckoutAddresses> get copyWith => __$CheckoutAddressesCopyWithImpl<_CheckoutAddresses>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutAddressesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutAddresses&&(identical(other.deliveryId, deliveryId) || other.deliveryId == deliveryId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&const DeepCollectionEquality().equals(other.available, _available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,deliveryId,invoiceId,const DeepCollectionEquality().hash(_available));
}

@override
String toString() {
    return 'CheckoutAddresses(deliveryId: $deliveryId, invoiceId: $invoiceId, available: $available)';
}


}

/// @nodoc
abstract mixin class _$CheckoutAddressesCopyWith<$Res> implements $CheckoutAddressesCopyWith<$Res> {
  factory _$CheckoutAddressesCopyWith(_CheckoutAddresses value, $Res Function(_CheckoutAddresses) _then) = __$CheckoutAddressesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'delivery_id') int? deliveryId,@JsonKey(name: 'invoice_id') int? invoiceId, List<Address> available
});




}
/// @nodoc
class __$CheckoutAddressesCopyWithImpl<$Res>
    implements _$CheckoutAddressesCopyWith<$Res> {
  __$CheckoutAddressesCopyWithImpl(this._self, this._then);

  final _CheckoutAddresses _self;
  final $Res Function(_CheckoutAddresses) _then;

/// Create a copy of CheckoutAddresses
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deliveryId = freezed,Object? invoiceId = freezed,Object? available = null,}) {
  return _then(_CheckoutAddresses(
deliveryId: freezed == deliveryId ? _self.deliveryId : deliveryId // ignore: cast_nullable_to_non_nullable
as int?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as int?,available: null == available ? _self._available : available // ignore: cast_nullable_to_non_nullable
as List<Address>,
  ));
}


}


/// @nodoc
mixin _$DeliveryMethod {

 int get id; String get name; String? get description; Price get price; bool get free; bool get available; String? get error;@JsonKey(name: 'logo_url') String? get logoUrl;
/// Create a copy of DeliveryMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryMethodCopyWith<DeliveryMethod> get copyWith => _$DeliveryMethodCopyWithImpl<DeliveryMethod>(this as DeliveryMethod, _$identity);

  /// Serializes this DeliveryMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeliveryMethod;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryMethod&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.free, _this.free) || other.free == _this.free)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.logoUrl, _this.logoUrl) || other.logoUrl == _this.logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeliveryMethod;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.price,_this.free,_this.available,_this.error,_this.logoUrl);
}

@override
String toString() {
  final _this = this as DeliveryMethod;
  return 'DeliveryMethod(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, price: ${_this.price}, free: ${_this.free}, available: ${_this.available}, error: ${_this.error}, logoUrl: ${_this.logoUrl})';
}


}

/// @nodoc
abstract mixin class $DeliveryMethodCopyWith<$Res>  {
  factory $DeliveryMethodCopyWith(DeliveryMethod value, $Res Function(DeliveryMethod) _then) = _$DeliveryMethodCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? description, Price price, bool free, bool available, String? error,@JsonKey(name: 'logo_url') String? logoUrl
});


$PriceCopyWith<$Res> get price;

}
/// @nodoc
class _$DeliveryMethodCopyWithImpl<$Res>
    implements $DeliveryMethodCopyWith<$Res> {
  _$DeliveryMethodCopyWithImpl(this._self, this._then);

  final DeliveryMethod _self;
  final $Res Function(DeliveryMethod) _then;

/// Create a copy of DeliveryMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? free = null,Object? available = null,Object? error = freezed,Object? logoUrl = freezed,}) {
  return _then(DeliveryMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,free: null == free ? _self.free : free // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DeliveryMethod
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeliveryMethod].
extension DeliveryMethodPatterns on DeliveryMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryMethod value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryMethod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryMethod value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  Price price,  bool free,  bool available,  String? error, @JsonKey(name: 'logo_url')  String? logoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryMethod() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.free,_that.available,_that.error,_that.logoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  Price price,  bool free,  bool available,  String? error, @JsonKey(name: 'logo_url')  String? logoUrl)  $default,) {final _that = this;
switch (_that) {
case _DeliveryMethod():
return $default(_that.id,_that.name,_that.description,_that.price,_that.free,_that.available,_that.error,_that.logoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? description,  Price price,  bool free,  bool available,  String? error, @JsonKey(name: 'logo_url')  String? logoUrl)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryMethod() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.free,_that.available,_that.error,_that.logoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryMethod implements DeliveryMethod {
  const _DeliveryMethod({required this.id, required this.name, this.description, required this.price, this.free = false, this.available = true, this.error, @JsonKey(name: 'logo_url') this.logoUrl});
  factory _DeliveryMethod.fromJson(Map<String, dynamic> json) => _$DeliveryMethodFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? description;
@override final  Price price;
@override@JsonKey() final  bool free;
@override@JsonKey() final  bool available;
@override final  String? error;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;

/// Create a copy of DeliveryMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryMethodCopyWith<_DeliveryMethod> get copyWith => __$DeliveryMethodCopyWithImpl<_DeliveryMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryMethodToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.free, free) || other.free == free)&&(identical(other.available, available) || other.available == available)&&(identical(other.error, error) || other.error == error)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,price,free,available,error,logoUrl);
}

@override
String toString() {
    return 'DeliveryMethod(id: $id, name: $name, description: $description, price: $price, free: $free, available: $available, error: $error, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class _$DeliveryMethodCopyWith<$Res> implements $DeliveryMethodCopyWith<$Res> {
  factory _$DeliveryMethodCopyWith(_DeliveryMethod value, $Res Function(_DeliveryMethod) _then) = __$DeliveryMethodCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? description, Price price, bool free, bool available, String? error,@JsonKey(name: 'logo_url') String? logoUrl
});


@override $PriceCopyWith<$Res> get price;

}
/// @nodoc
class __$DeliveryMethodCopyWithImpl<$Res>
    implements _$DeliveryMethodCopyWith<$Res> {
  __$DeliveryMethodCopyWithImpl(this._self, this._then);

  final _DeliveryMethod _self;
  final $Res Function(_DeliveryMethod) _then;

/// Create a copy of DeliveryMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? free = null,Object? available = null,Object? error = freezed,Object? logoUrl = freezed,}) {
  return _then(_DeliveryMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,free: null == free ? _self.free : free // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DeliveryMethod
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// @nodoc
mixin _$PaymentOption {

@JsonKey(name: 'payment_method_id') int get paymentMethodId;@JsonKey(name: 'provider_id') int get providerId;/// Cardul salvat, cand optiunea e unul. Pe uportho clientii platesc des asa.
@JsonKey(name: 'token_id') int? get tokenId; String get name;@JsonKey(name: 'provider_name') String get providerName; String get code; String get kind;/// Textul configurat de magazin, deja convertit din HTML in blocuri de catre
/// server (aplicatia nu are motor HTML).
 List<DescriptionBlock> get instructions;@JsonKey(name: 'is_test') bool get isTest;
/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentOptionCopyWith<PaymentOption> get copyWith => _$PaymentOptionCopyWithImpl<PaymentOption>(this as PaymentOption, _$identity);

  /// Serializes this PaymentOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentOption&&(identical(other.paymentMethodId, _this.paymentMethodId) || other.paymentMethodId == _this.paymentMethodId)&&(identical(other.providerId, _this.providerId) || other.providerId == _this.providerId)&&(identical(other.tokenId, _this.tokenId) || other.tokenId == _this.tokenId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.providerName, _this.providerName) || other.providerName == _this.providerName)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&const DeepCollectionEquality().equals(other.instructions, _this.instructions)&&(identical(other.isTest, _this.isTest) || other.isTest == _this.isTest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentOption;
  return Object.hash(runtimeType,_this.paymentMethodId,_this.providerId,_this.tokenId,_this.name,_this.providerName,_this.code,_this.kind,const DeepCollectionEquality().hash(_this.instructions),_this.isTest);
}

@override
String toString() {
  final _this = this as PaymentOption;
  return 'PaymentOption(paymentMethodId: ${_this.paymentMethodId}, providerId: ${_this.providerId}, tokenId: ${_this.tokenId}, name: ${_this.name}, providerName: ${_this.providerName}, code: ${_this.code}, kind: ${_this.kind}, instructions: ${_this.instructions}, isTest: ${_this.isTest})';
}


}

/// @nodoc
abstract mixin class $PaymentOptionCopyWith<$Res>  {
  factory $PaymentOptionCopyWith(PaymentOption value, $Res Function(PaymentOption) _then) = _$PaymentOptionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'payment_method_id') int paymentMethodId,@JsonKey(name: 'provider_id') int providerId,@JsonKey(name: 'token_id') int? tokenId, String name,@JsonKey(name: 'provider_name') String providerName, String code, String kind, List<DescriptionBlock> instructions,@JsonKey(name: 'is_test') bool isTest
});




}
/// @nodoc
class _$PaymentOptionCopyWithImpl<$Res>
    implements $PaymentOptionCopyWith<$Res> {
  _$PaymentOptionCopyWithImpl(this._self, this._then);

  final PaymentOption _self;
  final $Res Function(PaymentOption) _then;

/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentMethodId = null,Object? providerId = null,Object? tokenId = freezed,Object? name = null,Object? providerName = null,Object? code = null,Object? kind = null,Object? instructions = null,Object? isTest = null,}) {
  return _then(PaymentOption(
paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as int,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,tokenId: freezed == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,isTest: null == isTest ? _self.isTest : isTest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentOption].
extension PaymentOptionPatterns on PaymentOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentOption value)  $default,){
final _that = this;
switch (_that) {
case _PaymentOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentOption value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'payment_method_id')  int paymentMethodId, @JsonKey(name: 'provider_id')  int providerId, @JsonKey(name: 'token_id')  int? tokenId,  String name, @JsonKey(name: 'provider_name')  String providerName,  String code,  String kind,  List<DescriptionBlock> instructions, @JsonKey(name: 'is_test')  bool isTest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
return $default(_that.paymentMethodId,_that.providerId,_that.tokenId,_that.name,_that.providerName,_that.code,_that.kind,_that.instructions,_that.isTest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'payment_method_id')  int paymentMethodId, @JsonKey(name: 'provider_id')  int providerId, @JsonKey(name: 'token_id')  int? tokenId,  String name, @JsonKey(name: 'provider_name')  String providerName,  String code,  String kind,  List<DescriptionBlock> instructions, @JsonKey(name: 'is_test')  bool isTest)  $default,) {final _that = this;
switch (_that) {
case _PaymentOption():
return $default(_that.paymentMethodId,_that.providerId,_that.tokenId,_that.name,_that.providerName,_that.code,_that.kind,_that.instructions,_that.isTest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'payment_method_id')  int paymentMethodId, @JsonKey(name: 'provider_id')  int providerId, @JsonKey(name: 'token_id')  int? tokenId,  String name, @JsonKey(name: 'provider_name')  String providerName,  String code,  String kind,  List<DescriptionBlock> instructions, @JsonKey(name: 'is_test')  bool isTest)?  $default,) {final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
return $default(_that.paymentMethodId,_that.providerId,_that.tokenId,_that.name,_that.providerName,_that.code,_that.kind,_that.instructions,_that.isTest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentOption extends PaymentOption {
  const _PaymentOption({@JsonKey(name: 'payment_method_id') required this.paymentMethodId, @JsonKey(name: 'provider_id') required this.providerId, @JsonKey(name: 'token_id') this.tokenId, required this.name, @JsonKey(name: 'provider_name') required this.providerName, required this.code, required this.kind,  List<DescriptionBlock> instructions = const [], @JsonKey(name: 'is_test') this.isTest = false}): _instructions = instructions,super._();
  factory _PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);

@override@JsonKey(name: 'payment_method_id') final  int paymentMethodId;
@override@JsonKey(name: 'provider_id') final  int providerId;
/// Cardul salvat, cand optiunea e unul. Pe uportho clientii platesc des asa.
@override@JsonKey(name: 'token_id') final  int? tokenId;
@override final  String name;
@override@JsonKey(name: 'provider_name') final  String providerName;
@override final  String code;
@override final  String kind;
/// Textul configurat de magazin, deja convertit din HTML in blocuri de catre
/// server (aplicatia nu are motor HTML).
 final  List<DescriptionBlock> _instructions;
/// Textul configurat de magazin, deja convertit din HTML in blocuri de catre
/// server (aplicatia nu are motor HTML).
@override@JsonKey() List<DescriptionBlock> get instructions {
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instructions);
}

@override@JsonKey(name: 'is_test') final  bool isTest;

/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentOptionCopyWith<_PaymentOption> get copyWith => __$PaymentOptionCopyWithImpl<_PaymentOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentOption&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.name, name) || other.name == name)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.code, code) || other.code == code)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.instructions, _instructions)&&(identical(other.isTest, isTest) || other.isTest == isTest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,paymentMethodId,providerId,tokenId,name,providerName,code,kind,const DeepCollectionEquality().hash(_instructions),isTest);
}

@override
String toString() {
    return 'PaymentOption(paymentMethodId: $paymentMethodId, providerId: $providerId, tokenId: $tokenId, name: $name, providerName: $providerName, code: $code, kind: $kind, instructions: $instructions, isTest: $isTest)';
}


}

/// @nodoc
abstract mixin class _$PaymentOptionCopyWith<$Res> implements $PaymentOptionCopyWith<$Res> {
  factory _$PaymentOptionCopyWith(_PaymentOption value, $Res Function(_PaymentOption) _then) = __$PaymentOptionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'payment_method_id') int paymentMethodId,@JsonKey(name: 'provider_id') int providerId,@JsonKey(name: 'token_id') int? tokenId, String name,@JsonKey(name: 'provider_name') String providerName, String code, String kind, List<DescriptionBlock> instructions,@JsonKey(name: 'is_test') bool isTest
});




}
/// @nodoc
class __$PaymentOptionCopyWithImpl<$Res>
    implements _$PaymentOptionCopyWith<$Res> {
  __$PaymentOptionCopyWithImpl(this._self, this._then);

  final _PaymentOption _self;
  final $Res Function(_PaymentOption) _then;

/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentMethodId = null,Object? providerId = null,Object? tokenId = freezed,Object? name = null,Object? providerName = null,Object? code = null,Object? kind = null,Object? instructions = null,Object? isTest = null,}) {
  return _then(_PaymentOption(
paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as int,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,tokenId: freezed == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,isTest: null == isTest ? _self.isTest : isTest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CheckoutBlocker {

 String get code; String get message;
/// Create a copy of CheckoutBlocker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutBlockerCopyWith<CheckoutBlocker> get copyWith => _$CheckoutBlockerCopyWithImpl<CheckoutBlocker>(this as CheckoutBlocker, _$identity);

  /// Serializes this CheckoutBlocker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutBlocker;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutBlocker&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutBlocker;
  return Object.hash(runtimeType,_this.code,_this.message);
}

@override
String toString() {
  final _this = this as CheckoutBlocker;
  return 'CheckoutBlocker(code: ${_this.code}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $CheckoutBlockerCopyWith<$Res>  {
  factory $CheckoutBlockerCopyWith(CheckoutBlocker value, $Res Function(CheckoutBlocker) _then) = _$CheckoutBlockerCopyWithImpl;
@useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$CheckoutBlockerCopyWithImpl<$Res>
    implements $CheckoutBlockerCopyWith<$Res> {
  _$CheckoutBlockerCopyWithImpl(this._self, this._then);

  final CheckoutBlocker _self;
  final $Res Function(CheckoutBlocker) _then;

/// Create a copy of CheckoutBlocker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,}) {
  return _then(CheckoutBlocker(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutBlocker].
extension CheckoutBlockerPatterns on CheckoutBlocker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutBlocker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutBlocker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutBlocker value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutBlocker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutBlocker value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutBlocker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutBlocker() when $default != null:
return $default(_that.code,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message)  $default,) {final _that = this;
switch (_that) {
case _CheckoutBlocker():
return $default(_that.code,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutBlocker() when $default != null:
return $default(_that.code,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutBlocker implements CheckoutBlocker {
  const _CheckoutBlocker({required this.code, required this.message});
  factory _CheckoutBlocker.fromJson(Map<String, dynamic> json) => _$CheckoutBlockerFromJson(json);

@override final  String code;
@override final  String message;

/// Create a copy of CheckoutBlocker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutBlockerCopyWith<_CheckoutBlocker> get copyWith => __$CheckoutBlockerCopyWithImpl<_CheckoutBlocker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutBlockerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutBlocker&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message);
}

@override
String toString() {
    return 'CheckoutBlocker(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CheckoutBlockerCopyWith<$Res> implements $CheckoutBlockerCopyWith<$Res> {
  factory _$CheckoutBlockerCopyWith(_CheckoutBlocker value, $Res Function(_CheckoutBlocker) _then) = __$CheckoutBlockerCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class __$CheckoutBlockerCopyWithImpl<$Res>
    implements _$CheckoutBlockerCopyWith<$Res> {
  __$CheckoutBlockerCopyWithImpl(this._self, this._then);

  final _CheckoutBlocker _self;
  final $Res Function(_CheckoutBlocker) _then;

/// Create a copy of CheckoutBlocker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(_CheckoutBlocker(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Checkout {

@JsonKey(name: 'order_id') int get orderId; Cart get cart; CheckoutAddresses get addresses;@JsonKey(name: 'delivery_methods') List<DeliveryMethod> get deliveryMethods;@JsonKey(name: 'selected_delivery_method_id') int? get selectedDeliveryMethodId;@JsonKey(name: 'delivery_required') bool get deliveryRequired;@JsonKey(name: 'payment_options') List<PaymentOption> get paymentOptions; List<CheckoutBlocker> get blockers;
/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutCopyWith<Checkout> get copyWith => _$CheckoutCopyWithImpl<Checkout>(this as Checkout, _$identity);

  /// Serializes this Checkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Checkout;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Checkout&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.cart, _this.cart) || other.cart == _this.cart)&&(identical(other.addresses, _this.addresses) || other.addresses == _this.addresses)&&const DeepCollectionEquality().equals(other.deliveryMethods, _this.deliveryMethods)&&(identical(other.selectedDeliveryMethodId, _this.selectedDeliveryMethodId) || other.selectedDeliveryMethodId == _this.selectedDeliveryMethodId)&&(identical(other.deliveryRequired, _this.deliveryRequired) || other.deliveryRequired == _this.deliveryRequired)&&const DeepCollectionEquality().equals(other.paymentOptions, _this.paymentOptions)&&const DeepCollectionEquality().equals(other.blockers, _this.blockers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Checkout;
  return Object.hash(runtimeType,_this.orderId,_this.cart,_this.addresses,const DeepCollectionEquality().hash(_this.deliveryMethods),_this.selectedDeliveryMethodId,_this.deliveryRequired,const DeepCollectionEquality().hash(_this.paymentOptions),const DeepCollectionEquality().hash(_this.blockers));
}

@override
String toString() {
  final _this = this as Checkout;
  return 'Checkout(orderId: ${_this.orderId}, cart: ${_this.cart}, addresses: ${_this.addresses}, deliveryMethods: ${_this.deliveryMethods}, selectedDeliveryMethodId: ${_this.selectedDeliveryMethodId}, deliveryRequired: ${_this.deliveryRequired}, paymentOptions: ${_this.paymentOptions}, blockers: ${_this.blockers})';
}


}

/// @nodoc
abstract mixin class $CheckoutCopyWith<$Res>  {
  factory $CheckoutCopyWith(Checkout value, $Res Function(Checkout) _then) = _$CheckoutCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'order_id') int orderId, Cart cart, CheckoutAddresses addresses,@JsonKey(name: 'delivery_methods') List<DeliveryMethod> deliveryMethods,@JsonKey(name: 'selected_delivery_method_id') int? selectedDeliveryMethodId,@JsonKey(name: 'delivery_required') bool deliveryRequired,@JsonKey(name: 'payment_options') List<PaymentOption> paymentOptions, List<CheckoutBlocker> blockers
});


$CartCopyWith<$Res> get cart;$CheckoutAddressesCopyWith<$Res> get addresses;

}
/// @nodoc
class _$CheckoutCopyWithImpl<$Res>
    implements $CheckoutCopyWith<$Res> {
  _$CheckoutCopyWithImpl(this._self, this._then);

  final Checkout _self;
  final $Res Function(Checkout) _then;

/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? cart = null,Object? addresses = null,Object? deliveryMethods = null,Object? selectedDeliveryMethodId = freezed,Object? deliveryRequired = null,Object? paymentOptions = null,Object? blockers = null,}) {
  return _then(Checkout(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,cart: null == cart ? _self.cart : cart // ignore: cast_nullable_to_non_nullable
as Cart,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as CheckoutAddresses,deliveryMethods: null == deliveryMethods ? _self.deliveryMethods : deliveryMethods // ignore: cast_nullable_to_non_nullable
as List<DeliveryMethod>,selectedDeliveryMethodId: freezed == selectedDeliveryMethodId ? _self.selectedDeliveryMethodId : selectedDeliveryMethodId // ignore: cast_nullable_to_non_nullable
as int?,deliveryRequired: null == deliveryRequired ? _self.deliveryRequired : deliveryRequired // ignore: cast_nullable_to_non_nullable
as bool,paymentOptions: null == paymentOptions ? _self.paymentOptions : paymentOptions // ignore: cast_nullable_to_non_nullable
as List<PaymentOption>,blockers: null == blockers ? _self.blockers : blockers // ignore: cast_nullable_to_non_nullable
as List<CheckoutBlocker>,
  ));
}
/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartCopyWith<$Res> get cart {
  
  return $CartCopyWith<$Res>(_self.cart, (value) {
    return _then(_self.copyWith(cart: value));
  });
}/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckoutAddressesCopyWith<$Res> get addresses {
  
  return $CheckoutAddressesCopyWith<$Res>(_self.addresses, (value) {
    return _then(_self.copyWith(addresses: value));
  });
}
}


/// Adds pattern-matching-related methods to [Checkout].
extension CheckoutPatterns on Checkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Checkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Checkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Checkout value)  $default,){
final _that = this;
switch (_that) {
case _Checkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Checkout value)?  $default,){
final _that = this;
switch (_that) {
case _Checkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  int orderId,  Cart cart,  CheckoutAddresses addresses, @JsonKey(name: 'delivery_methods')  List<DeliveryMethod> deliveryMethods, @JsonKey(name: 'selected_delivery_method_id')  int? selectedDeliveryMethodId, @JsonKey(name: 'delivery_required')  bool deliveryRequired, @JsonKey(name: 'payment_options')  List<PaymentOption> paymentOptions,  List<CheckoutBlocker> blockers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Checkout() when $default != null:
return $default(_that.orderId,_that.cart,_that.addresses,_that.deliveryMethods,_that.selectedDeliveryMethodId,_that.deliveryRequired,_that.paymentOptions,_that.blockers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  int orderId,  Cart cart,  CheckoutAddresses addresses, @JsonKey(name: 'delivery_methods')  List<DeliveryMethod> deliveryMethods, @JsonKey(name: 'selected_delivery_method_id')  int? selectedDeliveryMethodId, @JsonKey(name: 'delivery_required')  bool deliveryRequired, @JsonKey(name: 'payment_options')  List<PaymentOption> paymentOptions,  List<CheckoutBlocker> blockers)  $default,) {final _that = this;
switch (_that) {
case _Checkout():
return $default(_that.orderId,_that.cart,_that.addresses,_that.deliveryMethods,_that.selectedDeliveryMethodId,_that.deliveryRequired,_that.paymentOptions,_that.blockers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'order_id')  int orderId,  Cart cart,  CheckoutAddresses addresses, @JsonKey(name: 'delivery_methods')  List<DeliveryMethod> deliveryMethods, @JsonKey(name: 'selected_delivery_method_id')  int? selectedDeliveryMethodId, @JsonKey(name: 'delivery_required')  bool deliveryRequired, @JsonKey(name: 'payment_options')  List<PaymentOption> paymentOptions,  List<CheckoutBlocker> blockers)?  $default,) {final _that = this;
switch (_that) {
case _Checkout() when $default != null:
return $default(_that.orderId,_that.cart,_that.addresses,_that.deliveryMethods,_that.selectedDeliveryMethodId,_that.deliveryRequired,_that.paymentOptions,_that.blockers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Checkout extends Checkout {
  const _Checkout({@JsonKey(name: 'order_id') required this.orderId, required this.cart, required this.addresses, @JsonKey(name: 'delivery_methods')  List<DeliveryMethod> deliveryMethods = const [], @JsonKey(name: 'selected_delivery_method_id') this.selectedDeliveryMethodId, @JsonKey(name: 'delivery_required') this.deliveryRequired = true, @JsonKey(name: 'payment_options')  List<PaymentOption> paymentOptions = const [],  List<CheckoutBlocker> blockers = const []}): _deliveryMethods = deliveryMethods,_paymentOptions = paymentOptions,_blockers = blockers,super._();
  factory _Checkout.fromJson(Map<String, dynamic> json) => _$CheckoutFromJson(json);

@override@JsonKey(name: 'order_id') final  int orderId;
@override final  Cart cart;
@override final  CheckoutAddresses addresses;
 final  List<DeliveryMethod> _deliveryMethods;
@override@JsonKey(name: 'delivery_methods') List<DeliveryMethod> get deliveryMethods {
  if (_deliveryMethods is EqualUnmodifiableListView) return _deliveryMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveryMethods);
}

@override@JsonKey(name: 'selected_delivery_method_id') final  int? selectedDeliveryMethodId;
@override@JsonKey(name: 'delivery_required') final  bool deliveryRequired;
 final  List<PaymentOption> _paymentOptions;
@override@JsonKey(name: 'payment_options') List<PaymentOption> get paymentOptions {
  if (_paymentOptions is EqualUnmodifiableListView) return _paymentOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentOptions);
}

 final  List<CheckoutBlocker> _blockers;
@override@JsonKey() List<CheckoutBlocker> get blockers {
  if (_blockers is EqualUnmodifiableListView) return _blockers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockers);
}


/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutCopyWith<_Checkout> get copyWith => __$CheckoutCopyWithImpl<_Checkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Checkout&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.cart, cart) || other.cart == cart)&&(identical(other.addresses, addresses) || other.addresses == addresses)&&const DeepCollectionEquality().equals(other.deliveryMethods, _deliveryMethods)&&(identical(other.selectedDeliveryMethodId, selectedDeliveryMethodId) || other.selectedDeliveryMethodId == selectedDeliveryMethodId)&&(identical(other.deliveryRequired, deliveryRequired) || other.deliveryRequired == deliveryRequired)&&const DeepCollectionEquality().equals(other.paymentOptions, _paymentOptions)&&const DeepCollectionEquality().equals(other.blockers, _blockers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderId,cart,addresses,const DeepCollectionEquality().hash(_deliveryMethods),selectedDeliveryMethodId,deliveryRequired,const DeepCollectionEquality().hash(_paymentOptions),const DeepCollectionEquality().hash(_blockers));
}

@override
String toString() {
    return 'Checkout(orderId: $orderId, cart: $cart, addresses: $addresses, deliveryMethods: $deliveryMethods, selectedDeliveryMethodId: $selectedDeliveryMethodId, deliveryRequired: $deliveryRequired, paymentOptions: $paymentOptions, blockers: $blockers)';
}


}

/// @nodoc
abstract mixin class _$CheckoutCopyWith<$Res> implements $CheckoutCopyWith<$Res> {
  factory _$CheckoutCopyWith(_Checkout value, $Res Function(_Checkout) _then) = __$CheckoutCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'order_id') int orderId, Cart cart, CheckoutAddresses addresses,@JsonKey(name: 'delivery_methods') List<DeliveryMethod> deliveryMethods,@JsonKey(name: 'selected_delivery_method_id') int? selectedDeliveryMethodId,@JsonKey(name: 'delivery_required') bool deliveryRequired,@JsonKey(name: 'payment_options') List<PaymentOption> paymentOptions, List<CheckoutBlocker> blockers
});


@override $CartCopyWith<$Res> get cart;@override $CheckoutAddressesCopyWith<$Res> get addresses;

}
/// @nodoc
class __$CheckoutCopyWithImpl<$Res>
    implements _$CheckoutCopyWith<$Res> {
  __$CheckoutCopyWithImpl(this._self, this._then);

  final _Checkout _self;
  final $Res Function(_Checkout) _then;

/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? cart = null,Object? addresses = null,Object? deliveryMethods = null,Object? selectedDeliveryMethodId = freezed,Object? deliveryRequired = null,Object? paymentOptions = null,Object? blockers = null,}) {
  return _then(_Checkout(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,cart: null == cart ? _self.cart : cart // ignore: cast_nullable_to_non_nullable
as Cart,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as CheckoutAddresses,deliveryMethods: null == deliveryMethods ? _self._deliveryMethods : deliveryMethods // ignore: cast_nullable_to_non_nullable
as List<DeliveryMethod>,selectedDeliveryMethodId: freezed == selectedDeliveryMethodId ? _self.selectedDeliveryMethodId : selectedDeliveryMethodId // ignore: cast_nullable_to_non_nullable
as int?,deliveryRequired: null == deliveryRequired ? _self.deliveryRequired : deliveryRequired // ignore: cast_nullable_to_non_nullable
as bool,paymentOptions: null == paymentOptions ? _self._paymentOptions : paymentOptions // ignore: cast_nullable_to_non_nullable
as List<PaymentOption>,blockers: null == blockers ? _self._blockers : blockers // ignore: cast_nullable_to_non_nullable
as List<CheckoutBlocker>,
  ));
}

/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartCopyWith<$Res> get cart {
  
  return $CartCopyWith<$Res>(_self.cart, (value) {
    return _then(_self.copyWith(cart: value));
  });
}/// Create a copy of Checkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckoutAddressesCopyWith<$Res> get addresses {
  
  return $CheckoutAddressesCopyWith<$Res>(_self.addresses, (value) {
    return _then(_self.copyWith(addresses: value));
  });
}
}


/// @nodoc
mixin _$PaymentOutcome {

 String get kind; String? get method; List<DescriptionBlock> get instructions; String? get reference;/// Starea tranzactiei, cand serverul a incercat deja plata (card salvat).
 String? get state;/// Motivul dat de provider cand plata cu cardul salvat nu a trecut.
 String? get message; String? get url;@JsonKey(name: 'return_url_prefix') String? get returnUrlPrefix;
/// Create a copy of PaymentOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentOutcomeCopyWith<PaymentOutcome> get copyWith => _$PaymentOutcomeCopyWithImpl<PaymentOutcome>(this as PaymentOutcome, _$identity);

  /// Serializes this PaymentOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentOutcome&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.method, _this.method) || other.method == _this.method)&&const DeepCollectionEquality().equals(other.instructions, _this.instructions)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.returnUrlPrefix, _this.returnUrlPrefix) || other.returnUrlPrefix == _this.returnUrlPrefix));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentOutcome;
  return Object.hash(runtimeType,_this.kind,_this.method,const DeepCollectionEquality().hash(_this.instructions),_this.reference,_this.state,_this.message,_this.url,_this.returnUrlPrefix);
}

@override
String toString() {
  final _this = this as PaymentOutcome;
  return 'PaymentOutcome(kind: ${_this.kind}, method: ${_this.method}, instructions: ${_this.instructions}, reference: ${_this.reference}, state: ${_this.state}, message: ${_this.message}, url: ${_this.url}, returnUrlPrefix: ${_this.returnUrlPrefix})';
}


}

/// @nodoc
abstract mixin class $PaymentOutcomeCopyWith<$Res>  {
  factory $PaymentOutcomeCopyWith(PaymentOutcome value, $Res Function(PaymentOutcome) _then) = _$PaymentOutcomeCopyWithImpl;
@useResult
$Res call({
 String kind, String? method, List<DescriptionBlock> instructions, String? reference, String? state, String? message, String? url,@JsonKey(name: 'return_url_prefix') String? returnUrlPrefix
});




}
/// @nodoc
class _$PaymentOutcomeCopyWithImpl<$Res>
    implements $PaymentOutcomeCopyWith<$Res> {
  _$PaymentOutcomeCopyWithImpl(this._self, this._then);

  final PaymentOutcome _self;
  final $Res Function(PaymentOutcome) _then;

/// Create a copy of PaymentOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? method = freezed,Object? instructions = null,Object? reference = freezed,Object? state = freezed,Object? message = freezed,Object? url = freezed,Object? returnUrlPrefix = freezed,}) {
  return _then(PaymentOutcome(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String?,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,returnUrlPrefix: freezed == returnUrlPrefix ? _self.returnUrlPrefix : returnUrlPrefix // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentOutcome].
extension PaymentOutcomePatterns on PaymentOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentOutcome value)  $default,){
final _that = this;
switch (_that) {
case _PaymentOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String? method,  List<DescriptionBlock> instructions,  String? reference,  String? state,  String? message,  String? url, @JsonKey(name: 'return_url_prefix')  String? returnUrlPrefix)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentOutcome() when $default != null:
return $default(_that.kind,_that.method,_that.instructions,_that.reference,_that.state,_that.message,_that.url,_that.returnUrlPrefix);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String? method,  List<DescriptionBlock> instructions,  String? reference,  String? state,  String? message,  String? url, @JsonKey(name: 'return_url_prefix')  String? returnUrlPrefix)  $default,) {final _that = this;
switch (_that) {
case _PaymentOutcome():
return $default(_that.kind,_that.method,_that.instructions,_that.reference,_that.state,_that.message,_that.url,_that.returnUrlPrefix);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String? method,  List<DescriptionBlock> instructions,  String? reference,  String? state,  String? message,  String? url, @JsonKey(name: 'return_url_prefix')  String? returnUrlPrefix)?  $default,) {final _that = this;
switch (_that) {
case _PaymentOutcome() when $default != null:
return $default(_that.kind,_that.method,_that.instructions,_that.reference,_that.state,_that.message,_that.url,_that.returnUrlPrefix);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentOutcome extends PaymentOutcome {
  const _PaymentOutcome({required this.kind, this.method,  List<DescriptionBlock> instructions = const [], this.reference, this.state, this.message, this.url, @JsonKey(name: 'return_url_prefix') this.returnUrlPrefix}): _instructions = instructions,super._();
  factory _PaymentOutcome.fromJson(Map<String, dynamic> json) => _$PaymentOutcomeFromJson(json);

@override final  String kind;
@override final  String? method;
 final  List<DescriptionBlock> _instructions;
@override@JsonKey() List<DescriptionBlock> get instructions {
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instructions);
}

@override final  String? reference;
/// Starea tranzactiei, cand serverul a incercat deja plata (card salvat).
@override final  String? state;
/// Motivul dat de provider cand plata cu cardul salvat nu a trecut.
@override final  String? message;
@override final  String? url;
@override@JsonKey(name: 'return_url_prefix') final  String? returnUrlPrefix;

/// Create a copy of PaymentOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentOutcomeCopyWith<_PaymentOutcome> get copyWith => __$PaymentOutcomeCopyWithImpl<_PaymentOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentOutcome&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.instructions, _instructions)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.state, state) || other.state == state)&&(identical(other.message, message) || other.message == message)&&(identical(other.url, url) || other.url == url)&&(identical(other.returnUrlPrefix, returnUrlPrefix) || other.returnUrlPrefix == returnUrlPrefix));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,method,const DeepCollectionEquality().hash(_instructions),reference,state,message,url,returnUrlPrefix);
}

@override
String toString() {
    return 'PaymentOutcome(kind: $kind, method: $method, instructions: $instructions, reference: $reference, state: $state, message: $message, url: $url, returnUrlPrefix: $returnUrlPrefix)';
}


}

/// @nodoc
abstract mixin class _$PaymentOutcomeCopyWith<$Res> implements $PaymentOutcomeCopyWith<$Res> {
  factory _$PaymentOutcomeCopyWith(_PaymentOutcome value, $Res Function(_PaymentOutcome) _then) = __$PaymentOutcomeCopyWithImpl;
@override @useResult
$Res call({
 String kind, String? method, List<DescriptionBlock> instructions, String? reference, String? state, String? message, String? url,@JsonKey(name: 'return_url_prefix') String? returnUrlPrefix
});




}
/// @nodoc
class __$PaymentOutcomeCopyWithImpl<$Res>
    implements _$PaymentOutcomeCopyWith<$Res> {
  __$PaymentOutcomeCopyWithImpl(this._self, this._then);

  final _PaymentOutcome _self;
  final $Res Function(_PaymentOutcome) _then;

/// Create a copy of PaymentOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? method = freezed,Object? instructions = null,Object? reference = freezed,Object? state = freezed,Object? message = freezed,Object? url = freezed,Object? returnUrlPrefix = freezed,}) {
  return _then(_PaymentOutcome(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String?,instructions: null == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,returnUrlPrefix: freezed == returnUrlPrefix ? _self.returnUrlPrefix : returnUrlPrefix // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CheckoutConfirmation {

@JsonKey(name: 'order_id') int get orderId;@JsonKey(name: 'order_ref') String get orderRef; PaymentOutcome get payment;
/// Create a copy of CheckoutConfirmation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutConfirmationCopyWith<CheckoutConfirmation> get copyWith => _$CheckoutConfirmationCopyWithImpl<CheckoutConfirmation>(this as CheckoutConfirmation, _$identity);

  /// Serializes this CheckoutConfirmation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckoutConfirmation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutConfirmation&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.orderRef, _this.orderRef) || other.orderRef == _this.orderRef)&&(identical(other.payment, _this.payment) || other.payment == _this.payment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckoutConfirmation;
  return Object.hash(runtimeType,_this.orderId,_this.orderRef,_this.payment);
}

@override
String toString() {
  final _this = this as CheckoutConfirmation;
  return 'CheckoutConfirmation(orderId: ${_this.orderId}, orderRef: ${_this.orderRef}, payment: ${_this.payment})';
}


}

/// @nodoc
abstract mixin class $CheckoutConfirmationCopyWith<$Res>  {
  factory $CheckoutConfirmationCopyWith(CheckoutConfirmation value, $Res Function(CheckoutConfirmation) _then) = _$CheckoutConfirmationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'order_id') int orderId,@JsonKey(name: 'order_ref') String orderRef, PaymentOutcome payment
});


$PaymentOutcomeCopyWith<$Res> get payment;

}
/// @nodoc
class _$CheckoutConfirmationCopyWithImpl<$Res>
    implements $CheckoutConfirmationCopyWith<$Res> {
  _$CheckoutConfirmationCopyWithImpl(this._self, this._then);

  final CheckoutConfirmation _self;
  final $Res Function(CheckoutConfirmation) _then;

/// Create a copy of CheckoutConfirmation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? orderRef = null,Object? payment = null,}) {
  return _then(CheckoutConfirmation(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,orderRef: null == orderRef ? _self.orderRef : orderRef // ignore: cast_nullable_to_non_nullable
as String,payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as PaymentOutcome,
  ));
}
/// Create a copy of CheckoutConfirmation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentOutcomeCopyWith<$Res> get payment {
  
  return $PaymentOutcomeCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckoutConfirmation].
extension CheckoutConfirmationPatterns on CheckoutConfirmation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutConfirmation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutConfirmation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutConfirmation value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutConfirmation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutConfirmation value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutConfirmation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  int orderId, @JsonKey(name: 'order_ref')  String orderRef,  PaymentOutcome payment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutConfirmation() when $default != null:
return $default(_that.orderId,_that.orderRef,_that.payment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  int orderId, @JsonKey(name: 'order_ref')  String orderRef,  PaymentOutcome payment)  $default,) {final _that = this;
switch (_that) {
case _CheckoutConfirmation():
return $default(_that.orderId,_that.orderRef,_that.payment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'order_id')  int orderId, @JsonKey(name: 'order_ref')  String orderRef,  PaymentOutcome payment)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutConfirmation() when $default != null:
return $default(_that.orderId,_that.orderRef,_that.payment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutConfirmation implements CheckoutConfirmation {
  const _CheckoutConfirmation({@JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'order_ref') required this.orderRef, required this.payment});
  factory _CheckoutConfirmation.fromJson(Map<String, dynamic> json) => _$CheckoutConfirmationFromJson(json);

@override@JsonKey(name: 'order_id') final  int orderId;
@override@JsonKey(name: 'order_ref') final  String orderRef;
@override final  PaymentOutcome payment;

/// Create a copy of CheckoutConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutConfirmationCopyWith<_CheckoutConfirmation> get copyWith => __$CheckoutConfirmationCopyWithImpl<_CheckoutConfirmation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutConfirmationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutConfirmation&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.orderRef, orderRef) || other.orderRef == orderRef)&&(identical(other.payment, payment) || other.payment == payment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderId,orderRef,payment);
}

@override
String toString() {
    return 'CheckoutConfirmation(orderId: $orderId, orderRef: $orderRef, payment: $payment)';
}


}

/// @nodoc
abstract mixin class _$CheckoutConfirmationCopyWith<$Res> implements $CheckoutConfirmationCopyWith<$Res> {
  factory _$CheckoutConfirmationCopyWith(_CheckoutConfirmation value, $Res Function(_CheckoutConfirmation) _then) = __$CheckoutConfirmationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'order_id') int orderId,@JsonKey(name: 'order_ref') String orderRef, PaymentOutcome payment
});


@override $PaymentOutcomeCopyWith<$Res> get payment;

}
/// @nodoc
class __$CheckoutConfirmationCopyWithImpl<$Res>
    implements _$CheckoutConfirmationCopyWith<$Res> {
  __$CheckoutConfirmationCopyWithImpl(this._self, this._then);

  final _CheckoutConfirmation _self;
  final $Res Function(_CheckoutConfirmation) _then;

/// Create a copy of CheckoutConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? orderRef = null,Object? payment = null,}) {
  return _then(_CheckoutConfirmation(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,orderRef: null == orderRef ? _self.orderRef : orderRef // ignore: cast_nullable_to_non_nullable
as String,payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as PaymentOutcome,
  ));
}

/// Create a copy of CheckoutConfirmation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentOutcomeCopyWith<$Res> get payment {
  
  return $PaymentOutcomeCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

// dart format on

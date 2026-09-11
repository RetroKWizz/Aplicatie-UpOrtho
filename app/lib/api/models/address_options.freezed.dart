// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddressCountry {

 int get id; String get name; String? get code;@JsonKey(name: 'state_required') bool get stateRequired;@JsonKey(name: 'zip_required') bool get zipRequired;
/// Create a copy of AddressCountry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCountryCopyWith<AddressCountry> get copyWith => _$AddressCountryCopyWithImpl<AddressCountry>(this as AddressCountry, _$identity);

  /// Serializes this AddressCountry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressCountry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressCountry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.stateRequired, _this.stateRequired) || other.stateRequired == _this.stateRequired)&&(identical(other.zipRequired, _this.zipRequired) || other.zipRequired == _this.zipRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressCountry;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code,_this.stateRequired,_this.zipRequired);
}

@override
String toString() {
  final _this = this as AddressCountry;
  return 'AddressCountry(id: ${_this.id}, name: ${_this.name}, code: ${_this.code}, stateRequired: ${_this.stateRequired}, zipRequired: ${_this.zipRequired})';
}


}

/// @nodoc
abstract mixin class $AddressCountryCopyWith<$Res>  {
  factory $AddressCountryCopyWith(AddressCountry value, $Res Function(AddressCountry) _then) = _$AddressCountryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? code,@JsonKey(name: 'state_required') bool stateRequired,@JsonKey(name: 'zip_required') bool zipRequired
});




}
/// @nodoc
class _$AddressCountryCopyWithImpl<$Res>
    implements $AddressCountryCopyWith<$Res> {
  _$AddressCountryCopyWithImpl(this._self, this._then);

  final AddressCountry _self;
  final $Res Function(AddressCountry) _then;

/// Create a copy of AddressCountry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = freezed,Object? stateRequired = null,Object? zipRequired = null,}) {
  return _then(AddressCountry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,stateRequired: null == stateRequired ? _self.stateRequired : stateRequired // ignore: cast_nullable_to_non_nullable
as bool,zipRequired: null == zipRequired ? _self.zipRequired : zipRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressCountry].
extension AddressCountryPatterns on AddressCountry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressCountry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressCountry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressCountry value)  $default,){
final _that = this;
switch (_that) {
case _AddressCountry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressCountry value)?  $default,){
final _that = this;
switch (_that) {
case _AddressCountry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? code, @JsonKey(name: 'state_required')  bool stateRequired, @JsonKey(name: 'zip_required')  bool zipRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressCountry() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.stateRequired,_that.zipRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? code, @JsonKey(name: 'state_required')  bool stateRequired, @JsonKey(name: 'zip_required')  bool zipRequired)  $default,) {final _that = this;
switch (_that) {
case _AddressCountry():
return $default(_that.id,_that.name,_that.code,_that.stateRequired,_that.zipRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? code, @JsonKey(name: 'state_required')  bool stateRequired, @JsonKey(name: 'zip_required')  bool zipRequired)?  $default,) {final _that = this;
switch (_that) {
case _AddressCountry() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.stateRequired,_that.zipRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressCountry implements AddressCountry {
  const _AddressCountry({required this.id, required this.name, this.code, @JsonKey(name: 'state_required') this.stateRequired = false, @JsonKey(name: 'zip_required') this.zipRequired = false});
  factory _AddressCountry.fromJson(Map<String, dynamic> json) => _$AddressCountryFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? code;
@override@JsonKey(name: 'state_required') final  bool stateRequired;
@override@JsonKey(name: 'zip_required') final  bool zipRequired;

/// Create a copy of AddressCountry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCountryCopyWith<_AddressCountry> get copyWith => __$AddressCountryCopyWithImpl<_AddressCountry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressCountryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressCountry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.stateRequired, stateRequired) || other.stateRequired == stateRequired)&&(identical(other.zipRequired, zipRequired) || other.zipRequired == zipRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code,stateRequired,zipRequired);
}

@override
String toString() {
    return 'AddressCountry(id: $id, name: $name, code: $code, stateRequired: $stateRequired, zipRequired: $zipRequired)';
}


}

/// @nodoc
abstract mixin class _$AddressCountryCopyWith<$Res> implements $AddressCountryCopyWith<$Res> {
  factory _$AddressCountryCopyWith(_AddressCountry value, $Res Function(_AddressCountry) _then) = __$AddressCountryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? code,@JsonKey(name: 'state_required') bool stateRequired,@JsonKey(name: 'zip_required') bool zipRequired
});




}
/// @nodoc
class __$AddressCountryCopyWithImpl<$Res>
    implements _$AddressCountryCopyWith<$Res> {
  __$AddressCountryCopyWithImpl(this._self, this._then);

  final _AddressCountry _self;
  final $Res Function(_AddressCountry) _then;

/// Create a copy of AddressCountry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = freezed,Object? stateRequired = null,Object? zipRequired = null,}) {
  return _then(_AddressCountry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,stateRequired: null == stateRequired ? _self.stateRequired : stateRequired // ignore: cast_nullable_to_non_nullable
as bool,zipRequired: null == zipRequired ? _self.zipRequired : zipRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AddressState {

 int get id; String get name; String? get code;
/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressStateCopyWith<AddressState> get copyWith => _$AddressStateCopyWithImpl<AddressState>(this as AddressState, _$identity);

  /// Serializes this AddressState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressState&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressState;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code);
}

@override
String toString() {
  final _this = this as AddressState;
  return 'AddressState(id: ${_this.id}, name: ${_this.name}, code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $AddressStateCopyWith<$Res>  {
  factory $AddressStateCopyWith(AddressState value, $Res Function(AddressState) _then) = _$AddressStateCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? code
});




}
/// @nodoc
class _$AddressStateCopyWithImpl<$Res>
    implements $AddressStateCopyWith<$Res> {
  _$AddressStateCopyWithImpl(this._self, this._then);

  final AddressState _self;
  final $Res Function(AddressState) _then;

/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = freezed,}) {
  return _then(AddressState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressState].
extension AddressStatePatterns on AddressState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressState value)  $default,){
final _that = this;
switch (_that) {
case _AddressState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressState value)?  $default,){
final _that = this;
switch (_that) {
case _AddressState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressState() when $default != null:
return $default(_that.id,_that.name,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? code)  $default,) {final _that = this;
switch (_that) {
case _AddressState():
return $default(_that.id,_that.name,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? code)?  $default,) {final _that = this;
switch (_that) {
case _AddressState() when $default != null:
return $default(_that.id,_that.name,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressState implements AddressState {
  const _AddressState({required this.id, required this.name, this.code});
  factory _AddressState.fromJson(Map<String, dynamic> json) => _$AddressStateFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? code;

/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressStateCopyWith<_AddressState> get copyWith => __$AddressStateCopyWithImpl<_AddressState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code);
}

@override
String toString() {
    return 'AddressState(id: $id, name: $name, code: $code)';
}


}

/// @nodoc
abstract mixin class _$AddressStateCopyWith<$Res> implements $AddressStateCopyWith<$Res> {
  factory _$AddressStateCopyWith(_AddressState value, $Res Function(_AddressState) _then) = __$AddressStateCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? code
});




}
/// @nodoc
class __$AddressStateCopyWithImpl<$Res>
    implements _$AddressStateCopyWith<$Res> {
  __$AddressStateCopyWithImpl(this._self, this._then);

  final _AddressState _self;
  final $Res Function(_AddressState) _then;

/// Create a copy of AddressState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = freezed,}) {
  return _then(_AddressState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AddressCity {

 int get id; String get name; String? get zip;
/// Create a copy of AddressCity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCityCopyWith<AddressCity> get copyWith => _$AddressCityCopyWithImpl<AddressCity>(this as AddressCity, _$identity);

  /// Serializes this AddressCity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressCity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressCity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zip, _this.zip) || other.zip == _this.zip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressCity;
  return Object.hash(runtimeType,_this.id,_this.name,_this.zip);
}

@override
String toString() {
  final _this = this as AddressCity;
  return 'AddressCity(id: ${_this.id}, name: ${_this.name}, zip: ${_this.zip})';
}


}

/// @nodoc
abstract mixin class $AddressCityCopyWith<$Res>  {
  factory $AddressCityCopyWith(AddressCity value, $Res Function(AddressCity) _then) = _$AddressCityCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? zip
});




}
/// @nodoc
class _$AddressCityCopyWithImpl<$Res>
    implements $AddressCityCopyWith<$Res> {
  _$AddressCityCopyWithImpl(this._self, this._then);

  final AddressCity _self;
  final $Res Function(AddressCity) _then;

/// Create a copy of AddressCity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? zip = freezed,}) {
  return _then(AddressCity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressCity].
extension AddressCityPatterns on AddressCity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressCity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressCity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressCity value)  $default,){
final _that = this;
switch (_that) {
case _AddressCity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressCity value)?  $default,){
final _that = this;
switch (_that) {
case _AddressCity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? zip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressCity() when $default != null:
return $default(_that.id,_that.name,_that.zip);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? zip)  $default,) {final _that = this;
switch (_that) {
case _AddressCity():
return $default(_that.id,_that.name,_that.zip);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? zip)?  $default,) {final _that = this;
switch (_that) {
case _AddressCity() when $default != null:
return $default(_that.id,_that.name,_that.zip);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressCity implements AddressCity {
  const _AddressCity({required this.id, required this.name, this.zip});
  factory _AddressCity.fromJson(Map<String, dynamic> json) => _$AddressCityFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? zip;

/// Create a copy of AddressCity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCityCopyWith<_AddressCity> get copyWith => __$AddressCityCopyWithImpl<_AddressCity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressCityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressCity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.zip, zip) || other.zip == zip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,zip);
}

@override
String toString() {
    return 'AddressCity(id: $id, name: $name, zip: $zip)';
}


}

/// @nodoc
abstract mixin class _$AddressCityCopyWith<$Res> implements $AddressCityCopyWith<$Res> {
  factory _$AddressCityCopyWith(_AddressCity value, $Res Function(_AddressCity) _then) = __$AddressCityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? zip
});




}
/// @nodoc
class __$AddressCityCopyWithImpl<$Res>
    implements _$AddressCityCopyWith<$Res> {
  __$AddressCityCopyWithImpl(this._self, this._then);

  final _AddressCity _self;
  final $Res Function(_AddressCity) _then;

/// Create a copy of AddressCity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? zip = freezed,}) {
  return _then(_AddressCity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AddressRequired {

 List<String> get delivery; List<String> get invoice;
/// Create a copy of AddressRequired
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressRequiredCopyWith<AddressRequired> get copyWith => _$AddressRequiredCopyWithImpl<AddressRequired>(this as AddressRequired, _$identity);

  /// Serializes this AddressRequired to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressRequired;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressRequired&&const DeepCollectionEquality().equals(other.delivery, _this.delivery)&&const DeepCollectionEquality().equals(other.invoice, _this.invoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressRequired;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.delivery),const DeepCollectionEquality().hash(_this.invoice));
}

@override
String toString() {
  final _this = this as AddressRequired;
  return 'AddressRequired(delivery: ${_this.delivery}, invoice: ${_this.invoice})';
}


}

/// @nodoc
abstract mixin class $AddressRequiredCopyWith<$Res>  {
  factory $AddressRequiredCopyWith(AddressRequired value, $Res Function(AddressRequired) _then) = _$AddressRequiredCopyWithImpl;
@useResult
$Res call({
 List<String> delivery, List<String> invoice
});




}
/// @nodoc
class _$AddressRequiredCopyWithImpl<$Res>
    implements $AddressRequiredCopyWith<$Res> {
  _$AddressRequiredCopyWithImpl(this._self, this._then);

  final AddressRequired _self;
  final $Res Function(AddressRequired) _then;

/// Create a copy of AddressRequired
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? delivery = null,Object? invoice = null,}) {
  return _then(AddressRequired(
delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as List<String>,invoice: null == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressRequired].
extension AddressRequiredPatterns on AddressRequired {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressRequired value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressRequired() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressRequired value)  $default,){
final _that = this;
switch (_that) {
case _AddressRequired():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressRequired value)?  $default,){
final _that = this;
switch (_that) {
case _AddressRequired() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> delivery,  List<String> invoice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressRequired() when $default != null:
return $default(_that.delivery,_that.invoice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> delivery,  List<String> invoice)  $default,) {final _that = this;
switch (_that) {
case _AddressRequired():
return $default(_that.delivery,_that.invoice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> delivery,  List<String> invoice)?  $default,) {final _that = this;
switch (_that) {
case _AddressRequired() when $default != null:
return $default(_that.delivery,_that.invoice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressRequired implements AddressRequired {
  const _AddressRequired({ List<String> delivery = const [],  List<String> invoice = const []}): _delivery = delivery,_invoice = invoice;
  factory _AddressRequired.fromJson(Map<String, dynamic> json) => _$AddressRequiredFromJson(json);

 final  List<String> _delivery;
@override@JsonKey() List<String> get delivery {
  if (_delivery is EqualUnmodifiableListView) return _delivery;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_delivery);
}

 final  List<String> _invoice;
@override@JsonKey() List<String> get invoice {
  if (_invoice is EqualUnmodifiableListView) return _invoice;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoice);
}


/// Create a copy of AddressRequired
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressRequiredCopyWith<_AddressRequired> get copyWith => __$AddressRequiredCopyWithImpl<_AddressRequired>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressRequiredToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressRequired&&const DeepCollectionEquality().equals(other.delivery, _delivery)&&const DeepCollectionEquality().equals(other.invoice, _invoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_delivery),const DeepCollectionEquality().hash(_invoice));
}

@override
String toString() {
    return 'AddressRequired(delivery: $delivery, invoice: $invoice)';
}


}

/// @nodoc
abstract mixin class _$AddressRequiredCopyWith<$Res> implements $AddressRequiredCopyWith<$Res> {
  factory _$AddressRequiredCopyWith(_AddressRequired value, $Res Function(_AddressRequired) _then) = __$AddressRequiredCopyWithImpl;
@override @useResult
$Res call({
 List<String> delivery, List<String> invoice
});




}
/// @nodoc
class __$AddressRequiredCopyWithImpl<$Res>
    implements _$AddressRequiredCopyWith<$Res> {
  __$AddressRequiredCopyWithImpl(this._self, this._then);

  final _AddressRequired _self;
  final $Res Function(_AddressRequired) _then;

/// Create a copy of AddressRequired
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? delivery = null,Object? invoice = null,}) {
  return _then(_AddressRequired(
delivery: null == delivery ? _self._delivery : delivery // ignore: cast_nullable_to_non_nullable
as List<String>,invoice: null == invoice ? _self._invoice : invoice // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$AddressOptions {

 List<AddressCountry> get countries;@JsonKey(name: 'default_country_id') int? get defaultCountryId; List<AddressState> get states; List<AddressCity> get cities; AddressRequired get required;/// Pe bazele clientului orasul e o inregistrare legata; pe altele e text liber.
/// Ecranul afiseaza o lista sau un camp de text dupa valoarea asta.
@JsonKey(name: 'city_is_list') bool get cityIsList;
/// Create a copy of AddressOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressOptionsCopyWith<AddressOptions> get copyWith => _$AddressOptionsCopyWithImpl<AddressOptions>(this as AddressOptions, _$identity);

  /// Serializes this AddressOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressOptions&&const DeepCollectionEquality().equals(other.countries, _this.countries)&&(identical(other.defaultCountryId, _this.defaultCountryId) || other.defaultCountryId == _this.defaultCountryId)&&const DeepCollectionEquality().equals(other.states, _this.states)&&const DeepCollectionEquality().equals(other.cities, _this.cities)&&(identical(other.required, _this.required) || other.required == _this.required)&&(identical(other.cityIsList, _this.cityIsList) || other.cityIsList == _this.cityIsList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressOptions;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.countries),_this.defaultCountryId,const DeepCollectionEquality().hash(_this.states),const DeepCollectionEquality().hash(_this.cities),_this.required,_this.cityIsList);
}

@override
String toString() {
  final _this = this as AddressOptions;
  return 'AddressOptions(countries: ${_this.countries}, defaultCountryId: ${_this.defaultCountryId}, states: ${_this.states}, cities: ${_this.cities}, required: ${_this.required}, cityIsList: ${_this.cityIsList})';
}


}

/// @nodoc
abstract mixin class $AddressOptionsCopyWith<$Res>  {
  factory $AddressOptionsCopyWith(AddressOptions value, $Res Function(AddressOptions) _then) = _$AddressOptionsCopyWithImpl;
@useResult
$Res call({
 List<AddressCountry> countries,@JsonKey(name: 'default_country_id') int? defaultCountryId, List<AddressState> states, List<AddressCity> cities, AddressRequired required,@JsonKey(name: 'city_is_list') bool cityIsList
});


$AddressRequiredCopyWith<$Res> get required;

}
/// @nodoc
class _$AddressOptionsCopyWithImpl<$Res>
    implements $AddressOptionsCopyWith<$Res> {
  _$AddressOptionsCopyWithImpl(this._self, this._then);

  final AddressOptions _self;
  final $Res Function(AddressOptions) _then;

/// Create a copy of AddressOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? countries = null,Object? defaultCountryId = freezed,Object? states = null,Object? cities = null,Object? required = null,Object? cityIsList = null,}) {
  return _then(AddressOptions(
countries: null == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<AddressCountry>,defaultCountryId: freezed == defaultCountryId ? _self.defaultCountryId : defaultCountryId // ignore: cast_nullable_to_non_nullable
as int?,states: null == states ? _self.states : states // ignore: cast_nullable_to_non_nullable
as List<AddressState>,cities: null == cities ? _self.cities : cities // ignore: cast_nullable_to_non_nullable
as List<AddressCity>,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as AddressRequired,cityIsList: null == cityIsList ? _self.cityIsList : cityIsList // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AddressOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressRequiredCopyWith<$Res> get required {
  
  return $AddressRequiredCopyWith<$Res>(_self.required, (value) {
    return _then(_self.copyWith(required: value));
  });
}
}


/// Adds pattern-matching-related methods to [AddressOptions].
extension AddressOptionsPatterns on AddressOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressOptions value)  $default,){
final _that = this;
switch (_that) {
case _AddressOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressOptions value)?  $default,){
final _that = this;
switch (_that) {
case _AddressOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AddressCountry> countries, @JsonKey(name: 'default_country_id')  int? defaultCountryId,  List<AddressState> states,  List<AddressCity> cities,  AddressRequired required, @JsonKey(name: 'city_is_list')  bool cityIsList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressOptions() when $default != null:
return $default(_that.countries,_that.defaultCountryId,_that.states,_that.cities,_that.required,_that.cityIsList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AddressCountry> countries, @JsonKey(name: 'default_country_id')  int? defaultCountryId,  List<AddressState> states,  List<AddressCity> cities,  AddressRequired required, @JsonKey(name: 'city_is_list')  bool cityIsList)  $default,) {final _that = this;
switch (_that) {
case _AddressOptions():
return $default(_that.countries,_that.defaultCountryId,_that.states,_that.cities,_that.required,_that.cityIsList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AddressCountry> countries, @JsonKey(name: 'default_country_id')  int? defaultCountryId,  List<AddressState> states,  List<AddressCity> cities,  AddressRequired required, @JsonKey(name: 'city_is_list')  bool cityIsList)?  $default,) {final _that = this;
switch (_that) {
case _AddressOptions() when $default != null:
return $default(_that.countries,_that.defaultCountryId,_that.states,_that.cities,_that.required,_that.cityIsList);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressOptions implements AddressOptions {
  const _AddressOptions({ List<AddressCountry> countries = const [], @JsonKey(name: 'default_country_id') this.defaultCountryId,  List<AddressState> states = const [],  List<AddressCity> cities = const [], required this.required, @JsonKey(name: 'city_is_list') this.cityIsList = false}): _countries = countries,_states = states,_cities = cities;
  factory _AddressOptions.fromJson(Map<String, dynamic> json) => _$AddressOptionsFromJson(json);

 final  List<AddressCountry> _countries;
@override@JsonKey() List<AddressCountry> get countries {
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countries);
}

@override@JsonKey(name: 'default_country_id') final  int? defaultCountryId;
 final  List<AddressState> _states;
@override@JsonKey() List<AddressState> get states {
  if (_states is EqualUnmodifiableListView) return _states;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_states);
}

 final  List<AddressCity> _cities;
@override@JsonKey() List<AddressCity> get cities {
  if (_cities is EqualUnmodifiableListView) return _cities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cities);
}

@override final  AddressRequired required;
/// Pe bazele clientului orasul e o inregistrare legata; pe altele e text liber.
/// Ecranul afiseaza o lista sau un camp de text dupa valoarea asta.
@override@JsonKey(name: 'city_is_list') final  bool cityIsList;

/// Create a copy of AddressOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressOptionsCopyWith<_AddressOptions> get copyWith => __$AddressOptionsCopyWithImpl<_AddressOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressOptions&&const DeepCollectionEquality().equals(other.countries, _countries)&&(identical(other.defaultCountryId, defaultCountryId) || other.defaultCountryId == defaultCountryId)&&const DeepCollectionEquality().equals(other.states, _states)&&const DeepCollectionEquality().equals(other.cities, _cities)&&(identical(other.required, required) || other.required == required)&&(identical(other.cityIsList, cityIsList) || other.cityIsList == cityIsList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_countries),defaultCountryId,const DeepCollectionEquality().hash(_states),const DeepCollectionEquality().hash(_cities),required,cityIsList);
}

@override
String toString() {
    return 'AddressOptions(countries: $countries, defaultCountryId: $defaultCountryId, states: $states, cities: $cities, required: $required, cityIsList: $cityIsList)';
}


}

/// @nodoc
abstract mixin class _$AddressOptionsCopyWith<$Res> implements $AddressOptionsCopyWith<$Res> {
  factory _$AddressOptionsCopyWith(_AddressOptions value, $Res Function(_AddressOptions) _then) = __$AddressOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<AddressCountry> countries,@JsonKey(name: 'default_country_id') int? defaultCountryId, List<AddressState> states, List<AddressCity> cities, AddressRequired required,@JsonKey(name: 'city_is_list') bool cityIsList
});


@override $AddressRequiredCopyWith<$Res> get required;

}
/// @nodoc
class __$AddressOptionsCopyWithImpl<$Res>
    implements _$AddressOptionsCopyWith<$Res> {
  __$AddressOptionsCopyWithImpl(this._self, this._then);

  final _AddressOptions _self;
  final $Res Function(_AddressOptions) _then;

/// Create a copy of AddressOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? countries = null,Object? defaultCountryId = freezed,Object? states = null,Object? cities = null,Object? required = null,Object? cityIsList = null,}) {
  return _then(_AddressOptions(
countries: null == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<AddressCountry>,defaultCountryId: freezed == defaultCountryId ? _self.defaultCountryId : defaultCountryId // ignore: cast_nullable_to_non_nullable
as int?,states: null == states ? _self._states : states // ignore: cast_nullable_to_non_nullable
as List<AddressState>,cities: null == cities ? _self._cities : cities // ignore: cast_nullable_to_non_nullable
as List<AddressCity>,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as AddressRequired,cityIsList: null == cityIsList ? _self.cityIsList : cityIsList // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AddressOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressRequiredCopyWith<$Res> get required {
  
  return $AddressRequiredCopyWith<$Res>(_self.required, (value) {
    return _then(_self.copyWith(required: value));
  });
}
}

// dart format on

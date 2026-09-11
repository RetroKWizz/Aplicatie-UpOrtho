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


/// @nodoc
mixin _$AddressFormValues {

 int get id; String get kind; String? get name; String? get street; String? get street2; String? get city;@JsonKey(name: 'city_id') int? get cityId; String? get zip;@JsonKey(name: 'state_id') int? get stateId;@JsonKey(name: 'country_id') int? get countryId; String? get phone; String? get email; String? get vat;@JsonKey(name: 'company_name') String? get companyName;@JsonKey(name: 'can_edit_name') bool get canEditName;@JsonKey(name: 'can_edit_vat') bool get canEditVat;
/// Create a copy of AddressFormValues
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressFormValuesCopyWith<AddressFormValues> get copyWith => _$AddressFormValuesCopyWithImpl<AddressFormValues>(this as AddressFormValues, _$identity);

  /// Serializes this AddressFormValues to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddressFormValues;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressFormValues&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.street2, _this.street2) || other.street2 == _this.street2)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.cityId, _this.cityId) || other.cityId == _this.cityId)&&(identical(other.zip, _this.zip) || other.zip == _this.zip)&&(identical(other.stateId, _this.stateId) || other.stateId == _this.stateId)&&(identical(other.countryId, _this.countryId) || other.countryId == _this.countryId)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.vat, _this.vat) || other.vat == _this.vat)&&(identical(other.companyName, _this.companyName) || other.companyName == _this.companyName)&&(identical(other.canEditName, _this.canEditName) || other.canEditName == _this.canEditName)&&(identical(other.canEditVat, _this.canEditVat) || other.canEditVat == _this.canEditVat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddressFormValues;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.name,_this.street,_this.street2,_this.city,_this.cityId,_this.zip,_this.stateId,_this.countryId,_this.phone,_this.email,_this.vat,_this.companyName,_this.canEditName,_this.canEditVat);
}

@override
String toString() {
  final _this = this as AddressFormValues;
  return 'AddressFormValues(id: ${_this.id}, kind: ${_this.kind}, name: ${_this.name}, street: ${_this.street}, street2: ${_this.street2}, city: ${_this.city}, cityId: ${_this.cityId}, zip: ${_this.zip}, stateId: ${_this.stateId}, countryId: ${_this.countryId}, phone: ${_this.phone}, email: ${_this.email}, vat: ${_this.vat}, companyName: ${_this.companyName}, canEditName: ${_this.canEditName}, canEditVat: ${_this.canEditVat})';
}


}

/// @nodoc
abstract mixin class $AddressFormValuesCopyWith<$Res>  {
  factory $AddressFormValuesCopyWith(AddressFormValues value, $Res Function(AddressFormValues) _then) = _$AddressFormValuesCopyWithImpl;
@useResult
$Res call({
 int id, String kind, String? name, String? street, String? street2, String? city,@JsonKey(name: 'city_id') int? cityId, String? zip,@JsonKey(name: 'state_id') int? stateId,@JsonKey(name: 'country_id') int? countryId, String? phone, String? email, String? vat,@JsonKey(name: 'company_name') String? companyName,@JsonKey(name: 'can_edit_name') bool canEditName,@JsonKey(name: 'can_edit_vat') bool canEditVat
});




}
/// @nodoc
class _$AddressFormValuesCopyWithImpl<$Res>
    implements $AddressFormValuesCopyWith<$Res> {
  _$AddressFormValuesCopyWithImpl(this._self, this._then);

  final AddressFormValues _self;
  final $Res Function(AddressFormValues) _then;

/// Create a copy of AddressFormValues
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? name = freezed,Object? street = freezed,Object? street2 = freezed,Object? city = freezed,Object? cityId = freezed,Object? zip = freezed,Object? stateId = freezed,Object? countryId = freezed,Object? phone = freezed,Object? email = freezed,Object? vat = freezed,Object? companyName = freezed,Object? canEditName = null,Object? canEditVat = null,}) {
  return _then(AddressFormValues(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,street2: freezed == street2 ? _self.street2 : street2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as int?,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as int?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,canEditName: null == canEditName ? _self.canEditName : canEditName // ignore: cast_nullable_to_non_nullable
as bool,canEditVat: null == canEditVat ? _self.canEditVat : canEditVat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressFormValues].
extension AddressFormValuesPatterns on AddressFormValues {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressFormValues value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressFormValues() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressFormValues value)  $default,){
final _that = this;
switch (_that) {
case _AddressFormValues():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressFormValues value)?  $default,){
final _that = this;
switch (_that) {
case _AddressFormValues() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String kind,  String? name,  String? street,  String? street2,  String? city, @JsonKey(name: 'city_id')  int? cityId,  String? zip, @JsonKey(name: 'state_id')  int? stateId, @JsonKey(name: 'country_id')  int? countryId,  String? phone,  String? email,  String? vat, @JsonKey(name: 'company_name')  String? companyName, @JsonKey(name: 'can_edit_name')  bool canEditName, @JsonKey(name: 'can_edit_vat')  bool canEditVat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressFormValues() when $default != null:
return $default(_that.id,_that.kind,_that.name,_that.street,_that.street2,_that.city,_that.cityId,_that.zip,_that.stateId,_that.countryId,_that.phone,_that.email,_that.vat,_that.companyName,_that.canEditName,_that.canEditVat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String kind,  String? name,  String? street,  String? street2,  String? city, @JsonKey(name: 'city_id')  int? cityId,  String? zip, @JsonKey(name: 'state_id')  int? stateId, @JsonKey(name: 'country_id')  int? countryId,  String? phone,  String? email,  String? vat, @JsonKey(name: 'company_name')  String? companyName, @JsonKey(name: 'can_edit_name')  bool canEditName, @JsonKey(name: 'can_edit_vat')  bool canEditVat)  $default,) {final _that = this;
switch (_that) {
case _AddressFormValues():
return $default(_that.id,_that.kind,_that.name,_that.street,_that.street2,_that.city,_that.cityId,_that.zip,_that.stateId,_that.countryId,_that.phone,_that.email,_that.vat,_that.companyName,_that.canEditName,_that.canEditVat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String kind,  String? name,  String? street,  String? street2,  String? city, @JsonKey(name: 'city_id')  int? cityId,  String? zip, @JsonKey(name: 'state_id')  int? stateId, @JsonKey(name: 'country_id')  int? countryId,  String? phone,  String? email,  String? vat, @JsonKey(name: 'company_name')  String? companyName, @JsonKey(name: 'can_edit_name')  bool canEditName, @JsonKey(name: 'can_edit_vat')  bool canEditVat)?  $default,) {final _that = this;
switch (_that) {
case _AddressFormValues() when $default != null:
return $default(_that.id,_that.kind,_that.name,_that.street,_that.street2,_that.city,_that.cityId,_that.zip,_that.stateId,_that.countryId,_that.phone,_that.email,_that.vat,_that.companyName,_that.canEditName,_that.canEditVat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressFormValues implements AddressFormValues {
  const _AddressFormValues({required this.id, required this.kind, this.name, this.street, this.street2, this.city, @JsonKey(name: 'city_id') this.cityId, this.zip, @JsonKey(name: 'state_id') this.stateId, @JsonKey(name: 'country_id') this.countryId, this.phone, this.email, this.vat, @JsonKey(name: 'company_name') this.companyName, @JsonKey(name: 'can_edit_name') this.canEditName = true, @JsonKey(name: 'can_edit_vat') this.canEditVat = true});
  factory _AddressFormValues.fromJson(Map<String, dynamic> json) => _$AddressFormValuesFromJson(json);

@override final  int id;
@override final  String kind;
@override final  String? name;
@override final  String? street;
@override final  String? street2;
@override final  String? city;
@override@JsonKey(name: 'city_id') final  int? cityId;
@override final  String? zip;
@override@JsonKey(name: 'state_id') final  int? stateId;
@override@JsonKey(name: 'country_id') final  int? countryId;
@override final  String? phone;
@override final  String? email;
@override final  String? vat;
@override@JsonKey(name: 'company_name') final  String? companyName;
@override@JsonKey(name: 'can_edit_name') final  bool canEditName;
@override@JsonKey(name: 'can_edit_vat') final  bool canEditVat;

/// Create a copy of AddressFormValues
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressFormValuesCopyWith<_AddressFormValues> get copyWith => __$AddressFormValuesCopyWithImpl<_AddressFormValues>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressFormValuesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressFormValues&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.name, name) || other.name == name)&&(identical(other.street, street) || other.street == street)&&(identical(other.street2, street2) || other.street2 == street2)&&(identical(other.city, city) || other.city == city)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.stateId, stateId) || other.stateId == stateId)&&(identical(other.countryId, countryId) || other.countryId == countryId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.canEditName, canEditName) || other.canEditName == canEditName)&&(identical(other.canEditVat, canEditVat) || other.canEditVat == canEditVat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,name,street,street2,city,cityId,zip,stateId,countryId,phone,email,vat,companyName,canEditName,canEditVat);
}

@override
String toString() {
    return 'AddressFormValues(id: $id, kind: $kind, name: $name, street: $street, street2: $street2, city: $city, cityId: $cityId, zip: $zip, stateId: $stateId, countryId: $countryId, phone: $phone, email: $email, vat: $vat, companyName: $companyName, canEditName: $canEditName, canEditVat: $canEditVat)';
}


}

/// @nodoc
abstract mixin class _$AddressFormValuesCopyWith<$Res> implements $AddressFormValuesCopyWith<$Res> {
  factory _$AddressFormValuesCopyWith(_AddressFormValues value, $Res Function(_AddressFormValues) _then) = __$AddressFormValuesCopyWithImpl;
@override @useResult
$Res call({
 int id, String kind, String? name, String? street, String? street2, String? city,@JsonKey(name: 'city_id') int? cityId, String? zip,@JsonKey(name: 'state_id') int? stateId,@JsonKey(name: 'country_id') int? countryId, String? phone, String? email, String? vat,@JsonKey(name: 'company_name') String? companyName,@JsonKey(name: 'can_edit_name') bool canEditName,@JsonKey(name: 'can_edit_vat') bool canEditVat
});




}
/// @nodoc
class __$AddressFormValuesCopyWithImpl<$Res>
    implements _$AddressFormValuesCopyWith<$Res> {
  __$AddressFormValuesCopyWithImpl(this._self, this._then);

  final _AddressFormValues _self;
  final $Res Function(_AddressFormValues) _then;

/// Create a copy of AddressFormValues
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? name = freezed,Object? street = freezed,Object? street2 = freezed,Object? city = freezed,Object? cityId = freezed,Object? zip = freezed,Object? stateId = freezed,Object? countryId = freezed,Object? phone = freezed,Object? email = freezed,Object? vat = freezed,Object? companyName = freezed,Object? canEditName = null,Object? canEditVat = null,}) {
  return _then(_AddressFormValues(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,street2: freezed == street2 ? _self.street2 : street2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as int?,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as int?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,canEditName: null == canEditName ? _self.canEditName : canEditName // ignore: cast_nullable_to_non_nullable
as bool,canEditVat: null == canEditVat ? _self.canEditVat : canEditVat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

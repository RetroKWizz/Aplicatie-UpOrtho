// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VariantValue {

 int get id; String get name; bool get selected; bool get available;/// Combinatia completa de trimis serverului (`?values=`) cand se apasa pe
/// aceasta valoare. Vine gata compusa de la server: aplicatia are in ecran doar
/// id-ul valorii apasate si nu are cum sa deduca restul combinatiei.
 List<int> get combination;
/// Create a copy of VariantValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantValueCopyWith<VariantValue> get copyWith => _$VariantValueCopyWithImpl<VariantValue>(this as VariantValue, _$identity);

  /// Serializes this VariantValue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VariantValue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantValue&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.selected, _this.selected) || other.selected == _this.selected)&&(identical(other.available, _this.available) || other.available == _this.available)&&const DeepCollectionEquality().equals(other.combination, _this.combination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VariantValue;
  return Object.hash(runtimeType,_this.id,_this.name,_this.selected,_this.available,const DeepCollectionEquality().hash(_this.combination));
}

@override
String toString() {
  final _this = this as VariantValue;
  return 'VariantValue(id: ${_this.id}, name: ${_this.name}, selected: ${_this.selected}, available: ${_this.available}, combination: ${_this.combination})';
}


}

/// @nodoc
abstract mixin class $VariantValueCopyWith<$Res>  {
  factory $VariantValueCopyWith(VariantValue value, $Res Function(VariantValue) _then) = _$VariantValueCopyWithImpl;
@useResult
$Res call({
 int id, String name, bool selected, bool available, List<int> combination
});




}
/// @nodoc
class _$VariantValueCopyWithImpl<$Res>
    implements $VariantValueCopyWith<$Res> {
  _$VariantValueCopyWithImpl(this._self, this._then);

  final VariantValue _self;
  final $Res Function(VariantValue) _then;

/// Create a copy of VariantValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? selected = null,Object? available = null,Object? combination = null,}) {
  return _then(VariantValue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,combination: null == combination ? _self.combination : combination // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [VariantValue].
extension VariantValuePatterns on VariantValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantValue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantValue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantValue value)  $default,){
final _that = this;
switch (_that) {
case _VariantValue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantValue value)?  $default,){
final _that = this;
switch (_that) {
case _VariantValue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  bool selected,  bool available,  List<int> combination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantValue() when $default != null:
return $default(_that.id,_that.name,_that.selected,_that.available,_that.combination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  bool selected,  bool available,  List<int> combination)  $default,) {final _that = this;
switch (_that) {
case _VariantValue():
return $default(_that.id,_that.name,_that.selected,_that.available,_that.combination);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  bool selected,  bool available,  List<int> combination)?  $default,) {final _that = this;
switch (_that) {
case _VariantValue() when $default != null:
return $default(_that.id,_that.name,_that.selected,_that.available,_that.combination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantValue implements VariantValue {
  const _VariantValue({required this.id, required this.name, this.selected = false, this.available = true,  List<int> combination = const []}): _combination = combination;
  factory _VariantValue.fromJson(Map<String, dynamic> json) => _$VariantValueFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey() final  bool selected;
@override@JsonKey() final  bool available;
/// Combinatia completa de trimis serverului (`?values=`) cand se apasa pe
/// aceasta valoare. Vine gata compusa de la server: aplicatia are in ecran doar
/// id-ul valorii apasate si nu are cum sa deduca restul combinatiei.
 final  List<int> _combination;
/// Combinatia completa de trimis serverului (`?values=`) cand se apasa pe
/// aceasta valoare. Vine gata compusa de la server: aplicatia are in ecran doar
/// id-ul valorii apasate si nu are cum sa deduca restul combinatiei.
@override@JsonKey() List<int> get combination {
  if (_combination is EqualUnmodifiableListView) return _combination;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_combination);
}


/// Create a copy of VariantValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantValueCopyWith<_VariantValue> get copyWith => __$VariantValueCopyWithImpl<_VariantValue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantValueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantValue&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.available, available) || other.available == available)&&const DeepCollectionEquality().equals(other.combination, _combination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,selected,available,const DeepCollectionEquality().hash(_combination));
}

@override
String toString() {
    return 'VariantValue(id: $id, name: $name, selected: $selected, available: $available, combination: $combination)';
}


}

/// @nodoc
abstract mixin class _$VariantValueCopyWith<$Res> implements $VariantValueCopyWith<$Res> {
  factory _$VariantValueCopyWith(_VariantValue value, $Res Function(_VariantValue) _then) = __$VariantValueCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, bool selected, bool available, List<int> combination
});




}
/// @nodoc
class __$VariantValueCopyWithImpl<$Res>
    implements _$VariantValueCopyWith<$Res> {
  __$VariantValueCopyWithImpl(this._self, this._then);

  final _VariantValue _self;
  final $Res Function(_VariantValue) _then;

/// Create a copy of VariantValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? selected = null,Object? available = null,Object? combination = null,}) {
  return _then(_VariantValue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,combination: null == combination ? _self._combination : combination // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$VariantAttribute {

 int get id; String get name; List<VariantValue> get values;
/// Create a copy of VariantAttribute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantAttributeCopyWith<VariantAttribute> get copyWith => _$VariantAttributeCopyWithImpl<VariantAttribute>(this as VariantAttribute, _$identity);

  /// Serializes this VariantAttribute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VariantAttribute;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantAttribute&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.values, _this.values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VariantAttribute;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.values));
}

@override
String toString() {
  final _this = this as VariantAttribute;
  return 'VariantAttribute(id: ${_this.id}, name: ${_this.name}, values: ${_this.values})';
}


}

/// @nodoc
abstract mixin class $VariantAttributeCopyWith<$Res>  {
  factory $VariantAttributeCopyWith(VariantAttribute value, $Res Function(VariantAttribute) _then) = _$VariantAttributeCopyWithImpl;
@useResult
$Res call({
 int id, String name, List<VariantValue> values
});




}
/// @nodoc
class _$VariantAttributeCopyWithImpl<$Res>
    implements $VariantAttributeCopyWith<$Res> {
  _$VariantAttributeCopyWithImpl(this._self, this._then);

  final VariantAttribute _self;
  final $Res Function(VariantAttribute) _then;

/// Create a copy of VariantAttribute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? values = null,}) {
  return _then(VariantAttribute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<VariantValue>,
  ));
}

}


/// Adds pattern-matching-related methods to [VariantAttribute].
extension VariantAttributePatterns on VariantAttribute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantAttribute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantAttribute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantAttribute value)  $default,){
final _that = this;
switch (_that) {
case _VariantAttribute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantAttribute value)?  $default,){
final _that = this;
switch (_that) {
case _VariantAttribute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  List<VariantValue> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantAttribute() when $default != null:
return $default(_that.id,_that.name,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  List<VariantValue> values)  $default,) {final _that = this;
switch (_that) {
case _VariantAttribute():
return $default(_that.id,_that.name,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  List<VariantValue> values)?  $default,) {final _that = this;
switch (_that) {
case _VariantAttribute() when $default != null:
return $default(_that.id,_that.name,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantAttribute implements VariantAttribute {
  const _VariantAttribute({required this.id, required this.name,  List<VariantValue> values = const []}): _values = values;
  factory _VariantAttribute.fromJson(Map<String, dynamic> json) => _$VariantAttributeFromJson(json);

@override final  int id;
@override final  String name;
 final  List<VariantValue> _values;
@override@JsonKey() List<VariantValue> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of VariantAttribute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantAttributeCopyWith<_VariantAttribute> get copyWith => __$VariantAttributeCopyWithImpl<_VariantAttribute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantAttributeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantAttribute&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_values));
}

@override
String toString() {
    return 'VariantAttribute(id: $id, name: $name, values: $values)';
}


}

/// @nodoc
abstract mixin class _$VariantAttributeCopyWith<$Res> implements $VariantAttributeCopyWith<$Res> {
  factory _$VariantAttributeCopyWith(_VariantAttribute value, $Res Function(_VariantAttribute) _then) = __$VariantAttributeCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, List<VariantValue> values
});




}
/// @nodoc
class __$VariantAttributeCopyWithImpl<$Res>
    implements _$VariantAttributeCopyWith<$Res> {
  __$VariantAttributeCopyWithImpl(this._self, this._then);

  final _VariantAttribute _self;
  final $Res Function(_VariantAttribute) _then;

/// Create a copy of VariantAttribute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? values = null,}) {
  return _then(_VariantAttribute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<VariantValue>,
  ));
}


}


/// @nodoc
mixin _$VariantOptions {

/// Combinatia activa acum, asa cum a rezolvat-o serverul. Ecranul o poate folosi
/// ca sa arate din nou selectia dupa o re-cerere, fara sa o deduca.
 List<int> get selected; List<VariantAttribute> get attributes;
/// Create a copy of VariantOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantOptionsCopyWith<VariantOptions> get copyWith => _$VariantOptionsCopyWithImpl<VariantOptions>(this as VariantOptions, _$identity);

  /// Serializes this VariantOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VariantOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantOptions&&const DeepCollectionEquality().equals(other.selected, _this.selected)&&const DeepCollectionEquality().equals(other.attributes, _this.attributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VariantOptions;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.selected),const DeepCollectionEquality().hash(_this.attributes));
}

@override
String toString() {
  final _this = this as VariantOptions;
  return 'VariantOptions(selected: ${_this.selected}, attributes: ${_this.attributes})';
}


}

/// @nodoc
abstract mixin class $VariantOptionsCopyWith<$Res>  {
  factory $VariantOptionsCopyWith(VariantOptions value, $Res Function(VariantOptions) _then) = _$VariantOptionsCopyWithImpl;
@useResult
$Res call({
 List<int> selected, List<VariantAttribute> attributes
});




}
/// @nodoc
class _$VariantOptionsCopyWithImpl<$Res>
    implements $VariantOptionsCopyWith<$Res> {
  _$VariantOptionsCopyWithImpl(this._self, this._then);

  final VariantOptions _self;
  final $Res Function(VariantOptions) _then;

/// Create a copy of VariantOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selected = null,Object? attributes = null,}) {
  return _then(VariantOptions(
selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as List<int>,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as List<VariantAttribute>,
  ));
}

}


/// Adds pattern-matching-related methods to [VariantOptions].
extension VariantOptionsPatterns on VariantOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantOptions value)  $default,){
final _that = this;
switch (_that) {
case _VariantOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantOptions value)?  $default,){
final _that = this;
switch (_that) {
case _VariantOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> selected,  List<VariantAttribute> attributes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantOptions() when $default != null:
return $default(_that.selected,_that.attributes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> selected,  List<VariantAttribute> attributes)  $default,) {final _that = this;
switch (_that) {
case _VariantOptions():
return $default(_that.selected,_that.attributes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> selected,  List<VariantAttribute> attributes)?  $default,) {final _that = this;
switch (_that) {
case _VariantOptions() when $default != null:
return $default(_that.selected,_that.attributes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantOptions implements VariantOptions {
  const _VariantOptions({ List<int> selected = const [],  List<VariantAttribute> attributes = const []}): _selected = selected,_attributes = attributes;
  factory _VariantOptions.fromJson(Map<String, dynamic> json) => _$VariantOptionsFromJson(json);

/// Combinatia activa acum, asa cum a rezolvat-o serverul. Ecranul o poate folosi
/// ca sa arate din nou selectia dupa o re-cerere, fara sa o deduca.
 final  List<int> _selected;
/// Combinatia activa acum, asa cum a rezolvat-o serverul. Ecranul o poate folosi
/// ca sa arate din nou selectia dupa o re-cerere, fara sa o deduca.
@override@JsonKey() List<int> get selected {
  if (_selected is EqualUnmodifiableListView) return _selected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selected);
}

 final  List<VariantAttribute> _attributes;
@override@JsonKey() List<VariantAttribute> get attributes {
  if (_attributes is EqualUnmodifiableListView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attributes);
}


/// Create a copy of VariantOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantOptionsCopyWith<_VariantOptions> get copyWith => __$VariantOptionsCopyWithImpl<_VariantOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantOptions&&const DeepCollectionEquality().equals(other.selected, _selected)&&const DeepCollectionEquality().equals(other.attributes, _attributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_selected),const DeepCollectionEquality().hash(_attributes));
}

@override
String toString() {
    return 'VariantOptions(selected: $selected, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class _$VariantOptionsCopyWith<$Res> implements $VariantOptionsCopyWith<$Res> {
  factory _$VariantOptionsCopyWith(_VariantOptions value, $Res Function(_VariantOptions) _then) = __$VariantOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<int> selected, List<VariantAttribute> attributes
});




}
/// @nodoc
class __$VariantOptionsCopyWithImpl<$Res>
    implements _$VariantOptionsCopyWith<$Res> {
  __$VariantOptionsCopyWithImpl(this._self, this._then);

  final _VariantOptions _self;
  final $Res Function(_VariantOptions) _then;

/// Create a copy of VariantOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selected = null,Object? attributes = null,}) {
  return _then(_VariantOptions(
selected: null == selected ? _self._selected : selected // ignore: cast_nullable_to_non_nullable
as List<int>,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as List<VariantAttribute>,
  ));
}


}

// dart format on

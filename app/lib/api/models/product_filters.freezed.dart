// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttributeFilterValue {

 int get id; String get name;/// Culoarea valorii, cand atributul e de tip culoare (hexazecimal, de la server).
 String? get color; int get count; bool get selected;
/// Create a copy of AttributeFilterValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttributeFilterValueCopyWith<AttributeFilterValue> get copyWith => _$AttributeFilterValueCopyWithImpl<AttributeFilterValue>(this as AttributeFilterValue, _$identity);

  /// Serializes this AttributeFilterValue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttributeFilterValue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttributeFilterValue&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.selected, _this.selected) || other.selected == _this.selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttributeFilterValue;
  return Object.hash(runtimeType,_this.id,_this.name,_this.color,_this.count,_this.selected);
}

@override
String toString() {
  final _this = this as AttributeFilterValue;
  return 'AttributeFilterValue(id: ${_this.id}, name: ${_this.name}, color: ${_this.color}, count: ${_this.count}, selected: ${_this.selected})';
}


}

/// @nodoc
abstract mixin class $AttributeFilterValueCopyWith<$Res>  {
  factory $AttributeFilterValueCopyWith(AttributeFilterValue value, $Res Function(AttributeFilterValue) _then) = _$AttributeFilterValueCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? color, int count, bool selected
});




}
/// @nodoc
class _$AttributeFilterValueCopyWithImpl<$Res>
    implements $AttributeFilterValueCopyWith<$Res> {
  _$AttributeFilterValueCopyWithImpl(this._self, this._then);

  final AttributeFilterValue _self;
  final $Res Function(AttributeFilterValue) _then;

/// Create a copy of AttributeFilterValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? count = null,Object? selected = null,}) {
  return _then(AttributeFilterValue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AttributeFilterValue].
extension AttributeFilterValuePatterns on AttributeFilterValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttributeFilterValue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttributeFilterValue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttributeFilterValue value)  $default,){
final _that = this;
switch (_that) {
case _AttributeFilterValue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttributeFilterValue value)?  $default,){
final _that = this;
switch (_that) {
case _AttributeFilterValue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? color,  int count,  bool selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttributeFilterValue() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.count,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? color,  int count,  bool selected)  $default,) {final _that = this;
switch (_that) {
case _AttributeFilterValue():
return $default(_that.id,_that.name,_that.color,_that.count,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? color,  int count,  bool selected)?  $default,) {final _that = this;
switch (_that) {
case _AttributeFilterValue() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.count,_that.selected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttributeFilterValue implements AttributeFilterValue {
  const _AttributeFilterValue({required this.id, required this.name, this.color, this.count = 0, this.selected = false});
  factory _AttributeFilterValue.fromJson(Map<String, dynamic> json) => _$AttributeFilterValueFromJson(json);

@override final  int id;
@override final  String name;
/// Culoarea valorii, cand atributul e de tip culoare (hexazecimal, de la server).
@override final  String? color;
@override@JsonKey() final  int count;
@override@JsonKey() final  bool selected;

/// Create a copy of AttributeFilterValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttributeFilterValueCopyWith<_AttributeFilterValue> get copyWith => __$AttributeFilterValueCopyWithImpl<_AttributeFilterValue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttributeFilterValueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttributeFilterValue&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.count, count) || other.count == count)&&(identical(other.selected, selected) || other.selected == selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,color,count,selected);
}

@override
String toString() {
    return 'AttributeFilterValue(id: $id, name: $name, color: $color, count: $count, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$AttributeFilterValueCopyWith<$Res> implements $AttributeFilterValueCopyWith<$Res> {
  factory _$AttributeFilterValueCopyWith(_AttributeFilterValue value, $Res Function(_AttributeFilterValue) _then) = __$AttributeFilterValueCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? color, int count, bool selected
});




}
/// @nodoc
class __$AttributeFilterValueCopyWithImpl<$Res>
    implements _$AttributeFilterValueCopyWith<$Res> {
  __$AttributeFilterValueCopyWithImpl(this._self, this._then);

  final _AttributeFilterValue _self;
  final $Res Function(_AttributeFilterValue) _then;

/// Create a copy of AttributeFilterValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? count = null,Object? selected = null,}) {
  return _then(_AttributeFilterValue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AttributeFilter {

 int get id; String get name;/// Cum il deseneaza magazinul (`radio`, `select`, `color`, `pills`...). Serveste
/// doar ca indiciu de prezentare; o valoare necunoscuta se deseneaza ca lista.
@JsonKey(name: 'display_type') String? get displayType; List<AttributeFilterValue> get values;
/// Create a copy of AttributeFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttributeFilterCopyWith<AttributeFilter> get copyWith => _$AttributeFilterCopyWithImpl<AttributeFilter>(this as AttributeFilter, _$identity);

  /// Serializes this AttributeFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttributeFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttributeFilter&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.displayType, _this.displayType) || other.displayType == _this.displayType)&&const DeepCollectionEquality().equals(other.values, _this.values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttributeFilter;
  return Object.hash(runtimeType,_this.id,_this.name,_this.displayType,const DeepCollectionEquality().hash(_this.values));
}

@override
String toString() {
  final _this = this as AttributeFilter;
  return 'AttributeFilter(id: ${_this.id}, name: ${_this.name}, displayType: ${_this.displayType}, values: ${_this.values})';
}


}

/// @nodoc
abstract mixin class $AttributeFilterCopyWith<$Res>  {
  factory $AttributeFilterCopyWith(AttributeFilter value, $Res Function(AttributeFilter) _then) = _$AttributeFilterCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'display_type') String? displayType, List<AttributeFilterValue> values
});




}
/// @nodoc
class _$AttributeFilterCopyWithImpl<$Res>
    implements $AttributeFilterCopyWith<$Res> {
  _$AttributeFilterCopyWithImpl(this._self, this._then);

  final AttributeFilter _self;
  final $Res Function(AttributeFilter) _then;

/// Create a copy of AttributeFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? displayType = freezed,Object? values = null,}) {
  return _then(AttributeFilter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayType: freezed == displayType ? _self.displayType : displayType // ignore: cast_nullable_to_non_nullable
as String?,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<AttributeFilterValue>,
  ));
}

}


/// Adds pattern-matching-related methods to [AttributeFilter].
extension AttributeFilterPatterns on AttributeFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttributeFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttributeFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttributeFilter value)  $default,){
final _that = this;
switch (_that) {
case _AttributeFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttributeFilter value)?  $default,){
final _that = this;
switch (_that) {
case _AttributeFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'display_type')  String? displayType,  List<AttributeFilterValue> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttributeFilter() when $default != null:
return $default(_that.id,_that.name,_that.displayType,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'display_type')  String? displayType,  List<AttributeFilterValue> values)  $default,) {final _that = this;
switch (_that) {
case _AttributeFilter():
return $default(_that.id,_that.name,_that.displayType,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'display_type')  String? displayType,  List<AttributeFilterValue> values)?  $default,) {final _that = this;
switch (_that) {
case _AttributeFilter() when $default != null:
return $default(_that.id,_that.name,_that.displayType,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttributeFilter implements AttributeFilter {
  const _AttributeFilter({required this.id, required this.name, @JsonKey(name: 'display_type') this.displayType,  List<AttributeFilterValue> values = const []}): _values = values;
  factory _AttributeFilter.fromJson(Map<String, dynamic> json) => _$AttributeFilterFromJson(json);

@override final  int id;
@override final  String name;
/// Cum il deseneaza magazinul (`radio`, `select`, `color`, `pills`...). Serveste
/// doar ca indiciu de prezentare; o valoare necunoscuta se deseneaza ca lista.
@override@JsonKey(name: 'display_type') final  String? displayType;
 final  List<AttributeFilterValue> _values;
@override@JsonKey() List<AttributeFilterValue> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of AttributeFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttributeFilterCopyWith<_AttributeFilter> get copyWith => __$AttributeFilterCopyWithImpl<_AttributeFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttributeFilterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttributeFilter&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayType, displayType) || other.displayType == displayType)&&const DeepCollectionEquality().equals(other.values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,displayType,const DeepCollectionEquality().hash(_values));
}

@override
String toString() {
    return 'AttributeFilter(id: $id, name: $name, displayType: $displayType, values: $values)';
}


}

/// @nodoc
abstract mixin class _$AttributeFilterCopyWith<$Res> implements $AttributeFilterCopyWith<$Res> {
  factory _$AttributeFilterCopyWith(_AttributeFilter value, $Res Function(_AttributeFilter) _then) = __$AttributeFilterCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'display_type') String? displayType, List<AttributeFilterValue> values
});




}
/// @nodoc
class __$AttributeFilterCopyWithImpl<$Res>
    implements _$AttributeFilterCopyWith<$Res> {
  __$AttributeFilterCopyWithImpl(this._self, this._then);

  final _AttributeFilter _self;
  final $Res Function(_AttributeFilter) _then;

/// Create a copy of AttributeFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? displayType = freezed,Object? values = null,}) {
  return _then(_AttributeFilter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayType: freezed == displayType ? _self.displayType : displayType // ignore: cast_nullable_to_non_nullable
as String?,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<AttributeFilterValue>,
  ));
}


}


/// @nodoc
mixin _$PriceFilter {

 double get min; double get max;@JsonKey(name: 'selected_min') double? get selectedMin;@JsonKey(name: 'selected_max') double? get selectedMax;
/// Create a copy of PriceFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceFilterCopyWith<PriceFilter> get copyWith => _$PriceFilterCopyWithImpl<PriceFilter>(this as PriceFilter, _$identity);

  /// Serializes this PriceFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceFilter&&(identical(other.min, _this.min) || other.min == _this.min)&&(identical(other.max, _this.max) || other.max == _this.max)&&(identical(other.selectedMin, _this.selectedMin) || other.selectedMin == _this.selectedMin)&&(identical(other.selectedMax, _this.selectedMax) || other.selectedMax == _this.selectedMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceFilter;
  return Object.hash(runtimeType,_this.min,_this.max,_this.selectedMin,_this.selectedMax);
}

@override
String toString() {
  final _this = this as PriceFilter;
  return 'PriceFilter(min: ${_this.min}, max: ${_this.max}, selectedMin: ${_this.selectedMin}, selectedMax: ${_this.selectedMax})';
}


}

/// @nodoc
abstract mixin class $PriceFilterCopyWith<$Res>  {
  factory $PriceFilterCopyWith(PriceFilter value, $Res Function(PriceFilter) _then) = _$PriceFilterCopyWithImpl;
@useResult
$Res call({
 double min, double max,@JsonKey(name: 'selected_min') double? selectedMin,@JsonKey(name: 'selected_max') double? selectedMax
});




}
/// @nodoc
class _$PriceFilterCopyWithImpl<$Res>
    implements $PriceFilterCopyWith<$Res> {
  _$PriceFilterCopyWithImpl(this._self, this._then);

  final PriceFilter _self;
  final $Res Function(PriceFilter) _then;

/// Create a copy of PriceFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,Object? selectedMin = freezed,Object? selectedMax = freezed,}) {
  return _then(PriceFilter(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,selectedMin: freezed == selectedMin ? _self.selectedMin : selectedMin // ignore: cast_nullable_to_non_nullable
as double?,selectedMax: freezed == selectedMax ? _self.selectedMax : selectedMax // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceFilter].
extension PriceFilterPatterns on PriceFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceFilter value)  $default,){
final _that = this;
switch (_that) {
case _PriceFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PriceFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double min,  double max, @JsonKey(name: 'selected_min')  double? selectedMin, @JsonKey(name: 'selected_max')  double? selectedMax)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceFilter() when $default != null:
return $default(_that.min,_that.max,_that.selectedMin,_that.selectedMax);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double min,  double max, @JsonKey(name: 'selected_min')  double? selectedMin, @JsonKey(name: 'selected_max')  double? selectedMax)  $default,) {final _that = this;
switch (_that) {
case _PriceFilter():
return $default(_that.min,_that.max,_that.selectedMin,_that.selectedMax);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double min,  double max, @JsonKey(name: 'selected_min')  double? selectedMin, @JsonKey(name: 'selected_max')  double? selectedMax)?  $default,) {final _that = this;
switch (_that) {
case _PriceFilter() when $default != null:
return $default(_that.min,_that.max,_that.selectedMin,_that.selectedMax);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceFilter extends PriceFilter {
  const _PriceFilter({this.min = 0, this.max = 0, @JsonKey(name: 'selected_min') this.selectedMin, @JsonKey(name: 'selected_max') this.selectedMax}): super._();
  factory _PriceFilter.fromJson(Map<String, dynamic> json) => _$PriceFilterFromJson(json);

@override@JsonKey() final  double min;
@override@JsonKey() final  double max;
@override@JsonKey(name: 'selected_min') final  double? selectedMin;
@override@JsonKey(name: 'selected_max') final  double? selectedMax;

/// Create a copy of PriceFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceFilterCopyWith<_PriceFilter> get copyWith => __$PriceFilterCopyWithImpl<_PriceFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceFilterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceFilter&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.selectedMin, selectedMin) || other.selectedMin == selectedMin)&&(identical(other.selectedMax, selectedMax) || other.selectedMax == selectedMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,min,max,selectedMin,selectedMax);
}

@override
String toString() {
    return 'PriceFilter(min: $min, max: $max, selectedMin: $selectedMin, selectedMax: $selectedMax)';
}


}

/// @nodoc
abstract mixin class _$PriceFilterCopyWith<$Res> implements $PriceFilterCopyWith<$Res> {
  factory _$PriceFilterCopyWith(_PriceFilter value, $Res Function(_PriceFilter) _then) = __$PriceFilterCopyWithImpl;
@override @useResult
$Res call({
 double min, double max,@JsonKey(name: 'selected_min') double? selectedMin,@JsonKey(name: 'selected_max') double? selectedMax
});




}
/// @nodoc
class __$PriceFilterCopyWithImpl<$Res>
    implements _$PriceFilterCopyWith<$Res> {
  __$PriceFilterCopyWithImpl(this._self, this._then);

  final _PriceFilter _self;
  final $Res Function(_PriceFilter) _then;

/// Create a copy of PriceFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,Object? selectedMin = freezed,Object? selectedMax = freezed,}) {
  return _then(_PriceFilter(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,selectedMin: freezed == selectedMin ? _self.selectedMin : selectedMin // ignore: cast_nullable_to_non_nullable
as double?,selectedMax: freezed == selectedMax ? _self.selectedMax : selectedMax // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$SortOption {

 String get key; String get name; bool get selected;
/// Create a copy of SortOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SortOptionCopyWith<SortOption> get copyWith => _$SortOptionCopyWithImpl<SortOption>(this as SortOption, _$identity);

  /// Serializes this SortOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SortOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SortOption&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.selected, _this.selected) || other.selected == _this.selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SortOption;
  return Object.hash(runtimeType,_this.key,_this.name,_this.selected);
}

@override
String toString() {
  final _this = this as SortOption;
  return 'SortOption(key: ${_this.key}, name: ${_this.name}, selected: ${_this.selected})';
}


}

/// @nodoc
abstract mixin class $SortOptionCopyWith<$Res>  {
  factory $SortOptionCopyWith(SortOption value, $Res Function(SortOption) _then) = _$SortOptionCopyWithImpl;
@useResult
$Res call({
 String key, String name, bool selected
});




}
/// @nodoc
class _$SortOptionCopyWithImpl<$Res>
    implements $SortOptionCopyWith<$Res> {
  _$SortOptionCopyWithImpl(this._self, this._then);

  final SortOption _self;
  final $Res Function(SortOption) _then;

/// Create a copy of SortOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? name = null,Object? selected = null,}) {
  return _then(SortOption(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SortOption].
extension SortOptionPatterns on SortOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SortOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SortOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SortOption value)  $default,){
final _that = this;
switch (_that) {
case _SortOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SortOption value)?  $default,){
final _that = this;
switch (_that) {
case _SortOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String name,  bool selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SortOption() when $default != null:
return $default(_that.key,_that.name,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String name,  bool selected)  $default,) {final _that = this;
switch (_that) {
case _SortOption():
return $default(_that.key,_that.name,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String name,  bool selected)?  $default,) {final _that = this;
switch (_that) {
case _SortOption() when $default != null:
return $default(_that.key,_that.name,_that.selected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SortOption implements SortOption {
  const _SortOption({required this.key, required this.name, this.selected = false});
  factory _SortOption.fromJson(Map<String, dynamic> json) => _$SortOptionFromJson(json);

@override final  String key;
@override final  String name;
@override@JsonKey() final  bool selected;

/// Create a copy of SortOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SortOptionCopyWith<_SortOption> get copyWith => __$SortOptionCopyWithImpl<_SortOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SortOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SortOption&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.selected, selected) || other.selected == selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,name,selected);
}

@override
String toString() {
    return 'SortOption(key: $key, name: $name, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$SortOptionCopyWith<$Res> implements $SortOptionCopyWith<$Res> {
  factory _$SortOptionCopyWith(_SortOption value, $Res Function(_SortOption) _then) = __$SortOptionCopyWithImpl;
@override @useResult
$Res call({
 String key, String name, bool selected
});




}
/// @nodoc
class __$SortOptionCopyWithImpl<$Res>
    implements _$SortOptionCopyWith<$Res> {
  __$SortOptionCopyWithImpl(this._self, this._then);

  final _SortOption _self;
  final $Res Function(_SortOption) _then;

/// Create a copy of SortOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? name = null,Object? selected = null,}) {
  return _then(_SortOption(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProductFilters {

 List<AttributeFilter> get attributes; PriceFilter get price; List<SortOption> get sorts;
/// Create a copy of ProductFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductFiltersCopyWith<ProductFilters> get copyWith => _$ProductFiltersCopyWithImpl<ProductFilters>(this as ProductFilters, _$identity);

  /// Serializes this ProductFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductFilters;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductFilters&&const DeepCollectionEquality().equals(other.attributes, _this.attributes)&&(identical(other.price, _this.price) || other.price == _this.price)&&const DeepCollectionEquality().equals(other.sorts, _this.sorts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductFilters;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.attributes),_this.price,const DeepCollectionEquality().hash(_this.sorts));
}

@override
String toString() {
  final _this = this as ProductFilters;
  return 'ProductFilters(attributes: ${_this.attributes}, price: ${_this.price}, sorts: ${_this.sorts})';
}


}

/// @nodoc
abstract mixin class $ProductFiltersCopyWith<$Res>  {
  factory $ProductFiltersCopyWith(ProductFilters value, $Res Function(ProductFilters) _then) = _$ProductFiltersCopyWithImpl;
@useResult
$Res call({
 List<AttributeFilter> attributes, PriceFilter price, List<SortOption> sorts
});


$PriceFilterCopyWith<$Res> get price;

}
/// @nodoc
class _$ProductFiltersCopyWithImpl<$Res>
    implements $ProductFiltersCopyWith<$Res> {
  _$ProductFiltersCopyWithImpl(this._self, this._then);

  final ProductFilters _self;
  final $Res Function(ProductFilters) _then;

/// Create a copy of ProductFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attributes = null,Object? price = null,Object? sorts = null,}) {
  return _then(ProductFilters(
attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as List<AttributeFilter>,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as PriceFilter,sorts: null == sorts ? _self.sorts : sorts // ignore: cast_nullable_to_non_nullable
as List<SortOption>,
  ));
}
/// Create a copy of ProductFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceFilterCopyWith<$Res> get price {
  
  return $PriceFilterCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductFilters].
extension ProductFiltersPatterns on ProductFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductFilters value)  $default,){
final _that = this;
switch (_that) {
case _ProductFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductFilters value)?  $default,){
final _that = this;
switch (_that) {
case _ProductFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AttributeFilter> attributes,  PriceFilter price,  List<SortOption> sorts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductFilters() when $default != null:
return $default(_that.attributes,_that.price,_that.sorts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AttributeFilter> attributes,  PriceFilter price,  List<SortOption> sorts)  $default,) {final _that = this;
switch (_that) {
case _ProductFilters():
return $default(_that.attributes,_that.price,_that.sorts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AttributeFilter> attributes,  PriceFilter price,  List<SortOption> sorts)?  $default,) {final _that = this;
switch (_that) {
case _ProductFilters() when $default != null:
return $default(_that.attributes,_that.price,_that.sorts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductFilters implements ProductFilters {
  const _ProductFilters({ List<AttributeFilter> attributes = const [], this.price = const PriceFilter(),  List<SortOption> sorts = const []}): _attributes = attributes,_sorts = sorts;
  factory _ProductFilters.fromJson(Map<String, dynamic> json) => _$ProductFiltersFromJson(json);

 final  List<AttributeFilter> _attributes;
@override@JsonKey() List<AttributeFilter> get attributes {
  if (_attributes is EqualUnmodifiableListView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attributes);
}

@override@JsonKey() final  PriceFilter price;
 final  List<SortOption> _sorts;
@override@JsonKey() List<SortOption> get sorts {
  if (_sorts is EqualUnmodifiableListView) return _sorts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sorts);
}


/// Create a copy of ProductFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFiltersCopyWith<_ProductFilters> get copyWith => __$ProductFiltersCopyWithImpl<_ProductFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFilters&&const DeepCollectionEquality().equals(other.attributes, _attributes)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.sorts, _sorts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_attributes),price,const DeepCollectionEquality().hash(_sorts));
}

@override
String toString() {
    return 'ProductFilters(attributes: $attributes, price: $price, sorts: $sorts)';
}


}

/// @nodoc
abstract mixin class _$ProductFiltersCopyWith<$Res> implements $ProductFiltersCopyWith<$Res> {
  factory _$ProductFiltersCopyWith(_ProductFilters value, $Res Function(_ProductFilters) _then) = __$ProductFiltersCopyWithImpl;
@override @useResult
$Res call({
 List<AttributeFilter> attributes, PriceFilter price, List<SortOption> sorts
});


@override $PriceFilterCopyWith<$Res> get price;

}
/// @nodoc
class __$ProductFiltersCopyWithImpl<$Res>
    implements _$ProductFiltersCopyWith<$Res> {
  __$ProductFiltersCopyWithImpl(this._self, this._then);

  final _ProductFilters _self;
  final $Res Function(_ProductFilters) _then;

/// Create a copy of ProductFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attributes = null,Object? price = null,Object? sorts = null,}) {
  return _then(_ProductFilters(
attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as List<AttributeFilter>,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as PriceFilter,sorts: null == sorts ? _self._sorts : sorts // ignore: cast_nullable_to_non_nullable
as List<SortOption>,
  ));
}

/// Create a copy of ProductFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceFilterCopyWith<$Res> get price {
  
  return $PriceFilterCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}

// dart format on

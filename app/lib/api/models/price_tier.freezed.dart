// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_tier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceTier {

@JsonKey(name: 'min_qty') int get minQty; String get label; Price get price;
/// Create a copy of PriceTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceTierCopyWith<PriceTier> get copyWith => _$PriceTierCopyWithImpl<PriceTier>(this as PriceTier, _$identity);

  /// Serializes this PriceTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceTier;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceTier&&(identical(other.minQty, _this.minQty) || other.minQty == _this.minQty)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.price, _this.price) || other.price == _this.price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceTier;
  return Object.hash(runtimeType,_this.minQty,_this.label,_this.price);
}

@override
String toString() {
  final _this = this as PriceTier;
  return 'PriceTier(minQty: ${_this.minQty}, label: ${_this.label}, price: ${_this.price})';
}


}

/// @nodoc
abstract mixin class $PriceTierCopyWith<$Res>  {
  factory $PriceTierCopyWith(PriceTier value, $Res Function(PriceTier) _then) = _$PriceTierCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'min_qty') int minQty, String label, Price price
});


$PriceCopyWith<$Res> get price;

}
/// @nodoc
class _$PriceTierCopyWithImpl<$Res>
    implements $PriceTierCopyWith<$Res> {
  _$PriceTierCopyWithImpl(this._self, this._then);

  final PriceTier _self;
  final $Res Function(PriceTier) _then;

/// Create a copy of PriceTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minQty = null,Object? label = null,Object? price = null,}) {
  return _then(PriceTier(
minQty: null == minQty ? _self.minQty : minQty // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}
/// Create a copy of PriceTier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [PriceTier].
extension PriceTierPatterns on PriceTier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceTier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceTier value)  $default,){
final _that = this;
switch (_that) {
case _PriceTier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceTier value)?  $default,){
final _that = this;
switch (_that) {
case _PriceTier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'min_qty')  int minQty,  String label,  Price price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceTier() when $default != null:
return $default(_that.minQty,_that.label,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'min_qty')  int minQty,  String label,  Price price)  $default,) {final _that = this;
switch (_that) {
case _PriceTier():
return $default(_that.minQty,_that.label,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'min_qty')  int minQty,  String label,  Price price)?  $default,) {final _that = this;
switch (_that) {
case _PriceTier() when $default != null:
return $default(_that.minQty,_that.label,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceTier implements PriceTier {
  const _PriceTier({@JsonKey(name: 'min_qty') required this.minQty, required this.label, required this.price});
  factory _PriceTier.fromJson(Map<String, dynamic> json) => _$PriceTierFromJson(json);

@override@JsonKey(name: 'min_qty') final  int minQty;
@override final  String label;
@override final  Price price;

/// Create a copy of PriceTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceTierCopyWith<_PriceTier> get copyWith => __$PriceTierCopyWithImpl<_PriceTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceTierToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceTier&&(identical(other.minQty, minQty) || other.minQty == minQty)&&(identical(other.label, label) || other.label == label)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minQty,label,price);
}

@override
String toString() {
    return 'PriceTier(minQty: $minQty, label: $label, price: $price)';
}


}

/// @nodoc
abstract mixin class _$PriceTierCopyWith<$Res> implements $PriceTierCopyWith<$Res> {
  factory _$PriceTierCopyWith(_PriceTier value, $Res Function(_PriceTier) _then) = __$PriceTierCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'min_qty') int minQty, String label, Price price
});


@override $PriceCopyWith<$Res> get price;

}
/// @nodoc
class __$PriceTierCopyWithImpl<$Res>
    implements _$PriceTierCopyWith<$Res> {
  __$PriceTierCopyWithImpl(this._self, this._then);

  final _PriceTier _self;
  final $Res Function(_PriceTier) _then;

/// Create a copy of PriceTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minQty = null,Object? label = null,Object? price = null,}) {
  return _then(_PriceTier(
minQty: null == minQty ? _self.minQty : minQty // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}

/// Create a copy of PriceTier
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variant_prices.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VariantPriceLine {

@JsonKey(name: 'variant_id') int get variantId; int get qty; Price get price; Price get subtotal;
/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantPriceLineCopyWith<VariantPriceLine> get copyWith => _$VariantPriceLineCopyWithImpl<VariantPriceLine>(this as VariantPriceLine, _$identity);

  /// Serializes this VariantPriceLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VariantPriceLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantPriceLine&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.qty, _this.qty) || other.qty == _this.qty)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VariantPriceLine;
  return Object.hash(runtimeType,_this.variantId,_this.qty,_this.price,_this.subtotal);
}

@override
String toString() {
  final _this = this as VariantPriceLine;
  return 'VariantPriceLine(variantId: ${_this.variantId}, qty: ${_this.qty}, price: ${_this.price}, subtotal: ${_this.subtotal})';
}


}

/// @nodoc
abstract mixin class $VariantPriceLineCopyWith<$Res>  {
  factory $VariantPriceLineCopyWith(VariantPriceLine value, $Res Function(VariantPriceLine) _then) = _$VariantPriceLineCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'variant_id') int variantId, int qty, Price price, Price subtotal
});


$PriceCopyWith<$Res> get price;$PriceCopyWith<$Res> get subtotal;

}
/// @nodoc
class _$VariantPriceLineCopyWithImpl<$Res>
    implements $VariantPriceLineCopyWith<$Res> {
  _$VariantPriceLineCopyWithImpl(this._self, this._then);

  final VariantPriceLine _self;
  final $Res Function(VariantPriceLine) _then;

/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? variantId = null,Object? qty = null,Object? price = null,Object? subtotal = null,}) {
  return _then(VariantPriceLine(
variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}
/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get subtotal {
  
  return $PriceCopyWith<$Res>(_self.subtotal, (value) {
    return _then(_self.copyWith(subtotal: value));
  });
}
}


/// Adds pattern-matching-related methods to [VariantPriceLine].
extension VariantPriceLinePatterns on VariantPriceLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantPriceLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantPriceLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantPriceLine value)  $default,){
final _that = this;
switch (_that) {
case _VariantPriceLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantPriceLine value)?  $default,){
final _that = this;
switch (_that) {
case _VariantPriceLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'variant_id')  int variantId,  int qty,  Price price,  Price subtotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantPriceLine() when $default != null:
return $default(_that.variantId,_that.qty,_that.price,_that.subtotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'variant_id')  int variantId,  int qty,  Price price,  Price subtotal)  $default,) {final _that = this;
switch (_that) {
case _VariantPriceLine():
return $default(_that.variantId,_that.qty,_that.price,_that.subtotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'variant_id')  int variantId,  int qty,  Price price,  Price subtotal)?  $default,) {final _that = this;
switch (_that) {
case _VariantPriceLine() when $default != null:
return $default(_that.variantId,_that.qty,_that.price,_that.subtotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantPriceLine implements VariantPriceLine {
  const _VariantPriceLine({@JsonKey(name: 'variant_id') required this.variantId, this.qty = 0, required this.price, required this.subtotal});
  factory _VariantPriceLine.fromJson(Map<String, dynamic> json) => _$VariantPriceLineFromJson(json);

@override@JsonKey(name: 'variant_id') final  int variantId;
@override@JsonKey() final  int qty;
@override final  Price price;
@override final  Price subtotal;

/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantPriceLineCopyWith<_VariantPriceLine> get copyWith => __$VariantPriceLineCopyWithImpl<_VariantPriceLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantPriceLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantPriceLine&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.price, price) || other.price == price)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,variantId,qty,price,subtotal);
}

@override
String toString() {
    return 'VariantPriceLine(variantId: $variantId, qty: $qty, price: $price, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class _$VariantPriceLineCopyWith<$Res> implements $VariantPriceLineCopyWith<$Res> {
  factory _$VariantPriceLineCopyWith(_VariantPriceLine value, $Res Function(_VariantPriceLine) _then) = __$VariantPriceLineCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'variant_id') int variantId, int qty, Price price, Price subtotal
});


@override $PriceCopyWith<$Res> get price;@override $PriceCopyWith<$Res> get subtotal;

}
/// @nodoc
class __$VariantPriceLineCopyWithImpl<$Res>
    implements _$VariantPriceLineCopyWith<$Res> {
  __$VariantPriceLineCopyWithImpl(this._self, this._then);

  final _VariantPriceLine _self;
  final $Res Function(_VariantPriceLine) _then;

/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? variantId = null,Object? qty = null,Object? price = null,Object? subtotal = null,}) {
  return _then(_VariantPriceLine(
variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}

/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of VariantPriceLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get subtotal {
  
  return $PriceCopyWith<$Res>(_self.subtotal, (value) {
    return _then(_self.copyWith(subtotal: value));
  });
}
}


/// @nodoc
mixin _$VariantPrices {

 List<VariantPriceLine> get lines; Price get total;
/// Create a copy of VariantPrices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantPricesCopyWith<VariantPrices> get copyWith => _$VariantPricesCopyWithImpl<VariantPrices>(this as VariantPrices, _$identity);

  /// Serializes this VariantPrices to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VariantPrices;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantPrices&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VariantPrices;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.total);
}

@override
String toString() {
  final _this = this as VariantPrices;
  return 'VariantPrices(lines: ${_this.lines}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $VariantPricesCopyWith<$Res>  {
  factory $VariantPricesCopyWith(VariantPrices value, $Res Function(VariantPrices) _then) = _$VariantPricesCopyWithImpl;
@useResult
$Res call({
 List<VariantPriceLine> lines, Price total
});


$PriceCopyWith<$Res> get total;

}
/// @nodoc
class _$VariantPricesCopyWithImpl<$Res>
    implements $VariantPricesCopyWith<$Res> {
  _$VariantPricesCopyWithImpl(this._self, this._then);

  final VariantPrices _self;
  final $Res Function(VariantPrices) _then;

/// Create a copy of VariantPrices
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? total = null,}) {
  return _then(VariantPrices(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<VariantPriceLine>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}
/// Create a copy of VariantPrices
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [VariantPrices].
extension VariantPricesPatterns on VariantPrices {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantPrices value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantPrices() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantPrices value)  $default,){
final _that = this;
switch (_that) {
case _VariantPrices():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantPrices value)?  $default,){
final _that = this;
switch (_that) {
case _VariantPrices() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VariantPriceLine> lines,  Price total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantPrices() when $default != null:
return $default(_that.lines,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VariantPriceLine> lines,  Price total)  $default,) {final _that = this;
switch (_that) {
case _VariantPrices():
return $default(_that.lines,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VariantPriceLine> lines,  Price total)?  $default,) {final _that = this;
switch (_that) {
case _VariantPrices() when $default != null:
return $default(_that.lines,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantPrices implements VariantPrices {
  const _VariantPrices({ List<VariantPriceLine> lines = const [], required this.total}): _lines = lines;
  factory _VariantPrices.fromJson(Map<String, dynamic> json) => _$VariantPricesFromJson(json);

 final  List<VariantPriceLine> _lines;
@override@JsonKey() List<VariantPriceLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  Price total;

/// Create a copy of VariantPrices
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantPricesCopyWith<_VariantPrices> get copyWith => __$VariantPricesCopyWithImpl<_VariantPrices>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantPricesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantPrices&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),total);
}

@override
String toString() {
    return 'VariantPrices(lines: $lines, total: $total)';
}


}

/// @nodoc
abstract mixin class _$VariantPricesCopyWith<$Res> implements $VariantPricesCopyWith<$Res> {
  factory _$VariantPricesCopyWith(_VariantPrices value, $Res Function(_VariantPrices) _then) = __$VariantPricesCopyWithImpl;
@override @useResult
$Res call({
 List<VariantPriceLine> lines, Price total
});


@override $PriceCopyWith<$Res> get total;

}
/// @nodoc
class __$VariantPricesCopyWithImpl<$Res>
    implements _$VariantPricesCopyWith<$Res> {
  __$VariantPricesCopyWithImpl(this._self, this._then);

  final _VariantPrices _self;
  final $Res Function(_VariantPrices) _then;

/// Create a copy of VariantPrices
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? total = null,}) {
  return _then(_VariantPrices(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<VariantPriceLine>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}

/// Create a copy of VariantPrices
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}

// dart format on

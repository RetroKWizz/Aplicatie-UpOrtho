// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartLine {

 int get id;@JsonKey(name: 'product_id') int get productId;@JsonKey(name: 'variant_id') int get variantId; String get name;@JsonKey(name: 'variant_name') String? get variantName;@JsonKey(name: 'default_code') String? get defaultCode;@JsonKey(name: 'image_url') String? get imageUrl; int get quantity;@JsonKey(name: 'unit_price') Price get unitPrice; Price get subtotal; String? get warning;
/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartLineCopyWith<CartLine> get copyWith => _$CartLineCopyWithImpl<CartLine>(this as CartLine, _$identity);

  /// Serializes this CartLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CartLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.variantName, _this.variantName) || other.variantName == _this.variantName)&&(identical(other.defaultCode, _this.defaultCode) || other.defaultCode == _this.defaultCode)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.warning, _this.warning) || other.warning == _this.warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.variantId,_this.name,_this.variantName,_this.defaultCode,_this.imageUrl,_this.quantity,_this.unitPrice,_this.subtotal,_this.warning);
}

@override
String toString() {
  final _this = this as CartLine;
  return 'CartLine(id: ${_this.id}, productId: ${_this.productId}, variantId: ${_this.variantId}, name: ${_this.name}, variantName: ${_this.variantName}, defaultCode: ${_this.defaultCode}, imageUrl: ${_this.imageUrl}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, subtotal: ${_this.subtotal}, warning: ${_this.warning})';
}


}

/// @nodoc
abstract mixin class $CartLineCopyWith<$Res>  {
  factory $CartLineCopyWith(CartLine value, $Res Function(CartLine) _then) = _$CartLineCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'product_id') int productId,@JsonKey(name: 'variant_id') int variantId, String name,@JsonKey(name: 'variant_name') String? variantName,@JsonKey(name: 'default_code') String? defaultCode,@JsonKey(name: 'image_url') String? imageUrl, int quantity,@JsonKey(name: 'unit_price') Price unitPrice, Price subtotal, String? warning
});


$PriceCopyWith<$Res> get unitPrice;$PriceCopyWith<$Res> get subtotal;

}
/// @nodoc
class _$CartLineCopyWithImpl<$Res>
    implements $CartLineCopyWith<$Res> {
  _$CartLineCopyWithImpl(this._self, this._then);

  final CartLine _self;
  final $Res Function(CartLine) _then;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? variantId = null,Object? name = null,Object? variantName = freezed,Object? defaultCode = freezed,Object? imageUrl = freezed,Object? quantity = null,Object? unitPrice = null,Object? subtotal = null,Object? warning = freezed,}) {
  return _then(CartLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,defaultCode: freezed == defaultCode ? _self.defaultCode : defaultCode // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Price,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Price,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get unitPrice {
  
  return $PriceCopyWith<$Res>(_self.unitPrice, (value) {
    return _then(_self.copyWith(unitPrice: value));
  });
}/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get subtotal {
  
  return $PriceCopyWith<$Res>(_self.subtotal, (value) {
    return _then(_self.copyWith(subtotal: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartLine].
extension CartLinePatterns on CartLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartLine value)  $default,){
final _that = this;
switch (_that) {
case _CartLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartLine value)?  $default,){
final _that = this;
switch (_that) {
case _CartLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'product_id')  int productId, @JsonKey(name: 'variant_id')  int variantId,  String name, @JsonKey(name: 'variant_name')  String? variantName, @JsonKey(name: 'default_code')  String? defaultCode, @JsonKey(name: 'image_url')  String? imageUrl,  int quantity, @JsonKey(name: 'unit_price')  Price unitPrice,  Price subtotal,  String? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartLine() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.name,_that.variantName,_that.defaultCode,_that.imageUrl,_that.quantity,_that.unitPrice,_that.subtotal,_that.warning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'product_id')  int productId, @JsonKey(name: 'variant_id')  int variantId,  String name, @JsonKey(name: 'variant_name')  String? variantName, @JsonKey(name: 'default_code')  String? defaultCode, @JsonKey(name: 'image_url')  String? imageUrl,  int quantity, @JsonKey(name: 'unit_price')  Price unitPrice,  Price subtotal,  String? warning)  $default,) {final _that = this;
switch (_that) {
case _CartLine():
return $default(_that.id,_that.productId,_that.variantId,_that.name,_that.variantName,_that.defaultCode,_that.imageUrl,_that.quantity,_that.unitPrice,_that.subtotal,_that.warning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'product_id')  int productId, @JsonKey(name: 'variant_id')  int variantId,  String name, @JsonKey(name: 'variant_name')  String? variantName, @JsonKey(name: 'default_code')  String? defaultCode, @JsonKey(name: 'image_url')  String? imageUrl,  int quantity, @JsonKey(name: 'unit_price')  Price unitPrice,  Price subtotal,  String? warning)?  $default,) {final _that = this;
switch (_that) {
case _CartLine() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.name,_that.variantName,_that.defaultCode,_that.imageUrl,_that.quantity,_that.unitPrice,_that.subtotal,_that.warning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartLine implements CartLine {
  const _CartLine({required this.id, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'variant_id') required this.variantId, required this.name, @JsonKey(name: 'variant_name') this.variantName, @JsonKey(name: 'default_code') this.defaultCode, @JsonKey(name: 'image_url') this.imageUrl, required this.quantity, @JsonKey(name: 'unit_price') required this.unitPrice, required this.subtotal, this.warning});
  factory _CartLine.fromJson(Map<String, dynamic> json) => _$CartLineFromJson(json);

@override final  int id;
@override@JsonKey(name: 'product_id') final  int productId;
@override@JsonKey(name: 'variant_id') final  int variantId;
@override final  String name;
@override@JsonKey(name: 'variant_name') final  String? variantName;
@override@JsonKey(name: 'default_code') final  String? defaultCode;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  int quantity;
@override@JsonKey(name: 'unit_price') final  Price unitPrice;
@override final  Price subtotal;
@override final  String? warning;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartLineCopyWith<_CartLine> get copyWith => __$CartLineCopyWithImpl<_CartLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.defaultCode, defaultCode) || other.defaultCode == defaultCode)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,variantId,name,variantName,defaultCode,imageUrl,quantity,unitPrice,subtotal,warning);
}

@override
String toString() {
    return 'CartLine(id: $id, productId: $productId, variantId: $variantId, name: $name, variantName: $variantName, defaultCode: $defaultCode, imageUrl: $imageUrl, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$CartLineCopyWith<$Res> implements $CartLineCopyWith<$Res> {
  factory _$CartLineCopyWith(_CartLine value, $Res Function(_CartLine) _then) = __$CartLineCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'product_id') int productId,@JsonKey(name: 'variant_id') int variantId, String name,@JsonKey(name: 'variant_name') String? variantName,@JsonKey(name: 'default_code') String? defaultCode,@JsonKey(name: 'image_url') String? imageUrl, int quantity,@JsonKey(name: 'unit_price') Price unitPrice, Price subtotal, String? warning
});


@override $PriceCopyWith<$Res> get unitPrice;@override $PriceCopyWith<$Res> get subtotal;

}
/// @nodoc
class __$CartLineCopyWithImpl<$Res>
    implements _$CartLineCopyWith<$Res> {
  __$CartLineCopyWithImpl(this._self, this._then);

  final _CartLine _self;
  final $Res Function(_CartLine) _then;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? variantId = null,Object? name = null,Object? variantName = freezed,Object? defaultCode = freezed,Object? imageUrl = freezed,Object? quantity = null,Object? unitPrice = null,Object? subtotal = null,Object? warning = freezed,}) {
  return _then(_CartLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,defaultCode: freezed == defaultCode ? _self.defaultCode : defaultCode // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Price,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Price,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get unitPrice {
  
  return $PriceCopyWith<$Res>(_self.unitPrice, (value) {
    return _then(_self.copyWith(unitPrice: value));
  });
}/// Create a copy of CartLine
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
mixin _$CartAmounts {

 Price get untaxed; Price get tax; Price get delivery; Price get total;
/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartAmountsCopyWith<CartAmounts> get copyWith => _$CartAmountsCopyWithImpl<CartAmounts>(this as CartAmounts, _$identity);

  /// Serializes this CartAmounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CartAmounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartAmounts&&(identical(other.untaxed, _this.untaxed) || other.untaxed == _this.untaxed)&&(identical(other.tax, _this.tax) || other.tax == _this.tax)&&(identical(other.delivery, _this.delivery) || other.delivery == _this.delivery)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartAmounts;
  return Object.hash(runtimeType,_this.untaxed,_this.tax,_this.delivery,_this.total);
}

@override
String toString() {
  final _this = this as CartAmounts;
  return 'CartAmounts(untaxed: ${_this.untaxed}, tax: ${_this.tax}, delivery: ${_this.delivery}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $CartAmountsCopyWith<$Res>  {
  factory $CartAmountsCopyWith(CartAmounts value, $Res Function(CartAmounts) _then) = _$CartAmountsCopyWithImpl;
@useResult
$Res call({
 Price untaxed, Price tax, Price delivery, Price total
});


$PriceCopyWith<$Res> get untaxed;$PriceCopyWith<$Res> get tax;$PriceCopyWith<$Res> get delivery;$PriceCopyWith<$Res> get total;

}
/// @nodoc
class _$CartAmountsCopyWithImpl<$Res>
    implements $CartAmountsCopyWith<$Res> {
  _$CartAmountsCopyWithImpl(this._self, this._then);

  final CartAmounts _self;
  final $Res Function(CartAmounts) _then;

/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? untaxed = null,Object? tax = null,Object? delivery = null,Object? total = null,}) {
  return _then(CartAmounts(
untaxed: null == untaxed ? _self.untaxed : untaxed // ignore: cast_nullable_to_non_nullable
as Price,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Price,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as Price,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}
/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get untaxed {
  
  return $PriceCopyWith<$Res>(_self.untaxed, (value) {
    return _then(_self.copyWith(untaxed: value));
  });
}/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get tax {
  
  return $PriceCopyWith<$Res>(_self.tax, (value) {
    return _then(_self.copyWith(tax: value));
  });
}/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get delivery {
  
  return $PriceCopyWith<$Res>(_self.delivery, (value) {
    return _then(_self.copyWith(delivery: value));
  });
}/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartAmounts].
extension CartAmountsPatterns on CartAmounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartAmounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartAmounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartAmounts value)  $default,){
final _that = this;
switch (_that) {
case _CartAmounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartAmounts value)?  $default,){
final _that = this;
switch (_that) {
case _CartAmounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Price untaxed,  Price tax,  Price delivery,  Price total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartAmounts() when $default != null:
return $default(_that.untaxed,_that.tax,_that.delivery,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Price untaxed,  Price tax,  Price delivery,  Price total)  $default,) {final _that = this;
switch (_that) {
case _CartAmounts():
return $default(_that.untaxed,_that.tax,_that.delivery,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Price untaxed,  Price tax,  Price delivery,  Price total)?  $default,) {final _that = this;
switch (_that) {
case _CartAmounts() when $default != null:
return $default(_that.untaxed,_that.tax,_that.delivery,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartAmounts implements CartAmounts {
  const _CartAmounts({required this.untaxed, required this.tax, required this.delivery, required this.total});
  factory _CartAmounts.fromJson(Map<String, dynamic> json) => _$CartAmountsFromJson(json);

@override final  Price untaxed;
@override final  Price tax;
@override final  Price delivery;
@override final  Price total;

/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartAmountsCopyWith<_CartAmounts> get copyWith => __$CartAmountsCopyWithImpl<_CartAmounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartAmountsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartAmounts&&(identical(other.untaxed, untaxed) || other.untaxed == untaxed)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,untaxed,tax,delivery,total);
}

@override
String toString() {
    return 'CartAmounts(untaxed: $untaxed, tax: $tax, delivery: $delivery, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CartAmountsCopyWith<$Res> implements $CartAmountsCopyWith<$Res> {
  factory _$CartAmountsCopyWith(_CartAmounts value, $Res Function(_CartAmounts) _then) = __$CartAmountsCopyWithImpl;
@override @useResult
$Res call({
 Price untaxed, Price tax, Price delivery, Price total
});


@override $PriceCopyWith<$Res> get untaxed;@override $PriceCopyWith<$Res> get tax;@override $PriceCopyWith<$Res> get delivery;@override $PriceCopyWith<$Res> get total;

}
/// @nodoc
class __$CartAmountsCopyWithImpl<$Res>
    implements _$CartAmountsCopyWith<$Res> {
  __$CartAmountsCopyWithImpl(this._self, this._then);

  final _CartAmounts _self;
  final $Res Function(_CartAmounts) _then;

/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? untaxed = null,Object? tax = null,Object? delivery = null,Object? total = null,}) {
  return _then(_CartAmounts(
untaxed: null == untaxed ? _self.untaxed : untaxed // ignore: cast_nullable_to_non_nullable
as Price,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Price,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as Price,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}

/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get untaxed {
  
  return $PriceCopyWith<$Res>(_self.untaxed, (value) {
    return _then(_self.copyWith(untaxed: value));
  });
}/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get tax {
  
  return $PriceCopyWith<$Res>(_self.tax, (value) {
    return _then(_self.copyWith(tax: value));
  });
}/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get delivery {
  
  return $PriceCopyWith<$Res>(_self.delivery, (value) {
    return _then(_self.copyWith(delivery: value));
  });
}/// Create a copy of CartAmounts
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get total {
  
  return $PriceCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// @nodoc
mixin _$FreeDeliveryProgress {

@JsonKey(name: 'free_over') Price get freeOver;@JsonKey(name: 'order_amount') Price get orderAmount; Price get remaining; bool get reached;
/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreeDeliveryProgressCopyWith<FreeDeliveryProgress> get copyWith => _$FreeDeliveryProgressCopyWithImpl<FreeDeliveryProgress>(this as FreeDeliveryProgress, _$identity);

  /// Serializes this FreeDeliveryProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FreeDeliveryProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreeDeliveryProgress&&(identical(other.freeOver, _this.freeOver) || other.freeOver == _this.freeOver)&&(identical(other.orderAmount, _this.orderAmount) || other.orderAmount == _this.orderAmount)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.reached, _this.reached) || other.reached == _this.reached));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FreeDeliveryProgress;
  return Object.hash(runtimeType,_this.freeOver,_this.orderAmount,_this.remaining,_this.reached);
}

@override
String toString() {
  final _this = this as FreeDeliveryProgress;
  return 'FreeDeliveryProgress(freeOver: ${_this.freeOver}, orderAmount: ${_this.orderAmount}, remaining: ${_this.remaining}, reached: ${_this.reached})';
}


}

/// @nodoc
abstract mixin class $FreeDeliveryProgressCopyWith<$Res>  {
  factory $FreeDeliveryProgressCopyWith(FreeDeliveryProgress value, $Res Function(FreeDeliveryProgress) _then) = _$FreeDeliveryProgressCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'free_over') Price freeOver,@JsonKey(name: 'order_amount') Price orderAmount, Price remaining, bool reached
});


$PriceCopyWith<$Res> get freeOver;$PriceCopyWith<$Res> get orderAmount;$PriceCopyWith<$Res> get remaining;

}
/// @nodoc
class _$FreeDeliveryProgressCopyWithImpl<$Res>
    implements $FreeDeliveryProgressCopyWith<$Res> {
  _$FreeDeliveryProgressCopyWithImpl(this._self, this._then);

  final FreeDeliveryProgress _self;
  final $Res Function(FreeDeliveryProgress) _then;

/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? freeOver = null,Object? orderAmount = null,Object? remaining = null,Object? reached = null,}) {
  return _then(FreeDeliveryProgress(
freeOver: null == freeOver ? _self.freeOver : freeOver // ignore: cast_nullable_to_non_nullable
as Price,orderAmount: null == orderAmount ? _self.orderAmount : orderAmount // ignore: cast_nullable_to_non_nullable
as Price,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Price,reached: null == reached ? _self.reached : reached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get freeOver {
  
  return $PriceCopyWith<$Res>(_self.freeOver, (value) {
    return _then(_self.copyWith(freeOver: value));
  });
}/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get orderAmount {
  
  return $PriceCopyWith<$Res>(_self.orderAmount, (value) {
    return _then(_self.copyWith(orderAmount: value));
  });
}/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get remaining {
  
  return $PriceCopyWith<$Res>(_self.remaining, (value) {
    return _then(_self.copyWith(remaining: value));
  });
}
}


/// Adds pattern-matching-related methods to [FreeDeliveryProgress].
extension FreeDeliveryProgressPatterns on FreeDeliveryProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FreeDeliveryProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FreeDeliveryProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FreeDeliveryProgress value)  $default,){
final _that = this;
switch (_that) {
case _FreeDeliveryProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FreeDeliveryProgress value)?  $default,){
final _that = this;
switch (_that) {
case _FreeDeliveryProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'free_over')  Price freeOver, @JsonKey(name: 'order_amount')  Price orderAmount,  Price remaining,  bool reached)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FreeDeliveryProgress() when $default != null:
return $default(_that.freeOver,_that.orderAmount,_that.remaining,_that.reached);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'free_over')  Price freeOver, @JsonKey(name: 'order_amount')  Price orderAmount,  Price remaining,  bool reached)  $default,) {final _that = this;
switch (_that) {
case _FreeDeliveryProgress():
return $default(_that.freeOver,_that.orderAmount,_that.remaining,_that.reached);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'free_over')  Price freeOver, @JsonKey(name: 'order_amount')  Price orderAmount,  Price remaining,  bool reached)?  $default,) {final _that = this;
switch (_that) {
case _FreeDeliveryProgress() when $default != null:
return $default(_that.freeOver,_that.orderAmount,_that.remaining,_that.reached);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FreeDeliveryProgress implements FreeDeliveryProgress {
  const _FreeDeliveryProgress({@JsonKey(name: 'free_over') required this.freeOver, @JsonKey(name: 'order_amount') required this.orderAmount, required this.remaining, required this.reached});
  factory _FreeDeliveryProgress.fromJson(Map<String, dynamic> json) => _$FreeDeliveryProgressFromJson(json);

@override@JsonKey(name: 'free_over') final  Price freeOver;
@override@JsonKey(name: 'order_amount') final  Price orderAmount;
@override final  Price remaining;
@override final  bool reached;

/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FreeDeliveryProgressCopyWith<_FreeDeliveryProgress> get copyWith => __$FreeDeliveryProgressCopyWithImpl<_FreeDeliveryProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreeDeliveryProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FreeDeliveryProgress&&(identical(other.freeOver, freeOver) || other.freeOver == freeOver)&&(identical(other.orderAmount, orderAmount) || other.orderAmount == orderAmount)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.reached, reached) || other.reached == reached));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,freeOver,orderAmount,remaining,reached);
}

@override
String toString() {
    return 'FreeDeliveryProgress(freeOver: $freeOver, orderAmount: $orderAmount, remaining: $remaining, reached: $reached)';
}


}

/// @nodoc
abstract mixin class _$FreeDeliveryProgressCopyWith<$Res> implements $FreeDeliveryProgressCopyWith<$Res> {
  factory _$FreeDeliveryProgressCopyWith(_FreeDeliveryProgress value, $Res Function(_FreeDeliveryProgress) _then) = __$FreeDeliveryProgressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'free_over') Price freeOver,@JsonKey(name: 'order_amount') Price orderAmount, Price remaining, bool reached
});


@override $PriceCopyWith<$Res> get freeOver;@override $PriceCopyWith<$Res> get orderAmount;@override $PriceCopyWith<$Res> get remaining;

}
/// @nodoc
class __$FreeDeliveryProgressCopyWithImpl<$Res>
    implements _$FreeDeliveryProgressCopyWith<$Res> {
  __$FreeDeliveryProgressCopyWithImpl(this._self, this._then);

  final _FreeDeliveryProgress _self;
  final $Res Function(_FreeDeliveryProgress) _then;

/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? freeOver = null,Object? orderAmount = null,Object? remaining = null,Object? reached = null,}) {
  return _then(_FreeDeliveryProgress(
freeOver: null == freeOver ? _self.freeOver : freeOver // ignore: cast_nullable_to_non_nullable
as Price,orderAmount: null == orderAmount ? _self.orderAmount : orderAmount // ignore: cast_nullable_to_non_nullable
as Price,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Price,reached: null == reached ? _self.reached : reached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get freeOver {
  
  return $PriceCopyWith<$Res>(_self.freeOver, (value) {
    return _then(_self.copyWith(freeOver: value));
  });
}/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get orderAmount {
  
  return $PriceCopyWith<$Res>(_self.orderAmount, (value) {
    return _then(_self.copyWith(orderAmount: value));
  });
}/// Create a copy of FreeDeliveryProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get remaining {
  
  return $PriceCopyWith<$Res>(_self.remaining, (value) {
    return _then(_self.copyWith(remaining: value));
  });
}
}


/// @nodoc
mixin _$Cart {

@JsonKey(name: 'order_id') int? get orderId; int get quantity; List<CartLine> get lines; CartAmounts get amounts;@JsonKey(name: 'free_delivery') FreeDeliveryProgress? get freeDelivery; String? get warning;/// Avertismentele stranse de server la ultima modificare (stoc ajustat, cantitate
/// redusa). Vin o singura data, in raspunsul modificarii - un `GET /cart` de dupa
/// nu le mai contine.
 List<String> get warnings;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Cart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.amounts, _this.amounts) || other.amounts == _this.amounts)&&(identical(other.freeDelivery, _this.freeDelivery) || other.freeDelivery == _this.freeDelivery)&&(identical(other.warning, _this.warning) || other.warning == _this.warning)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Cart;
  return Object.hash(runtimeType,_this.orderId,_this.quantity,const DeepCollectionEquality().hash(_this.lines),_this.amounts,_this.freeDelivery,_this.warning,const DeepCollectionEquality().hash(_this.warnings));
}

@override
String toString() {
  final _this = this as Cart;
  return 'Cart(orderId: ${_this.orderId}, quantity: ${_this.quantity}, lines: ${_this.lines}, amounts: ${_this.amounts}, freeDelivery: ${_this.freeDelivery}, warning: ${_this.warning}, warnings: ${_this.warnings})';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'order_id') int? orderId, int quantity, List<CartLine> lines, CartAmounts amounts,@JsonKey(name: 'free_delivery') FreeDeliveryProgress? freeDelivery, String? warning, List<String> warnings
});


$CartAmountsCopyWith<$Res> get amounts;$FreeDeliveryProgressCopyWith<$Res>? get freeDelivery;

}
/// @nodoc
class _$CartCopyWithImpl<$Res>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = freezed,Object? quantity = null,Object? lines = null,Object? amounts = null,Object? freeDelivery = freezed,Object? warning = freezed,Object? warnings = null,}) {
  return _then(Cart(
orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as CartAmounts,freeDelivery: freezed == freeDelivery ? _self.freeDelivery : freeDelivery // ignore: cast_nullable_to_non_nullable
as FreeDeliveryProgress?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartAmountsCopyWith<$Res> get amounts {
  
  return $CartAmountsCopyWith<$Res>(_self.amounts, (value) {
    return _then(_self.copyWith(amounts: value));
  });
}/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FreeDeliveryProgressCopyWith<$Res>? get freeDelivery {
    if (_self.freeDelivery == null) {
    return null;
  }

  return $FreeDeliveryProgressCopyWith<$Res>(_self.freeDelivery!, (value) {
    return _then(_self.copyWith(freeDelivery: value));
  });
}
}


/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cart value)  $default,){
final _that = this;
switch (_that) {
case _Cart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cart value)?  $default,){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  int? orderId,  int quantity,  List<CartLine> lines,  CartAmounts amounts, @JsonKey(name: 'free_delivery')  FreeDeliveryProgress? freeDelivery,  String? warning,  List<String> warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.orderId,_that.quantity,_that.lines,_that.amounts,_that.freeDelivery,_that.warning,_that.warnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  int? orderId,  int quantity,  List<CartLine> lines,  CartAmounts amounts, @JsonKey(name: 'free_delivery')  FreeDeliveryProgress? freeDelivery,  String? warning,  List<String> warnings)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.orderId,_that.quantity,_that.lines,_that.amounts,_that.freeDelivery,_that.warning,_that.warnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'order_id')  int? orderId,  int quantity,  List<CartLine> lines,  CartAmounts amounts, @JsonKey(name: 'free_delivery')  FreeDeliveryProgress? freeDelivery,  String? warning,  List<String> warnings)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.orderId,_that.quantity,_that.lines,_that.amounts,_that.freeDelivery,_that.warning,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cart extends Cart {
  const _Cart({@JsonKey(name: 'order_id') this.orderId, this.quantity = 0,  List<CartLine> lines = const [], required this.amounts, @JsonKey(name: 'free_delivery') this.freeDelivery, this.warning,  List<String> warnings = const []}): _lines = lines,_warnings = warnings,super._();
  factory _Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

@override@JsonKey(name: 'order_id') final  int? orderId;
@override@JsonKey() final  int quantity;
 final  List<CartLine> _lines;
@override@JsonKey() List<CartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  CartAmounts amounts;
@override@JsonKey(name: 'free_delivery') final  FreeDeliveryProgress? freeDelivery;
@override final  String? warning;
/// Avertismentele stranse de server la ultima modificare (stoc ajustat, cantitate
/// redusa). Vin o singura data, in raspunsul modificarii - un `GET /cart` de dupa
/// nu le mai contine.
 final  List<String> _warnings;
/// Avertismentele stranse de server la ultima modificare (stoc ajustat, cantitate
/// redusa). Vin o singura data, in raspunsul modificarii - un `GET /cart` de dupa
/// nu le mai contine.
@override@JsonKey() List<String> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}


/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartCopyWith<_Cart> get copyWith => __$CartCopyWithImpl<_Cart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.amounts, amounts) || other.amounts == amounts)&&(identical(other.freeDelivery, freeDelivery) || other.freeDelivery == freeDelivery)&&(identical(other.warning, warning) || other.warning == warning)&&const DeepCollectionEquality().equals(other.warnings, _warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderId,quantity,const DeepCollectionEquality().hash(_lines),amounts,freeDelivery,warning,const DeepCollectionEquality().hash(_warnings));
}

@override
String toString() {
    return 'Cart(orderId: $orderId, quantity: $quantity, lines: $lines, amounts: $amounts, freeDelivery: $freeDelivery, warning: $warning, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'order_id') int? orderId, int quantity, List<CartLine> lines, CartAmounts amounts,@JsonKey(name: 'free_delivery') FreeDeliveryProgress? freeDelivery, String? warning, List<String> warnings
});


@override $CartAmountsCopyWith<$Res> get amounts;@override $FreeDeliveryProgressCopyWith<$Res>? get freeDelivery;

}
/// @nodoc
class __$CartCopyWithImpl<$Res>
    implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = freezed,Object? quantity = null,Object? lines = null,Object? amounts = null,Object? freeDelivery = freezed,Object? warning = freezed,Object? warnings = null,}) {
  return _then(_Cart(
orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as CartAmounts,freeDelivery: freezed == freeDelivery ? _self.freeDelivery : freeDelivery // ignore: cast_nullable_to_non_nullable
as FreeDeliveryProgress?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartAmountsCopyWith<$Res> get amounts {
  
  return $CartAmountsCopyWith<$Res>(_self.amounts, (value) {
    return _then(_self.copyWith(amounts: value));
  });
}/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FreeDeliveryProgressCopyWith<$Res>? get freeDelivery {
    if (_self.freeDelivery == null) {
    return null;
  }

  return $FreeDeliveryProgressCopyWith<$Res>(_self.freeDelivery!, (value) {
    return _then(_self.copyWith(freeDelivery: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Price {

 double get amount; String get currency; String get formatted;@JsonKey(name: 'with_vat') bool get withVat;@JsonKey(name: 'list_amount') double? get listAmount;@JsonKey(name: 'list_formatted') String? get listFormatted;@JsonKey(name: 'discount_pct') int? get discountPct;
/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceCopyWith<Price> get copyWith => _$PriceCopyWithImpl<Price>(this as Price, _$identity);

  /// Serializes this Price to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Price;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Price&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.formatted, _this.formatted) || other.formatted == _this.formatted)&&(identical(other.withVat, _this.withVat) || other.withVat == _this.withVat)&&(identical(other.listAmount, _this.listAmount) || other.listAmount == _this.listAmount)&&(identical(other.listFormatted, _this.listFormatted) || other.listFormatted == _this.listFormatted)&&(identical(other.discountPct, _this.discountPct) || other.discountPct == _this.discountPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Price;
  return Object.hash(runtimeType,_this.amount,_this.currency,_this.formatted,_this.withVat,_this.listAmount,_this.listFormatted,_this.discountPct);
}

@override
String toString() {
  final _this = this as Price;
  return 'Price(amount: ${_this.amount}, currency: ${_this.currency}, formatted: ${_this.formatted}, withVat: ${_this.withVat}, listAmount: ${_this.listAmount}, listFormatted: ${_this.listFormatted}, discountPct: ${_this.discountPct})';
}


}

/// @nodoc
abstract mixin class $PriceCopyWith<$Res>  {
  factory $PriceCopyWith(Price value, $Res Function(Price) _then) = _$PriceCopyWithImpl;
@useResult
$Res call({
 double amount, String currency, String formatted,@JsonKey(name: 'with_vat') bool withVat,@JsonKey(name: 'list_amount') double? listAmount,@JsonKey(name: 'list_formatted') String? listFormatted,@JsonKey(name: 'discount_pct') int? discountPct
});




}
/// @nodoc
class _$PriceCopyWithImpl<$Res>
    implements $PriceCopyWith<$Res> {
  _$PriceCopyWithImpl(this._self, this._then);

  final Price _self;
  final $Res Function(Price) _then;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? currency = null,Object? formatted = null,Object? withVat = null,Object? listAmount = freezed,Object? listFormatted = freezed,Object? discountPct = freezed,}) {
  return _then(Price(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,formatted: null == formatted ? _self.formatted : formatted // ignore: cast_nullable_to_non_nullable
as String,withVat: null == withVat ? _self.withVat : withVat // ignore: cast_nullable_to_non_nullable
as bool,listAmount: freezed == listAmount ? _self.listAmount : listAmount // ignore: cast_nullable_to_non_nullable
as double?,listFormatted: freezed == listFormatted ? _self.listFormatted : listFormatted // ignore: cast_nullable_to_non_nullable
as String?,discountPct: freezed == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Price].
extension PricePatterns on Price {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Price value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Price() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Price value)  $default,){
final _that = this;
switch (_that) {
case _Price():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Price value)?  $default,){
final _that = this;
switch (_that) {
case _Price() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double amount,  String currency,  String formatted, @JsonKey(name: 'with_vat')  bool withVat, @JsonKey(name: 'list_amount')  double? listAmount, @JsonKey(name: 'list_formatted')  String? listFormatted, @JsonKey(name: 'discount_pct')  int? discountPct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that.amount,_that.currency,_that.formatted,_that.withVat,_that.listAmount,_that.listFormatted,_that.discountPct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double amount,  String currency,  String formatted, @JsonKey(name: 'with_vat')  bool withVat, @JsonKey(name: 'list_amount')  double? listAmount, @JsonKey(name: 'list_formatted')  String? listFormatted, @JsonKey(name: 'discount_pct')  int? discountPct)  $default,) {final _that = this;
switch (_that) {
case _Price():
return $default(_that.amount,_that.currency,_that.formatted,_that.withVat,_that.listAmount,_that.listFormatted,_that.discountPct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double amount,  String currency,  String formatted, @JsonKey(name: 'with_vat')  bool withVat, @JsonKey(name: 'list_amount')  double? listAmount, @JsonKey(name: 'list_formatted')  String? listFormatted, @JsonKey(name: 'discount_pct')  int? discountPct)?  $default,) {final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that.amount,_that.currency,_that.formatted,_that.withVat,_that.listAmount,_that.listFormatted,_that.discountPct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Price implements Price {
  const _Price({required this.amount, required this.currency, required this.formatted, @JsonKey(name: 'with_vat') this.withVat = true, @JsonKey(name: 'list_amount') this.listAmount, @JsonKey(name: 'list_formatted') this.listFormatted, @JsonKey(name: 'discount_pct') this.discountPct});
  factory _Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

@override final  double amount;
@override final  String currency;
@override final  String formatted;
@override@JsonKey(name: 'with_vat') final  bool withVat;
@override@JsonKey(name: 'list_amount') final  double? listAmount;
@override@JsonKey(name: 'list_formatted') final  String? listFormatted;
@override@JsonKey(name: 'discount_pct') final  int? discountPct;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceCopyWith<_Price> get copyWith => __$PriceCopyWithImpl<_Price>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Price&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.formatted, formatted) || other.formatted == formatted)&&(identical(other.withVat, withVat) || other.withVat == withVat)&&(identical(other.listAmount, listAmount) || other.listAmount == listAmount)&&(identical(other.listFormatted, listFormatted) || other.listFormatted == listFormatted)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,amount,currency,formatted,withVat,listAmount,listFormatted,discountPct);
}

@override
String toString() {
    return 'Price(amount: $amount, currency: $currency, formatted: $formatted, withVat: $withVat, listAmount: $listAmount, listFormatted: $listFormatted, discountPct: $discountPct)';
}


}

/// @nodoc
abstract mixin class _$PriceCopyWith<$Res> implements $PriceCopyWith<$Res> {
  factory _$PriceCopyWith(_Price value, $Res Function(_Price) _then) = __$PriceCopyWithImpl;
@override @useResult
$Res call({
 double amount, String currency, String formatted,@JsonKey(name: 'with_vat') bool withVat,@JsonKey(name: 'list_amount') double? listAmount,@JsonKey(name: 'list_formatted') String? listFormatted,@JsonKey(name: 'discount_pct') int? discountPct
});




}
/// @nodoc
class __$PriceCopyWithImpl<$Res>
    implements _$PriceCopyWith<$Res> {
  __$PriceCopyWithImpl(this._self, this._then);

  final _Price _self;
  final $Res Function(_Price) _then;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? currency = null,Object? formatted = null,Object? withVat = null,Object? listAmount = freezed,Object? listFormatted = freezed,Object? discountPct = freezed,}) {
  return _then(_Price(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,formatted: null == formatted ? _self.formatted : formatted // ignore: cast_nullable_to_non_nullable
as String,withVat: null == withVat ? _self.withVat : withVat // ignore: cast_nullable_to_non_nullable
as bool,listAmount: freezed == listAmount ? _self.listAmount : listAmount // ignore: cast_nullable_to_non_nullable
as double?,listFormatted: freezed == listFormatted ? _self.listFormatted : listFormatted // ignore: cast_nullable_to_non_nullable
as String?,discountPct: freezed == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_badge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductBadge {

 String get text;@JsonKey(unknownEnumValue: ProductBadgeColor.orange) ProductBadgeColor get color;
/// Create a copy of ProductBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductBadgeCopyWith<ProductBadge> get copyWith => _$ProductBadgeCopyWithImpl<ProductBadge>(this as ProductBadge, _$identity);

  /// Serializes this ProductBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductBadge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductBadge&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.color, _this.color) || other.color == _this.color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductBadge;
  return Object.hash(runtimeType,_this.text,_this.color);
}

@override
String toString() {
  final _this = this as ProductBadge;
  return 'ProductBadge(text: ${_this.text}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $ProductBadgeCopyWith<$Res>  {
  factory $ProductBadgeCopyWith(ProductBadge value, $Res Function(ProductBadge) _then) = _$ProductBadgeCopyWithImpl;
@useResult
$Res call({
 String text,@JsonKey(unknownEnumValue: ProductBadgeColor.orange) ProductBadgeColor color
});




}
/// @nodoc
class _$ProductBadgeCopyWithImpl<$Res>
    implements $ProductBadgeCopyWith<$Res> {
  _$ProductBadgeCopyWithImpl(this._self, this._then);

  final ProductBadge _self;
  final $Res Function(ProductBadge) _then;

/// Create a copy of ProductBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? color = null,}) {
  return _then(ProductBadge(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as ProductBadgeColor,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductBadge].
extension ProductBadgePatterns on ProductBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductBadge value)  $default,){
final _that = this;
switch (_that) {
case _ProductBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductBadge value)?  $default,){
final _that = this;
switch (_that) {
case _ProductBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text, @JsonKey(unknownEnumValue: ProductBadgeColor.orange)  ProductBadgeColor color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductBadge() when $default != null:
return $default(_that.text,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text, @JsonKey(unknownEnumValue: ProductBadgeColor.orange)  ProductBadgeColor color)  $default,) {final _that = this;
switch (_that) {
case _ProductBadge():
return $default(_that.text,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text, @JsonKey(unknownEnumValue: ProductBadgeColor.orange)  ProductBadgeColor color)?  $default,) {final _that = this;
switch (_that) {
case _ProductBadge() when $default != null:
return $default(_that.text,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductBadge implements ProductBadge {
  const _ProductBadge({required this.text, @JsonKey(unknownEnumValue: ProductBadgeColor.orange) required this.color});
  factory _ProductBadge.fromJson(Map<String, dynamic> json) => _$ProductBadgeFromJson(json);

@override final  String text;
@override@JsonKey(unknownEnumValue: ProductBadgeColor.orange) final  ProductBadgeColor color;

/// Create a copy of ProductBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductBadgeCopyWith<_ProductBadge> get copyWith => __$ProductBadgeCopyWithImpl<_ProductBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductBadge&&(identical(other.text, text) || other.text == text)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,color);
}

@override
String toString() {
    return 'ProductBadge(text: $text, color: $color)';
}


}

/// @nodoc
abstract mixin class _$ProductBadgeCopyWith<$Res> implements $ProductBadgeCopyWith<$Res> {
  factory _$ProductBadgeCopyWith(_ProductBadge value, $Res Function(_ProductBadge) _then) = __$ProductBadgeCopyWithImpl;
@override @useResult
$Res call({
 String text,@JsonKey(unknownEnumValue: ProductBadgeColor.orange) ProductBadgeColor color
});




}
/// @nodoc
class __$ProductBadgeCopyWithImpl<$Res>
    implements _$ProductBadgeCopyWith<$Res> {
  __$ProductBadgeCopyWithImpl(this._self, this._then);

  final _ProductBadge _self;
  final $Res Function(_ProductBadge) _then;

/// Create a copy of ProductBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? color = null,}) {
  return _then(_ProductBadge(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as ProductBadgeColor,
  ));
}


}

// dart format on

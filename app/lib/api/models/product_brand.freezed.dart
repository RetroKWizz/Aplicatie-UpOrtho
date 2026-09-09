// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_brand.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductBrand {

 String get name; List<DescriptionBlock> get description;@JsonKey(name: 'logo_url') String? get logoUrl;
/// Create a copy of ProductBrand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductBrandCopyWith<ProductBrand> get copyWith => _$ProductBrandCopyWithImpl<ProductBrand>(this as ProductBrand, _$identity);

  /// Serializes this ProductBrand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductBrand;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductBrand&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.description, _this.description)&&(identical(other.logoUrl, _this.logoUrl) || other.logoUrl == _this.logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductBrand;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.description),_this.logoUrl);
}

@override
String toString() {
  final _this = this as ProductBrand;
  return 'ProductBrand(name: ${_this.name}, description: ${_this.description}, logoUrl: ${_this.logoUrl})';
}


}

/// @nodoc
abstract mixin class $ProductBrandCopyWith<$Res>  {
  factory $ProductBrandCopyWith(ProductBrand value, $Res Function(ProductBrand) _then) = _$ProductBrandCopyWithImpl;
@useResult
$Res call({
 String name, List<DescriptionBlock> description,@JsonKey(name: 'logo_url') String? logoUrl
});




}
/// @nodoc
class _$ProductBrandCopyWithImpl<$Res>
    implements $ProductBrandCopyWith<$Res> {
  _$ProductBrandCopyWithImpl(this._self, this._then);

  final ProductBrand _self;
  final $Res Function(ProductBrand) _then;

/// Create a copy of ProductBrand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? logoUrl = freezed,}) {
  return _then(ProductBrand(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductBrand].
extension ProductBrandPatterns on ProductBrand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductBrand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductBrand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductBrand value)  $default,){
final _that = this;
switch (_that) {
case _ProductBrand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductBrand value)?  $default,){
final _that = this;
switch (_that) {
case _ProductBrand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<DescriptionBlock> description, @JsonKey(name: 'logo_url')  String? logoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductBrand() when $default != null:
return $default(_that.name,_that.description,_that.logoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<DescriptionBlock> description, @JsonKey(name: 'logo_url')  String? logoUrl)  $default,) {final _that = this;
switch (_that) {
case _ProductBrand():
return $default(_that.name,_that.description,_that.logoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<DescriptionBlock> description, @JsonKey(name: 'logo_url')  String? logoUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProductBrand() when $default != null:
return $default(_that.name,_that.description,_that.logoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductBrand implements ProductBrand {
  const _ProductBrand({required this.name,  List<DescriptionBlock> description = const [], @JsonKey(name: 'logo_url') this.logoUrl}): _description = description;
  factory _ProductBrand.fromJson(Map<String, dynamic> json) => _$ProductBrandFromJson(json);

@override final  String name;
 final  List<DescriptionBlock> _description;
@override@JsonKey() List<DescriptionBlock> get description {
  if (_description is EqualUnmodifiableListView) return _description;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_description);
}

@override@JsonKey(name: 'logo_url') final  String? logoUrl;

/// Create a copy of ProductBrand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductBrandCopyWith<_ProductBrand> get copyWith => __$ProductBrandCopyWithImpl<_ProductBrand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductBrandToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductBrand&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.description, _description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_description),logoUrl);
}

@override
String toString() {
    return 'ProductBrand(name: $name, description: $description, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductBrandCopyWith<$Res> implements $ProductBrandCopyWith<$Res> {
  factory _$ProductBrandCopyWith(_ProductBrand value, $Res Function(_ProductBrand) _then) = __$ProductBrandCopyWithImpl;
@override @useResult
$Res call({
 String name, List<DescriptionBlock> description,@JsonKey(name: 'logo_url') String? logoUrl
});




}
/// @nodoc
class __$ProductBrandCopyWithImpl<$Res>
    implements _$ProductBrandCopyWith<$Res> {
  __$ProductBrandCopyWithImpl(this._self, this._then);

  final _ProductBrand _self;
  final $Res Function(_ProductBrand) _then;

/// Create a copy of ProductBrand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? logoUrl = freezed,}) {
  return _then(_ProductBrand(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self._description : description // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

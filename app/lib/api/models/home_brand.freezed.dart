// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_brand.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeBrand {

 int get id;@JsonKey(name: 'attribute_id') int get attributeId; String get name;@JsonKey(name: 'product_count') int get productCount;@JsonKey(name: 'logo_url') String? get logoUrl;
/// Create a copy of HomeBrand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeBrandCopyWith<HomeBrand> get copyWith => _$HomeBrandCopyWithImpl<HomeBrand>(this as HomeBrand, _$identity);

  /// Serializes this HomeBrand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeBrand;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeBrand&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.attributeId, _this.attributeId) || other.attributeId == _this.attributeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.productCount, _this.productCount) || other.productCount == _this.productCount)&&(identical(other.logoUrl, _this.logoUrl) || other.logoUrl == _this.logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeBrand;
  return Object.hash(runtimeType,_this.id,_this.attributeId,_this.name,_this.productCount,_this.logoUrl);
}

@override
String toString() {
  final _this = this as HomeBrand;
  return 'HomeBrand(id: ${_this.id}, attributeId: ${_this.attributeId}, name: ${_this.name}, productCount: ${_this.productCount}, logoUrl: ${_this.logoUrl})';
}


}

/// @nodoc
abstract mixin class $HomeBrandCopyWith<$Res>  {
  factory $HomeBrandCopyWith(HomeBrand value, $Res Function(HomeBrand) _then) = _$HomeBrandCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'attribute_id') int attributeId, String name,@JsonKey(name: 'product_count') int productCount,@JsonKey(name: 'logo_url') String? logoUrl
});




}
/// @nodoc
class _$HomeBrandCopyWithImpl<$Res>
    implements $HomeBrandCopyWith<$Res> {
  _$HomeBrandCopyWithImpl(this._self, this._then);

  final HomeBrand _self;
  final $Res Function(HomeBrand) _then;

/// Create a copy of HomeBrand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attributeId = null,Object? name = null,Object? productCount = null,Object? logoUrl = freezed,}) {
  return _then(HomeBrand(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,attributeId: null == attributeId ? _self.attributeId : attributeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeBrand].
extension HomeBrandPatterns on HomeBrand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeBrand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeBrand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeBrand value)  $default,){
final _that = this;
switch (_that) {
case _HomeBrand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeBrand value)?  $default,){
final _that = this;
switch (_that) {
case _HomeBrand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'attribute_id')  int attributeId,  String name, @JsonKey(name: 'product_count')  int productCount, @JsonKey(name: 'logo_url')  String? logoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeBrand() when $default != null:
return $default(_that.id,_that.attributeId,_that.name,_that.productCount,_that.logoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'attribute_id')  int attributeId,  String name, @JsonKey(name: 'product_count')  int productCount, @JsonKey(name: 'logo_url')  String? logoUrl)  $default,) {final _that = this;
switch (_that) {
case _HomeBrand():
return $default(_that.id,_that.attributeId,_that.name,_that.productCount,_that.logoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'attribute_id')  int attributeId,  String name, @JsonKey(name: 'product_count')  int productCount, @JsonKey(name: 'logo_url')  String? logoUrl)?  $default,) {final _that = this;
switch (_that) {
case _HomeBrand() when $default != null:
return $default(_that.id,_that.attributeId,_that.name,_that.productCount,_that.logoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeBrand implements HomeBrand {
  const _HomeBrand({required this.id, @JsonKey(name: 'attribute_id') required this.attributeId, required this.name, @JsonKey(name: 'product_count') this.productCount = 0, @JsonKey(name: 'logo_url') this.logoUrl});
  factory _HomeBrand.fromJson(Map<String, dynamic> json) => _$HomeBrandFromJson(json);

@override final  int id;
@override@JsonKey(name: 'attribute_id') final  int attributeId;
@override final  String name;
@override@JsonKey(name: 'product_count') final  int productCount;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;

/// Create a copy of HomeBrand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeBrandCopyWith<_HomeBrand> get copyWith => __$HomeBrandCopyWithImpl<_HomeBrand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeBrandToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeBrand&&(identical(other.id, id) || other.id == id)&&(identical(other.attributeId, attributeId) || other.attributeId == attributeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,attributeId,name,productCount,logoUrl);
}

@override
String toString() {
    return 'HomeBrand(id: $id, attributeId: $attributeId, name: $name, productCount: $productCount, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class _$HomeBrandCopyWith<$Res> implements $HomeBrandCopyWith<$Res> {
  factory _$HomeBrandCopyWith(_HomeBrand value, $Res Function(_HomeBrand) _then) = __$HomeBrandCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'attribute_id') int attributeId, String name,@JsonKey(name: 'product_count') int productCount,@JsonKey(name: 'logo_url') String? logoUrl
});




}
/// @nodoc
class __$HomeBrandCopyWithImpl<$Res>
    implements _$HomeBrandCopyWith<$Res> {
  __$HomeBrandCopyWithImpl(this._self, this._then);

  final _HomeBrand _self;
  final $Res Function(_HomeBrand) _then;

/// Create a copy of HomeBrand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attributeId = null,Object? name = null,Object? productCount = null,Object? logoUrl = freezed,}) {
  return _then(_HomeBrand(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,attributeId: null == attributeId ? _self.attributeId : attributeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

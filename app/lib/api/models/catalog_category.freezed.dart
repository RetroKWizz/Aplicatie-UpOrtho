// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogCategory {

 int get id; String get name;@JsonKey(name: 'parent_id') int? get parentId;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'product_count') int get productCount;
/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogCategoryCopyWith<CatalogCategory> get copyWith => _$CatalogCategoryCopyWithImpl<CatalogCategory>(this as CatalogCategory, _$identity);

  /// Serializes this CatalogCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.iconUrl, _this.iconUrl) || other.iconUrl == _this.iconUrl)&&(identical(other.productCount, _this.productCount) || other.productCount == _this.productCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogCategory;
  return Object.hash(runtimeType,_this.id,_this.name,_this.parentId,_this.iconUrl,_this.productCount);
}

@override
String toString() {
  final _this = this as CatalogCategory;
  return 'CatalogCategory(id: ${_this.id}, name: ${_this.name}, parentId: ${_this.parentId}, iconUrl: ${_this.iconUrl}, productCount: ${_this.productCount})';
}


}

/// @nodoc
abstract mixin class $CatalogCategoryCopyWith<$Res>  {
  factory $CatalogCategoryCopyWith(CatalogCategory value, $Res Function(CatalogCategory) _then) = _$CatalogCategoryCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'parent_id') int? parentId,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'product_count') int productCount
});




}
/// @nodoc
class _$CatalogCategoryCopyWithImpl<$Res>
    implements $CatalogCategoryCopyWith<$Res> {
  _$CatalogCategoryCopyWithImpl(this._self, this._then);

  final CatalogCategory _self;
  final $Res Function(CatalogCategory) _then;

/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? iconUrl = freezed,Object? productCount = null,}) {
  return _then(CatalogCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogCategory].
extension CatalogCategoryPatterns on CatalogCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogCategory value)  $default,){
final _that = this;
switch (_that) {
case _CatalogCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogCategory value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'parent_id')  int? parentId, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'product_count')  int productCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.iconUrl,_that.productCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'parent_id')  int? parentId, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'product_count')  int productCount)  $default,) {final _that = this;
switch (_that) {
case _CatalogCategory():
return $default(_that.id,_that.name,_that.parentId,_that.iconUrl,_that.productCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'parent_id')  int? parentId, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'product_count')  int productCount)?  $default,) {final _that = this;
switch (_that) {
case _CatalogCategory() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.iconUrl,_that.productCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogCategory implements CatalogCategory {
  const _CatalogCategory({required this.id, required this.name, @JsonKey(name: 'parent_id') this.parentId, @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'product_count') required this.productCount});
  factory _CatalogCategory.fromJson(Map<String, dynamic> json) => _$CatalogCategoryFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'parent_id') final  int? parentId;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'product_count') final  int productCount;

/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogCategoryCopyWith<_CatalogCategory> get copyWith => __$CatalogCategoryCopyWithImpl<_CatalogCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.productCount, productCount) || other.productCount == productCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,parentId,iconUrl,productCount);
}

@override
String toString() {
    return 'CatalogCategory(id: $id, name: $name, parentId: $parentId, iconUrl: $iconUrl, productCount: $productCount)';
}


}

/// @nodoc
abstract mixin class _$CatalogCategoryCopyWith<$Res> implements $CatalogCategoryCopyWith<$Res> {
  factory _$CatalogCategoryCopyWith(_CatalogCategory value, $Res Function(_CatalogCategory) _then) = __$CatalogCategoryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'parent_id') int? parentId,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'product_count') int productCount
});




}
/// @nodoc
class __$CatalogCategoryCopyWithImpl<$Res>
    implements _$CatalogCategoryCopyWith<$Res> {
  __$CatalogCategoryCopyWithImpl(this._self, this._then);

  final _CatalogCategory _self;
  final $Res Function(_CatalogCategory) _then;

/// Create a copy of CatalogCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? iconUrl = freezed,Object? productCount = null,}) {
  return _then(_CatalogCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

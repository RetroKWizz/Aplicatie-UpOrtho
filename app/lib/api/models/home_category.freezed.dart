// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeCategory {

 int get id; String get name;@JsonKey(name: 'icon_url') String? get iconUrl;
/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCategoryCopyWith<HomeCategory> get copyWith => _$HomeCategoryCopyWithImpl<HomeCategory>(this as HomeCategory, _$identity);

  /// Serializes this HomeCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconUrl, _this.iconUrl) || other.iconUrl == _this.iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeCategory;
  return Object.hash(runtimeType,_this.id,_this.name,_this.iconUrl);
}

@override
String toString() {
  final _this = this as HomeCategory;
  return 'HomeCategory(id: ${_this.id}, name: ${_this.name}, iconUrl: ${_this.iconUrl})';
}


}

/// @nodoc
abstract mixin class $HomeCategoryCopyWith<$Res>  {
  factory $HomeCategoryCopyWith(HomeCategory value, $Res Function(HomeCategory) _then) = _$HomeCategoryCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'icon_url') String? iconUrl
});




}
/// @nodoc
class _$HomeCategoryCopyWithImpl<$Res>
    implements $HomeCategoryCopyWith<$Res> {
  _$HomeCategoryCopyWithImpl(this._self, this._then);

  final HomeCategory _self;
  final $Res Function(HomeCategory) _then;

/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,}) {
  return _then(HomeCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeCategory].
extension HomeCategoryPatterns on HomeCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeCategory value)  $default,){
final _that = this;
switch (_that) {
case _HomeCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeCategory value)?  $default,){
final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'icon_url')  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'icon_url')  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _HomeCategory():
return $default(_that.id,_that.name,_that.iconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'icon_url')  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _HomeCategory() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeCategory implements HomeCategory {
  const _HomeCategory({required this.id, required this.name, @JsonKey(name: 'icon_url') this.iconUrl});
  factory _HomeCategory.fromJson(Map<String, dynamic> json) => _$HomeCategoryFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;

/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeCategoryCopyWith<_HomeCategory> get copyWith => __$HomeCategoryCopyWithImpl<_HomeCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,iconUrl);
}

@override
String toString() {
    return 'HomeCategory(id: $id, name: $name, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$HomeCategoryCopyWith<$Res> implements $HomeCategoryCopyWith<$Res> {
  factory _$HomeCategoryCopyWith(_HomeCategory value, $Res Function(_HomeCategory) _then) = __$HomeCategoryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'icon_url') String? iconUrl
});




}
/// @nodoc
class __$HomeCategoryCopyWithImpl<$Res>
    implements _$HomeCategoryCopyWith<$Res> {
  __$HomeCategoryCopyWithImpl(this._self, this._then);

  final _HomeCategory _self;
  final $Res Function(_HomeCategory) _then;

/// Create a copy of HomeCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,}) {
  return _then(_HomeCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

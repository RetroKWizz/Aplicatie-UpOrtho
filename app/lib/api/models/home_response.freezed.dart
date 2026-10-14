// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeResponse {

 List<AppBanner> get banners;@JsonKey(name: 'quick_categories') List<HomeCategory> get quickCategories; List<HomeBrand> get brands; List<HomeSection> get sections;
/// Create a copy of HomeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeResponseCopyWith<HomeResponse> get copyWith => _$HomeResponseCopyWithImpl<HomeResponse>(this as HomeResponse, _$identity);

  /// Serializes this HomeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeResponse&&const DeepCollectionEquality().equals(other.banners, _this.banners)&&const DeepCollectionEquality().equals(other.quickCategories, _this.quickCategories)&&const DeepCollectionEquality().equals(other.brands, _this.brands)&&const DeepCollectionEquality().equals(other.sections, _this.sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.banners),const DeepCollectionEquality().hash(_this.quickCategories),const DeepCollectionEquality().hash(_this.brands),const DeepCollectionEquality().hash(_this.sections));
}

@override
String toString() {
  final _this = this as HomeResponse;
  return 'HomeResponse(banners: ${_this.banners}, quickCategories: ${_this.quickCategories}, brands: ${_this.brands}, sections: ${_this.sections})';
}


}

/// @nodoc
abstract mixin class $HomeResponseCopyWith<$Res>  {
  factory $HomeResponseCopyWith(HomeResponse value, $Res Function(HomeResponse) _then) = _$HomeResponseCopyWithImpl;
@useResult
$Res call({
 List<AppBanner> banners,@JsonKey(name: 'quick_categories') List<HomeCategory> quickCategories, List<HomeBrand> brands, List<HomeSection> sections
});




}
/// @nodoc
class _$HomeResponseCopyWithImpl<$Res>
    implements $HomeResponseCopyWith<$Res> {
  _$HomeResponseCopyWithImpl(this._self, this._then);

  final HomeResponse _self;
  final $Res Function(HomeResponse) _then;

/// Create a copy of HomeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? banners = null,Object? quickCategories = null,Object? brands = null,Object? sections = null,}) {
  return _then(HomeResponse(
banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<AppBanner>,quickCategories: null == quickCategories ? _self.quickCategories : quickCategories // ignore: cast_nullable_to_non_nullable
as List<HomeCategory>,brands: null == brands ? _self.brands : brands // ignore: cast_nullable_to_non_nullable
as List<HomeBrand>,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<HomeSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeResponse].
extension HomeResponsePatterns on HomeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeResponse value)  $default,){
final _that = this;
switch (_that) {
case _HomeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _HomeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AppBanner> banners, @JsonKey(name: 'quick_categories')  List<HomeCategory> quickCategories,  List<HomeBrand> brands,  List<HomeSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeResponse() when $default != null:
return $default(_that.banners,_that.quickCategories,_that.brands,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AppBanner> banners, @JsonKey(name: 'quick_categories')  List<HomeCategory> quickCategories,  List<HomeBrand> brands,  List<HomeSection> sections)  $default,) {final _that = this;
switch (_that) {
case _HomeResponse():
return $default(_that.banners,_that.quickCategories,_that.brands,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AppBanner> banners, @JsonKey(name: 'quick_categories')  List<HomeCategory> quickCategories,  List<HomeBrand> brands,  List<HomeSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _HomeResponse() when $default != null:
return $default(_that.banners,_that.quickCategories,_that.brands,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeResponse implements HomeResponse {
  const _HomeResponse({ List<AppBanner> banners = const [], @JsonKey(name: 'quick_categories')  List<HomeCategory> quickCategories = const [],  List<HomeBrand> brands = const [],  List<HomeSection> sections = const []}): _banners = banners,_quickCategories = quickCategories,_brands = brands,_sections = sections;
  factory _HomeResponse.fromJson(Map<String, dynamic> json) => _$HomeResponseFromJson(json);

 final  List<AppBanner> _banners;
@override@JsonKey() List<AppBanner> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

 final  List<HomeCategory> _quickCategories;
@override@JsonKey(name: 'quick_categories') List<HomeCategory> get quickCategories {
  if (_quickCategories is EqualUnmodifiableListView) return _quickCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickCategories);
}

 final  List<HomeBrand> _brands;
@override@JsonKey() List<HomeBrand> get brands {
  if (_brands is EqualUnmodifiableListView) return _brands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_brands);
}

 final  List<HomeSection> _sections;
@override@JsonKey() List<HomeSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of HomeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeResponseCopyWith<_HomeResponse> get copyWith => __$HomeResponseCopyWithImpl<_HomeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeResponse&&const DeepCollectionEquality().equals(other.banners, _banners)&&const DeepCollectionEquality().equals(other.quickCategories, _quickCategories)&&const DeepCollectionEquality().equals(other.brands, _brands)&&const DeepCollectionEquality().equals(other.sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_banners),const DeepCollectionEquality().hash(_quickCategories),const DeepCollectionEquality().hash(_brands),const DeepCollectionEquality().hash(_sections));
}

@override
String toString() {
    return 'HomeResponse(banners: $banners, quickCategories: $quickCategories, brands: $brands, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$HomeResponseCopyWith<$Res> implements $HomeResponseCopyWith<$Res> {
  factory _$HomeResponseCopyWith(_HomeResponse value, $Res Function(_HomeResponse) _then) = __$HomeResponseCopyWithImpl;
@override @useResult
$Res call({
 List<AppBanner> banners,@JsonKey(name: 'quick_categories') List<HomeCategory> quickCategories, List<HomeBrand> brands, List<HomeSection> sections
});




}
/// @nodoc
class __$HomeResponseCopyWithImpl<$Res>
    implements _$HomeResponseCopyWith<$Res> {
  __$HomeResponseCopyWithImpl(this._self, this._then);

  final _HomeResponse _self;
  final $Res Function(_HomeResponse) _then;

/// Create a copy of HomeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? banners = null,Object? quickCategories = null,Object? brands = null,Object? sections = null,}) {
  return _then(_HomeResponse(
banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<AppBanner>,quickCategories: null == quickCategories ? _self._quickCategories : quickCategories // ignore: cast_nullable_to_non_nullable
as List<HomeCategory>,brands: null == brands ? _self._brands : brands // ignore: cast_nullable_to_non_nullable
as List<HomeBrand>,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<HomeSection>,
  ));
}


}

// dart format on

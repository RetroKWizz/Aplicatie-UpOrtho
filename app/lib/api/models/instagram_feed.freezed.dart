// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instagram_feed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstagramFeed {

 String get username;@JsonKey(name: 'embed_url') String get embedUrl;@JsonKey(name: 'profile_url') String get profileUrl;
/// Create a copy of InstagramFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstagramFeedCopyWith<InstagramFeed> get copyWith => _$InstagramFeedCopyWithImpl<InstagramFeed>(this as InstagramFeed, _$identity);

  /// Serializes this InstagramFeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InstagramFeed;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstagramFeed&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.embedUrl, _this.embedUrl) || other.embedUrl == _this.embedUrl)&&(identical(other.profileUrl, _this.profileUrl) || other.profileUrl == _this.profileUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InstagramFeed;
  return Object.hash(runtimeType,_this.username,_this.embedUrl,_this.profileUrl);
}

@override
String toString() {
  final _this = this as InstagramFeed;
  return 'InstagramFeed(username: ${_this.username}, embedUrl: ${_this.embedUrl}, profileUrl: ${_this.profileUrl})';
}


}

/// @nodoc
abstract mixin class $InstagramFeedCopyWith<$Res>  {
  factory $InstagramFeedCopyWith(InstagramFeed value, $Res Function(InstagramFeed) _then) = _$InstagramFeedCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'embed_url') String embedUrl,@JsonKey(name: 'profile_url') String profileUrl
});




}
/// @nodoc
class _$InstagramFeedCopyWithImpl<$Res>
    implements $InstagramFeedCopyWith<$Res> {
  _$InstagramFeedCopyWithImpl(this._self, this._then);

  final InstagramFeed _self;
  final $Res Function(InstagramFeed) _then;

/// Create a copy of InstagramFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? embedUrl = null,Object? profileUrl = null,}) {
  return _then(InstagramFeed(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,embedUrl: null == embedUrl ? _self.embedUrl : embedUrl // ignore: cast_nullable_to_non_nullable
as String,profileUrl: null == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InstagramFeed].
extension InstagramFeedPatterns on InstagramFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstagramFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstagramFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstagramFeed value)  $default,){
final _that = this;
switch (_that) {
case _InstagramFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstagramFeed value)?  $default,){
final _that = this;
switch (_that) {
case _InstagramFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'embed_url')  String embedUrl, @JsonKey(name: 'profile_url')  String profileUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstagramFeed() when $default != null:
return $default(_that.username,_that.embedUrl,_that.profileUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'embed_url')  String embedUrl, @JsonKey(name: 'profile_url')  String profileUrl)  $default,) {final _that = this;
switch (_that) {
case _InstagramFeed():
return $default(_that.username,_that.embedUrl,_that.profileUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'embed_url')  String embedUrl, @JsonKey(name: 'profile_url')  String profileUrl)?  $default,) {final _that = this;
switch (_that) {
case _InstagramFeed() when $default != null:
return $default(_that.username,_that.embedUrl,_that.profileUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InstagramFeed implements InstagramFeed {
  const _InstagramFeed({required this.username, @JsonKey(name: 'embed_url') required this.embedUrl, @JsonKey(name: 'profile_url') required this.profileUrl});
  factory _InstagramFeed.fromJson(Map<String, dynamic> json) => _$InstagramFeedFromJson(json);

@override final  String username;
@override@JsonKey(name: 'embed_url') final  String embedUrl;
@override@JsonKey(name: 'profile_url') final  String profileUrl;

/// Create a copy of InstagramFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstagramFeedCopyWith<_InstagramFeed> get copyWith => __$InstagramFeedCopyWithImpl<_InstagramFeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstagramFeedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstagramFeed&&(identical(other.username, username) || other.username == username)&&(identical(other.embedUrl, embedUrl) || other.embedUrl == embedUrl)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,username,embedUrl,profileUrl);
}

@override
String toString() {
    return 'InstagramFeed(username: $username, embedUrl: $embedUrl, profileUrl: $profileUrl)';
}


}

/// @nodoc
abstract mixin class _$InstagramFeedCopyWith<$Res> implements $InstagramFeedCopyWith<$Res> {
  factory _$InstagramFeedCopyWith(_InstagramFeed value, $Res Function(_InstagramFeed) _then) = __$InstagramFeedCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'embed_url') String embedUrl,@JsonKey(name: 'profile_url') String profileUrl
});




}
/// @nodoc
class __$InstagramFeedCopyWithImpl<$Res>
    implements _$InstagramFeedCopyWith<$Res> {
  __$InstagramFeedCopyWithImpl(this._self, this._then);

  final _InstagramFeed _self;
  final $Res Function(_InstagramFeed) _then;

/// Create a copy of InstagramFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? embedUrl = null,Object? profileUrl = null,}) {
  return _then(_InstagramFeed(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,embedUrl: null == embedUrl ? _self.embedUrl : embedUrl // ignore: cast_nullable_to_non_nullable
as String,profileUrl: null == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

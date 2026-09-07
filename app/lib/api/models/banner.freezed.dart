// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BannerLink {

@JsonKey(unknownEnumValue: BannerLinkType.none) BannerLinkType get type;@JsonKey(name: 'category_id') int? get categoryId; String? get url;
/// Create a copy of BannerLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerLinkCopyWith<BannerLink> get copyWith => _$BannerLinkCopyWithImpl<BannerLink>(this as BannerLink, _$identity);

  /// Serializes this BannerLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BannerLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerLink&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BannerLink;
  return Object.hash(runtimeType,_this.type,_this.categoryId,_this.url);
}

@override
String toString() {
  final _this = this as BannerLink;
  return 'BannerLink(type: ${_this.type}, categoryId: ${_this.categoryId}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $BannerLinkCopyWith<$Res>  {
  factory $BannerLinkCopyWith(BannerLink value, $Res Function(BannerLink) _then) = _$BannerLinkCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: BannerLinkType.none) BannerLinkType type,@JsonKey(name: 'category_id') int? categoryId, String? url
});




}
/// @nodoc
class _$BannerLinkCopyWithImpl<$Res>
    implements $BannerLinkCopyWith<$Res> {
  _$BannerLinkCopyWithImpl(this._self, this._then);

  final BannerLink _self;
  final $Res Function(BannerLink) _then;

/// Create a copy of BannerLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? categoryId = freezed,Object? url = freezed,}) {
  return _then(BannerLink(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BannerLinkType,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BannerLink].
extension BannerLinkPatterns on BannerLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerLink value)  $default,){
final _that = this;
switch (_that) {
case _BannerLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerLink value)?  $default,){
final _that = this;
switch (_that) {
case _BannerLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: BannerLinkType.none)  BannerLinkType type, @JsonKey(name: 'category_id')  int? categoryId,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerLink() when $default != null:
return $default(_that.type,_that.categoryId,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: BannerLinkType.none)  BannerLinkType type, @JsonKey(name: 'category_id')  int? categoryId,  String? url)  $default,) {final _that = this;
switch (_that) {
case _BannerLink():
return $default(_that.type,_that.categoryId,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: BannerLinkType.none)  BannerLinkType type, @JsonKey(name: 'category_id')  int? categoryId,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _BannerLink() when $default != null:
return $default(_that.type,_that.categoryId,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerLink implements BannerLink {
  const _BannerLink({@JsonKey(unknownEnumValue: BannerLinkType.none) required this.type, @JsonKey(name: 'category_id') this.categoryId, this.url});
  factory _BannerLink.fromJson(Map<String, dynamic> json) => _$BannerLinkFromJson(json);

@override@JsonKey(unknownEnumValue: BannerLinkType.none) final  BannerLinkType type;
@override@JsonKey(name: 'category_id') final  int? categoryId;
@override final  String? url;

/// Create a copy of BannerLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerLinkCopyWith<_BannerLink> get copyWith => __$BannerLinkCopyWithImpl<_BannerLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerLink&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,categoryId,url);
}

@override
String toString() {
    return 'BannerLink(type: $type, categoryId: $categoryId, url: $url)';
}


}

/// @nodoc
abstract mixin class _$BannerLinkCopyWith<$Res> implements $BannerLinkCopyWith<$Res> {
  factory _$BannerLinkCopyWith(_BannerLink value, $Res Function(_BannerLink) _then) = __$BannerLinkCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: BannerLinkType.none) BannerLinkType type,@JsonKey(name: 'category_id') int? categoryId, String? url
});




}
/// @nodoc
class __$BannerLinkCopyWithImpl<$Res>
    implements _$BannerLinkCopyWith<$Res> {
  __$BannerLinkCopyWithImpl(this._self, this._then);

  final _BannerLink _self;
  final $Res Function(_BannerLink) _then;

/// Create a copy of BannerLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? categoryId = freezed,Object? url = freezed,}) {
  return _then(_BannerLink(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BannerLinkType,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AppBanner {

 int get id; String get title; String? get subtitle;@JsonKey(name: 'cta_text') String? get ctaText;@JsonKey(unknownEnumValue: BannerPlacement.promo) BannerPlacement get placement;@JsonKey(name: 'image_url') String? get imageUrl; BannerLink get link;
/// Create a copy of AppBanner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBannerCopyWith<AppBanner> get copyWith => _$AppBannerCopyWithImpl<AppBanner>(this as AppBanner, _$identity);

  /// Serializes this AppBanner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppBanner;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBanner&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.ctaText, _this.ctaText) || other.ctaText == _this.ctaText)&&(identical(other.placement, _this.placement) || other.placement == _this.placement)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.link, _this.link) || other.link == _this.link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppBanner;
  return Object.hash(runtimeType,_this.id,_this.title,_this.subtitle,_this.ctaText,_this.placement,_this.imageUrl,_this.link);
}

@override
String toString() {
  final _this = this as AppBanner;
  return 'AppBanner(id: ${_this.id}, title: ${_this.title}, subtitle: ${_this.subtitle}, ctaText: ${_this.ctaText}, placement: ${_this.placement}, imageUrl: ${_this.imageUrl}, link: ${_this.link})';
}


}

/// @nodoc
abstract mixin class $AppBannerCopyWith<$Res>  {
  factory $AppBannerCopyWith(AppBanner value, $Res Function(AppBanner) _then) = _$AppBannerCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? subtitle,@JsonKey(name: 'cta_text') String? ctaText,@JsonKey(unknownEnumValue: BannerPlacement.promo) BannerPlacement placement,@JsonKey(name: 'image_url') String? imageUrl, BannerLink link
});


$BannerLinkCopyWith<$Res> get link;

}
/// @nodoc
class _$AppBannerCopyWithImpl<$Res>
    implements $AppBannerCopyWith<$Res> {
  _$AppBannerCopyWithImpl(this._self, this._then);

  final AppBanner _self;
  final $Res Function(AppBanner) _then;

/// Create a copy of AppBanner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = freezed,Object? ctaText = freezed,Object? placement = null,Object? imageUrl = freezed,Object? link = null,}) {
  return _then(AppBanner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,ctaText: freezed == ctaText ? _self.ctaText : ctaText // ignore: cast_nullable_to_non_nullable
as String?,placement: null == placement ? _self.placement : placement // ignore: cast_nullable_to_non_nullable
as BannerPlacement,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as BannerLink,
  ));
}
/// Create a copy of AppBanner
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BannerLinkCopyWith<$Res> get link {
  
  return $BannerLinkCopyWith<$Res>(_self.link, (value) {
    return _then(_self.copyWith(link: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppBanner].
extension AppBannerPatterns on AppBanner {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBanner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBanner() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBanner value)  $default,){
final _that = this;
switch (_that) {
case _AppBanner():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBanner value)?  $default,){
final _that = this;
switch (_that) {
case _AppBanner() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? subtitle, @JsonKey(name: 'cta_text')  String? ctaText, @JsonKey(unknownEnumValue: BannerPlacement.promo)  BannerPlacement placement, @JsonKey(name: 'image_url')  String? imageUrl,  BannerLink link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBanner() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.ctaText,_that.placement,_that.imageUrl,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? subtitle, @JsonKey(name: 'cta_text')  String? ctaText, @JsonKey(unknownEnumValue: BannerPlacement.promo)  BannerPlacement placement, @JsonKey(name: 'image_url')  String? imageUrl,  BannerLink link)  $default,) {final _that = this;
switch (_that) {
case _AppBanner():
return $default(_that.id,_that.title,_that.subtitle,_that.ctaText,_that.placement,_that.imageUrl,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? subtitle, @JsonKey(name: 'cta_text')  String? ctaText, @JsonKey(unknownEnumValue: BannerPlacement.promo)  BannerPlacement placement, @JsonKey(name: 'image_url')  String? imageUrl,  BannerLink link)?  $default,) {final _that = this;
switch (_that) {
case _AppBanner() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.ctaText,_that.placement,_that.imageUrl,_that.link);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppBanner implements AppBanner {
  const _AppBanner({required this.id, required this.title, this.subtitle, @JsonKey(name: 'cta_text') this.ctaText, @JsonKey(unknownEnumValue: BannerPlacement.promo) required this.placement, @JsonKey(name: 'image_url') this.imageUrl, required this.link});
  factory _AppBanner.fromJson(Map<String, dynamic> json) => _$AppBannerFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? subtitle;
@override@JsonKey(name: 'cta_text') final  String? ctaText;
@override@JsonKey(unknownEnumValue: BannerPlacement.promo) final  BannerPlacement placement;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  BannerLink link;

/// Create a copy of AppBanner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBannerCopyWith<_AppBanner> get copyWith => __$AppBannerCopyWithImpl<_AppBanner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppBannerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBanner&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.ctaText, ctaText) || other.ctaText == ctaText)&&(identical(other.placement, placement) || other.placement == placement)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,subtitle,ctaText,placement,imageUrl,link);
}

@override
String toString() {
    return 'AppBanner(id: $id, title: $title, subtitle: $subtitle, ctaText: $ctaText, placement: $placement, imageUrl: $imageUrl, link: $link)';
}


}

/// @nodoc
abstract mixin class _$AppBannerCopyWith<$Res> implements $AppBannerCopyWith<$Res> {
  factory _$AppBannerCopyWith(_AppBanner value, $Res Function(_AppBanner) _then) = __$AppBannerCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? subtitle,@JsonKey(name: 'cta_text') String? ctaText,@JsonKey(unknownEnumValue: BannerPlacement.promo) BannerPlacement placement,@JsonKey(name: 'image_url') String? imageUrl, BannerLink link
});


@override $BannerLinkCopyWith<$Res> get link;

}
/// @nodoc
class __$AppBannerCopyWithImpl<$Res>
    implements _$AppBannerCopyWith<$Res> {
  __$AppBannerCopyWithImpl(this._self, this._then);

  final _AppBanner _self;
  final $Res Function(_AppBanner) _then;

/// Create a copy of AppBanner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = freezed,Object? ctaText = freezed,Object? placement = null,Object? imageUrl = freezed,Object? link = null,}) {
  return _then(_AppBanner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,ctaText: freezed == ctaText ? _self.ctaText : ctaText // ignore: cast_nullable_to_non_nullable
as String?,placement: null == placement ? _self.placement : placement // ignore: cast_nullable_to_non_nullable
as BannerPlacement,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as BannerLink,
  ));
}

/// Create a copy of AppBanner
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BannerLinkCopyWith<$Res> get link {
  
  return $BannerLinkCopyWith<$Res>(_self.link, (value) {
    return _then(_self.copyWith(link: value));
  });
}
}

// dart format on

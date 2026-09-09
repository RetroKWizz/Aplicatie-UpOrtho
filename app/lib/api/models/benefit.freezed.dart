// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Benefit {

@JsonKey(unknownEnumValue: BenefitIcon.info) BenefitIcon get icon; String get title; String? get text;@JsonKey(name: 'image_url') String? get imageUrl;
/// Create a copy of Benefit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitCopyWith<Benefit> get copyWith => _$BenefitCopyWithImpl<Benefit>(this as Benefit, _$identity);

  /// Serializes this Benefit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Benefit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Benefit&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Benefit;
  return Object.hash(runtimeType,_this.icon,_this.title,_this.text,_this.imageUrl);
}

@override
String toString() {
  final _this = this as Benefit;
  return 'Benefit(icon: ${_this.icon}, title: ${_this.title}, text: ${_this.text}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $BenefitCopyWith<$Res>  {
  factory $BenefitCopyWith(Benefit value, $Res Function(Benefit) _then) = _$BenefitCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: BenefitIcon.info) BenefitIcon icon, String title, String? text,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class _$BenefitCopyWithImpl<$Res>
    implements $BenefitCopyWith<$Res> {
  _$BenefitCopyWithImpl(this._self, this._then);

  final Benefit _self;
  final $Res Function(Benefit) _then;

/// Create a copy of Benefit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? title = null,Object? text = freezed,Object? imageUrl = freezed,}) {
  return _then(Benefit(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as BenefitIcon,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Benefit].
extension BenefitPatterns on Benefit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Benefit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Benefit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Benefit value)  $default,){
final _that = this;
switch (_that) {
case _Benefit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Benefit value)?  $default,){
final _that = this;
switch (_that) {
case _Benefit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: BenefitIcon.info)  BenefitIcon icon,  String title,  String? text, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Benefit() when $default != null:
return $default(_that.icon,_that.title,_that.text,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: BenefitIcon.info)  BenefitIcon icon,  String title,  String? text, @JsonKey(name: 'image_url')  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Benefit():
return $default(_that.icon,_that.title,_that.text,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: BenefitIcon.info)  BenefitIcon icon,  String title,  String? text, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Benefit() when $default != null:
return $default(_that.icon,_that.title,_that.text,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Benefit implements Benefit {
  const _Benefit({@JsonKey(unknownEnumValue: BenefitIcon.info) required this.icon, required this.title, this.text, @JsonKey(name: 'image_url') this.imageUrl});
  factory _Benefit.fromJson(Map<String, dynamic> json) => _$BenefitFromJson(json);

@override@JsonKey(unknownEnumValue: BenefitIcon.info) final  BenefitIcon icon;
@override final  String title;
@override final  String? text;
@override@JsonKey(name: 'image_url') final  String? imageUrl;

/// Create a copy of Benefit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenefitCopyWith<_Benefit> get copyWith => __$BenefitCopyWithImpl<_Benefit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenefitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Benefit&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,icon,title,text,imageUrl);
}

@override
String toString() {
    return 'Benefit(icon: $icon, title: $title, text: $text, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$BenefitCopyWith<$Res> implements $BenefitCopyWith<$Res> {
  factory _$BenefitCopyWith(_Benefit value, $Res Function(_Benefit) _then) = __$BenefitCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: BenefitIcon.info) BenefitIcon icon, String title, String? text,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class __$BenefitCopyWithImpl<$Res>
    implements _$BenefitCopyWith<$Res> {
  __$BenefitCopyWithImpl(this._self, this._then);

  final _Benefit _self;
  final $Res Function(_Benefit) _then;

/// Create a copy of Benefit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? title = null,Object? text = freezed,Object? imageUrl = freezed,}) {
  return _then(_Benefit(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as BenefitIcon,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

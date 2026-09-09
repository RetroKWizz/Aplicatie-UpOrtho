// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'description_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DescriptionSpan {

 String get text; bool get bold; bool get italic;
/// Create a copy of DescriptionSpan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DescriptionSpanCopyWith<DescriptionSpan> get copyWith => _$DescriptionSpanCopyWithImpl<DescriptionSpan>(this as DescriptionSpan, _$identity);

  /// Serializes this DescriptionSpan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DescriptionSpan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DescriptionSpan&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.bold, _this.bold) || other.bold == _this.bold)&&(identical(other.italic, _this.italic) || other.italic == _this.italic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DescriptionSpan;
  return Object.hash(runtimeType,_this.text,_this.bold,_this.italic);
}

@override
String toString() {
  final _this = this as DescriptionSpan;
  return 'DescriptionSpan(text: ${_this.text}, bold: ${_this.bold}, italic: ${_this.italic})';
}


}

/// @nodoc
abstract mixin class $DescriptionSpanCopyWith<$Res>  {
  factory $DescriptionSpanCopyWith(DescriptionSpan value, $Res Function(DescriptionSpan) _then) = _$DescriptionSpanCopyWithImpl;
@useResult
$Res call({
 String text, bool bold, bool italic
});




}
/// @nodoc
class _$DescriptionSpanCopyWithImpl<$Res>
    implements $DescriptionSpanCopyWith<$Res> {
  _$DescriptionSpanCopyWithImpl(this._self, this._then);

  final DescriptionSpan _self;
  final $Res Function(DescriptionSpan) _then;

/// Create a copy of DescriptionSpan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? bold = null,Object? italic = null,}) {
  return _then(DescriptionSpan(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DescriptionSpan].
extension DescriptionSpanPatterns on DescriptionSpan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DescriptionSpan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DescriptionSpan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DescriptionSpan value)  $default,){
final _that = this;
switch (_that) {
case _DescriptionSpan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DescriptionSpan value)?  $default,){
final _that = this;
switch (_that) {
case _DescriptionSpan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  bool bold,  bool italic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DescriptionSpan() when $default != null:
return $default(_that.text,_that.bold,_that.italic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  bool bold,  bool italic)  $default,) {final _that = this;
switch (_that) {
case _DescriptionSpan():
return $default(_that.text,_that.bold,_that.italic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  bool bold,  bool italic)?  $default,) {final _that = this;
switch (_that) {
case _DescriptionSpan() when $default != null:
return $default(_that.text,_that.bold,_that.italic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DescriptionSpan implements DescriptionSpan {
  const _DescriptionSpan({this.text = '', this.bold = false, this.italic = false});
  factory _DescriptionSpan.fromJson(Map<String, dynamic> json) => _$DescriptionSpanFromJson(json);

@override@JsonKey() final  String text;
@override@JsonKey() final  bool bold;
@override@JsonKey() final  bool italic;

/// Create a copy of DescriptionSpan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DescriptionSpanCopyWith<_DescriptionSpan> get copyWith => __$DescriptionSpanCopyWithImpl<_DescriptionSpan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DescriptionSpanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DescriptionSpan&&(identical(other.text, text) || other.text == text)&&(identical(other.bold, bold) || other.bold == bold)&&(identical(other.italic, italic) || other.italic == italic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,bold,italic);
}

@override
String toString() {
    return 'DescriptionSpan(text: $text, bold: $bold, italic: $italic)';
}


}

/// @nodoc
abstract mixin class _$DescriptionSpanCopyWith<$Res> implements $DescriptionSpanCopyWith<$Res> {
  factory _$DescriptionSpanCopyWith(_DescriptionSpan value, $Res Function(_DescriptionSpan) _then) = __$DescriptionSpanCopyWithImpl;
@override @useResult
$Res call({
 String text, bool bold, bool italic
});




}
/// @nodoc
class __$DescriptionSpanCopyWithImpl<$Res>
    implements _$DescriptionSpanCopyWith<$Res> {
  __$DescriptionSpanCopyWithImpl(this._self, this._then);

  final _DescriptionSpan _self;
  final $Res Function(_DescriptionSpan) _then;

/// Create a copy of DescriptionSpan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? bold = null,Object? italic = null,}) {
  return _then(_DescriptionSpan(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DescriptionBullet {

 List<DescriptionSpan> get spans;
/// Create a copy of DescriptionBullet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DescriptionBulletCopyWith<DescriptionBullet> get copyWith => _$DescriptionBulletCopyWithImpl<DescriptionBullet>(this as DescriptionBullet, _$identity);

  /// Serializes this DescriptionBullet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DescriptionBullet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DescriptionBullet&&const DeepCollectionEquality().equals(other.spans, _this.spans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DescriptionBullet;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.spans));
}

@override
String toString() {
  final _this = this as DescriptionBullet;
  return 'DescriptionBullet(spans: ${_this.spans})';
}


}

/// @nodoc
abstract mixin class $DescriptionBulletCopyWith<$Res>  {
  factory $DescriptionBulletCopyWith(DescriptionBullet value, $Res Function(DescriptionBullet) _then) = _$DescriptionBulletCopyWithImpl;
@useResult
$Res call({
 List<DescriptionSpan> spans
});




}
/// @nodoc
class _$DescriptionBulletCopyWithImpl<$Res>
    implements $DescriptionBulletCopyWith<$Res> {
  _$DescriptionBulletCopyWithImpl(this._self, this._then);

  final DescriptionBullet _self;
  final $Res Function(DescriptionBullet) _then;

/// Create a copy of DescriptionBullet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spans = null,}) {
  return _then(DescriptionBullet(
spans: null == spans ? _self.spans : spans // ignore: cast_nullable_to_non_nullable
as List<DescriptionSpan>,
  ));
}

}


/// Adds pattern-matching-related methods to [DescriptionBullet].
extension DescriptionBulletPatterns on DescriptionBullet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DescriptionBullet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DescriptionBullet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DescriptionBullet value)  $default,){
final _that = this;
switch (_that) {
case _DescriptionBullet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DescriptionBullet value)?  $default,){
final _that = this;
switch (_that) {
case _DescriptionBullet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DescriptionSpan> spans)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DescriptionBullet() when $default != null:
return $default(_that.spans);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DescriptionSpan> spans)  $default,) {final _that = this;
switch (_that) {
case _DescriptionBullet():
return $default(_that.spans);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DescriptionSpan> spans)?  $default,) {final _that = this;
switch (_that) {
case _DescriptionBullet() when $default != null:
return $default(_that.spans);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DescriptionBullet implements DescriptionBullet {
  const _DescriptionBullet({ List<DescriptionSpan> spans = const []}): _spans = spans;
  factory _DescriptionBullet.fromJson(Map<String, dynamic> json) => _$DescriptionBulletFromJson(json);

 final  List<DescriptionSpan> _spans;
@override@JsonKey() List<DescriptionSpan> get spans {
  if (_spans is EqualUnmodifiableListView) return _spans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spans);
}


/// Create a copy of DescriptionBullet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DescriptionBulletCopyWith<_DescriptionBullet> get copyWith => __$DescriptionBulletCopyWithImpl<_DescriptionBullet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DescriptionBulletToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DescriptionBullet&&const DeepCollectionEquality().equals(other.spans, _spans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_spans));
}

@override
String toString() {
    return 'DescriptionBullet(spans: $spans)';
}


}

/// @nodoc
abstract mixin class _$DescriptionBulletCopyWith<$Res> implements $DescriptionBulletCopyWith<$Res> {
  factory _$DescriptionBulletCopyWith(_DescriptionBullet value, $Res Function(_DescriptionBullet) _then) = __$DescriptionBulletCopyWithImpl;
@override @useResult
$Res call({
 List<DescriptionSpan> spans
});




}
/// @nodoc
class __$DescriptionBulletCopyWithImpl<$Res>
    implements _$DescriptionBulletCopyWith<$Res> {
  __$DescriptionBulletCopyWithImpl(this._self, this._then);

  final _DescriptionBullet _self;
  final $Res Function(_DescriptionBullet) _then;

/// Create a copy of DescriptionBullet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spans = null,}) {
  return _then(_DescriptionBullet(
spans: null == spans ? _self._spans : spans // ignore: cast_nullable_to_non_nullable
as List<DescriptionSpan>,
  ));
}


}


/// @nodoc
mixin _$DescriptionBlock {

@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph) DescriptionBlockType get type; List<DescriptionSpan> get spans; List<DescriptionBullet> get items;
/// Create a copy of DescriptionBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DescriptionBlockCopyWith<DescriptionBlock> get copyWith => _$DescriptionBlockCopyWithImpl<DescriptionBlock>(this as DescriptionBlock, _$identity);

  /// Serializes this DescriptionBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DescriptionBlock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DescriptionBlock&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.spans, _this.spans)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DescriptionBlock;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.spans),const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as DescriptionBlock;
  return 'DescriptionBlock(type: ${_this.type}, spans: ${_this.spans}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $DescriptionBlockCopyWith<$Res>  {
  factory $DescriptionBlockCopyWith(DescriptionBlock value, $Res Function(DescriptionBlock) _then) = _$DescriptionBlockCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph) DescriptionBlockType type, List<DescriptionSpan> spans, List<DescriptionBullet> items
});




}
/// @nodoc
class _$DescriptionBlockCopyWithImpl<$Res>
    implements $DescriptionBlockCopyWith<$Res> {
  _$DescriptionBlockCopyWithImpl(this._self, this._then);

  final DescriptionBlock _self;
  final $Res Function(DescriptionBlock) _then;

/// Create a copy of DescriptionBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? spans = null,Object? items = null,}) {
  return _then(DescriptionBlock(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DescriptionBlockType,spans: null == spans ? _self.spans : spans // ignore: cast_nullable_to_non_nullable
as List<DescriptionSpan>,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DescriptionBullet>,
  ));
}

}


/// Adds pattern-matching-related methods to [DescriptionBlock].
extension DescriptionBlockPatterns on DescriptionBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DescriptionBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DescriptionBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DescriptionBlock value)  $default,){
final _that = this;
switch (_that) {
case _DescriptionBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DescriptionBlock value)?  $default,){
final _that = this;
switch (_that) {
case _DescriptionBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph)  DescriptionBlockType type,  List<DescriptionSpan> spans,  List<DescriptionBullet> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DescriptionBlock() when $default != null:
return $default(_that.type,_that.spans,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph)  DescriptionBlockType type,  List<DescriptionSpan> spans,  List<DescriptionBullet> items)  $default,) {final _that = this;
switch (_that) {
case _DescriptionBlock():
return $default(_that.type,_that.spans,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph)  DescriptionBlockType type,  List<DescriptionSpan> spans,  List<DescriptionBullet> items)?  $default,) {final _that = this;
switch (_that) {
case _DescriptionBlock() when $default != null:
return $default(_that.type,_that.spans,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DescriptionBlock implements DescriptionBlock {
  const _DescriptionBlock({@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph) this.type = DescriptionBlockType.paragraph,  List<DescriptionSpan> spans = const [],  List<DescriptionBullet> items = const []}): _spans = spans,_items = items;
  factory _DescriptionBlock.fromJson(Map<String, dynamic> json) => _$DescriptionBlockFromJson(json);

@override@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph) final  DescriptionBlockType type;
 final  List<DescriptionSpan> _spans;
@override@JsonKey() List<DescriptionSpan> get spans {
  if (_spans is EqualUnmodifiableListView) return _spans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spans);
}

 final  List<DescriptionBullet> _items;
@override@JsonKey() List<DescriptionBullet> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of DescriptionBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DescriptionBlockCopyWith<_DescriptionBlock> get copyWith => __$DescriptionBlockCopyWithImpl<_DescriptionBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DescriptionBlockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DescriptionBlock&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.spans, _spans)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_spans),const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'DescriptionBlock(type: $type, spans: $spans, items: $items)';
}


}

/// @nodoc
abstract mixin class _$DescriptionBlockCopyWith<$Res> implements $DescriptionBlockCopyWith<$Res> {
  factory _$DescriptionBlockCopyWith(_DescriptionBlock value, $Res Function(_DescriptionBlock) _then) = __$DescriptionBlockCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: DescriptionBlockType.paragraph) DescriptionBlockType type, List<DescriptionSpan> spans, List<DescriptionBullet> items
});




}
/// @nodoc
class __$DescriptionBlockCopyWithImpl<$Res>
    implements _$DescriptionBlockCopyWith<$Res> {
  __$DescriptionBlockCopyWithImpl(this._self, this._then);

  final _DescriptionBlock _self;
  final $Res Function(_DescriptionBlock) _then;

/// Create a copy of DescriptionBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? spans = null,Object? items = null,}) {
  return _then(_DescriptionBlock(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DescriptionBlockType,spans: null == spans ? _self._spans : spans // ignore: cast_nullable_to_non_nullable
as List<DescriptionSpan>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DescriptionBullet>,
  ));
}


}

// dart format on

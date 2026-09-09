// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductDocument {

 int get id; String get name;@JsonKey(name: 'file_name') String? get fileName; String get url;
/// Create a copy of ProductDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDocumentCopyWith<ProductDocument> get copyWith => _$ProductDocumentCopyWithImpl<ProductDocument>(this as ProductDocument, _$identity);

  /// Serializes this ProductDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDocument&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductDocument;
  return Object.hash(runtimeType,_this.id,_this.name,_this.fileName,_this.url);
}

@override
String toString() {
  final _this = this as ProductDocument;
  return 'ProductDocument(id: ${_this.id}, name: ${_this.name}, fileName: ${_this.fileName}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $ProductDocumentCopyWith<$Res>  {
  factory $ProductDocumentCopyWith(ProductDocument value, $Res Function(ProductDocument) _then) = _$ProductDocumentCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'file_name') String? fileName, String url
});




}
/// @nodoc
class _$ProductDocumentCopyWithImpl<$Res>
    implements $ProductDocumentCopyWith<$Res> {
  _$ProductDocumentCopyWithImpl(this._self, this._then);

  final ProductDocument _self;
  final $Res Function(ProductDocument) _then;

/// Create a copy of ProductDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? fileName = freezed,Object? url = null,}) {
  return _then(ProductDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductDocument].
extension ProductDocumentPatterns on ProductDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductDocument value)  $default,){
final _that = this;
switch (_that) {
case _ProductDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ProductDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'file_name')  String? fileName,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductDocument() when $default != null:
return $default(_that.id,_that.name,_that.fileName,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'file_name')  String? fileName,  String url)  $default,) {final _that = this;
switch (_that) {
case _ProductDocument():
return $default(_that.id,_that.name,_that.fileName,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'file_name')  String? fileName,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ProductDocument() when $default != null:
return $default(_that.id,_that.name,_that.fileName,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductDocument implements ProductDocument {
  const _ProductDocument({required this.id, required this.name, @JsonKey(name: 'file_name') this.fileName, required this.url});
  factory _ProductDocument.fromJson(Map<String, dynamic> json) => _$ProductDocumentFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'file_name') final  String? fileName;
@override final  String url;

/// Create a copy of ProductDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDocumentCopyWith<_ProductDocument> get copyWith => __$ProductDocumentCopyWithImpl<_ProductDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,fileName,url);
}

@override
String toString() {
    return 'ProductDocument(id: $id, name: $name, fileName: $fileName, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ProductDocumentCopyWith<$Res> implements $ProductDocumentCopyWith<$Res> {
  factory _$ProductDocumentCopyWith(_ProductDocument value, $Res Function(_ProductDocument) _then) = __$ProductDocumentCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'file_name') String? fileName, String url
});




}
/// @nodoc
class __$ProductDocumentCopyWithImpl<$Res>
    implements _$ProductDocumentCopyWith<$Res> {
  __$ProductDocumentCopyWithImpl(this._self, this._then);

  final _ProductDocument _self;
  final $Res Function(_ProductDocument) _then;

/// Create a copy of ProductDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? fileName = freezed,Object? url = null,}) {
  return _then(_ProductDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

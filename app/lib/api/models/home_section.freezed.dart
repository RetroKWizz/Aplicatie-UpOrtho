// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeSection {

 int get id; String get title;/// Categoria din spatele randului, cand randul e facut dintr-o categorie: "Vezi
/// toate" duce atunci in catalog, pe ea. Null pentru produse alese de mana.
@JsonKey(name: 'category_id') int? get categoryId; List<Product> get products;
/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSectionCopyWith<HomeSection> get copyWith => _$HomeSectionCopyWithImpl<HomeSection>(this as HomeSection, _$identity);

  /// Serializes this HomeSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&const DeepCollectionEquality().equals(other.products, _this.products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeSection;
  return Object.hash(runtimeType,_this.id,_this.title,_this.categoryId,const DeepCollectionEquality().hash(_this.products));
}

@override
String toString() {
  final _this = this as HomeSection;
  return 'HomeSection(id: ${_this.id}, title: ${_this.title}, categoryId: ${_this.categoryId}, products: ${_this.products})';
}


}

/// @nodoc
abstract mixin class $HomeSectionCopyWith<$Res>  {
  factory $HomeSectionCopyWith(HomeSection value, $Res Function(HomeSection) _then) = _$HomeSectionCopyWithImpl;
@useResult
$Res call({
 int id, String title,@JsonKey(name: 'category_id') int? categoryId, List<Product> products
});




}
/// @nodoc
class _$HomeSectionCopyWithImpl<$Res>
    implements $HomeSectionCopyWith<$Res> {
  _$HomeSectionCopyWithImpl(this._self, this._then);

  final HomeSection _self;
  final $Res Function(HomeSection) _then;

/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? categoryId = freezed,Object? products = null,}) {
  return _then(HomeSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeSection].
extension HomeSectionPatterns on HomeSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSection value)  $default,){
final _that = this;
switch (_that) {
case _HomeSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSection value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'category_id')  int? categoryId,  List<Product> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
return $default(_that.id,_that.title,_that.categoryId,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'category_id')  int? categoryId,  List<Product> products)  $default,) {final _that = this;
switch (_that) {
case _HomeSection():
return $default(_that.id,_that.title,_that.categoryId,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title, @JsonKey(name: 'category_id')  int? categoryId,  List<Product> products)?  $default,) {final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
return $default(_that.id,_that.title,_that.categoryId,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeSection implements HomeSection {
  const _HomeSection({required this.id, required this.title, @JsonKey(name: 'category_id') this.categoryId,  List<Product> products = const []}): _products = products;
  factory _HomeSection.fromJson(Map<String, dynamic> json) => _$HomeSectionFromJson(json);

@override final  int id;
@override final  String title;
/// Categoria din spatele randului, cand randul e facut dintr-o categorie: "Vezi
/// toate" duce atunci in catalog, pe ea. Null pentru produse alese de mana.
@override@JsonKey(name: 'category_id') final  int? categoryId;
 final  List<Product> _products;
@override@JsonKey() List<Product> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSectionCopyWith<_HomeSection> get copyWith => __$HomeSectionCopyWithImpl<_HomeSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeSectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,categoryId,const DeepCollectionEquality().hash(_products));
}

@override
String toString() {
    return 'HomeSection(id: $id, title: $title, categoryId: $categoryId, products: $products)';
}


}

/// @nodoc
abstract mixin class _$HomeSectionCopyWith<$Res> implements $HomeSectionCopyWith<$Res> {
  factory _$HomeSectionCopyWith(_HomeSection value, $Res Function(_HomeSection) _then) = __$HomeSectionCopyWithImpl;
@override @useResult
$Res call({
 int id, String title,@JsonKey(name: 'category_id') int? categoryId, List<Product> products
});




}
/// @nodoc
class __$HomeSectionCopyWithImpl<$Res>
    implements _$HomeSectionCopyWith<$Res> {
  __$HomeSectionCopyWithImpl(this._self, this._then);

  final _HomeSection _self;
  final $Res Function(_HomeSection) _then;

/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? categoryId = freezed,Object? products = null,}) {
  return _then(_HomeSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,
  ));
}


}

// dart format on

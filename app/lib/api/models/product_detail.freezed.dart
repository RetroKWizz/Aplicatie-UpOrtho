// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductImage {

 int get id; String? get url;@JsonKey(unknownEnumValue: ProductImageKind.image) ProductImageKind get kind;@JsonKey(name: 'video_url') String? get videoUrl;
/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageCopyWith<ProductImage> get copyWith => _$ProductImageCopyWithImpl<ProductImage>(this as ProductImage, _$identity);

  /// Serializes this ProductImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductImage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.videoUrl, _this.videoUrl) || other.videoUrl == _this.videoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductImage;
  return Object.hash(runtimeType,_this.id,_this.url,_this.kind,_this.videoUrl);
}

@override
String toString() {
  final _this = this as ProductImage;
  return 'ProductImage(id: ${_this.id}, url: ${_this.url}, kind: ${_this.kind}, videoUrl: ${_this.videoUrl})';
}


}

/// @nodoc
abstract mixin class $ProductImageCopyWith<$Res>  {
  factory $ProductImageCopyWith(ProductImage value, $Res Function(ProductImage) _then) = _$ProductImageCopyWithImpl;
@useResult
$Res call({
 int id, String? url,@JsonKey(unknownEnumValue: ProductImageKind.image) ProductImageKind kind,@JsonKey(name: 'video_url') String? videoUrl
});




}
/// @nodoc
class _$ProductImageCopyWithImpl<$Res>
    implements $ProductImageCopyWith<$Res> {
  _$ProductImageCopyWithImpl(this._self, this._then);

  final ProductImage _self;
  final $Res Function(ProductImage) _then;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = freezed,Object? kind = null,Object? videoUrl = freezed,}) {
  return _then(ProductImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ProductImageKind,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImage].
extension ProductImagePatterns on ProductImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImage value)  $default,){
final _that = this;
switch (_that) {
case _ProductImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImage value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? url, @JsonKey(unknownEnumValue: ProductImageKind.image)  ProductImageKind kind, @JsonKey(name: 'video_url')  String? videoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
return $default(_that.id,_that.url,_that.kind,_that.videoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? url, @JsonKey(unknownEnumValue: ProductImageKind.image)  ProductImageKind kind, @JsonKey(name: 'video_url')  String? videoUrl)  $default,) {final _that = this;
switch (_that) {
case _ProductImage():
return $default(_that.id,_that.url,_that.kind,_that.videoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? url, @JsonKey(unknownEnumValue: ProductImageKind.image)  ProductImageKind kind, @JsonKey(name: 'video_url')  String? videoUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
return $default(_that.id,_that.url,_that.kind,_that.videoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductImage implements ProductImage {
  const _ProductImage({required this.id, this.url, @JsonKey(unknownEnumValue: ProductImageKind.image) this.kind = ProductImageKind.image, @JsonKey(name: 'video_url') this.videoUrl});
  factory _ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);

@override final  int id;
@override final  String? url;
@override@JsonKey(unknownEnumValue: ProductImageKind.image) final  ProductImageKind kind;
@override@JsonKey(name: 'video_url') final  String? videoUrl;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageCopyWith<_ProductImage> get copyWith => __$ProductImageCopyWithImpl<_ProductImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductImageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImage&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,kind,videoUrl);
}

@override
String toString() {
    return 'ProductImage(id: $id, url: $url, kind: $kind, videoUrl: $videoUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductImageCopyWith<$Res> implements $ProductImageCopyWith<$Res> {
  factory _$ProductImageCopyWith(_ProductImage value, $Res Function(_ProductImage) _then) = __$ProductImageCopyWithImpl;
@override @useResult
$Res call({
 int id, String? url,@JsonKey(unknownEnumValue: ProductImageKind.image) ProductImageKind kind,@JsonKey(name: 'video_url') String? videoUrl
});




}
/// @nodoc
class __$ProductImageCopyWithImpl<$Res>
    implements _$ProductImageCopyWith<$Res> {
  __$ProductImageCopyWithImpl(this._self, this._then);

  final _ProductImage _self;
  final $Res Function(_ProductImage) _then;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = freezed,Object? kind = null,Object? videoUrl = freezed,}) {
  return _then(_ProductImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ProductImageKind,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductAvailability {

 String? get message;@JsonKey(name: 'in_stock') bool get inStock;
/// Create a copy of ProductAvailability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductAvailabilityCopyWith<ProductAvailability> get copyWith => _$ProductAvailabilityCopyWithImpl<ProductAvailability>(this as ProductAvailability, _$identity);

  /// Serializes this ProductAvailability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductAvailability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductAvailability&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.inStock, _this.inStock) || other.inStock == _this.inStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductAvailability;
  return Object.hash(runtimeType,_this.message,_this.inStock);
}

@override
String toString() {
  final _this = this as ProductAvailability;
  return 'ProductAvailability(message: ${_this.message}, inStock: ${_this.inStock})';
}


}

/// @nodoc
abstract mixin class $ProductAvailabilityCopyWith<$Res>  {
  factory $ProductAvailabilityCopyWith(ProductAvailability value, $Res Function(ProductAvailability) _then) = _$ProductAvailabilityCopyWithImpl;
@useResult
$Res call({
 String? message,@JsonKey(name: 'in_stock') bool inStock
});




}
/// @nodoc
class _$ProductAvailabilityCopyWithImpl<$Res>
    implements $ProductAvailabilityCopyWith<$Res> {
  _$ProductAvailabilityCopyWithImpl(this._self, this._then);

  final ProductAvailability _self;
  final $Res Function(ProductAvailability) _then;

/// Create a copy of ProductAvailability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? inStock = null,}) {
  return _then(ProductAvailability(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductAvailability].
extension ProductAvailabilityPatterns on ProductAvailability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductAvailability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductAvailability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductAvailability value)  $default,){
final _that = this;
switch (_that) {
case _ProductAvailability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductAvailability value)?  $default,){
final _that = this;
switch (_that) {
case _ProductAvailability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? message, @JsonKey(name: 'in_stock')  bool inStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductAvailability() when $default != null:
return $default(_that.message,_that.inStock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? message, @JsonKey(name: 'in_stock')  bool inStock)  $default,) {final _that = this;
switch (_that) {
case _ProductAvailability():
return $default(_that.message,_that.inStock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? message, @JsonKey(name: 'in_stock')  bool inStock)?  $default,) {final _that = this;
switch (_that) {
case _ProductAvailability() when $default != null:
return $default(_that.message,_that.inStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductAvailability implements ProductAvailability {
  const _ProductAvailability({this.message, @JsonKey(name: 'in_stock') this.inStock = true});
  factory _ProductAvailability.fromJson(Map<String, dynamic> json) => _$ProductAvailabilityFromJson(json);

@override final  String? message;
@override@JsonKey(name: 'in_stock') final  bool inStock;

/// Create a copy of ProductAvailability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductAvailabilityCopyWith<_ProductAvailability> get copyWith => __$ProductAvailabilityCopyWithImpl<_ProductAvailability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductAvailabilityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductAvailability&&(identical(other.message, message) || other.message == message)&&(identical(other.inStock, inStock) || other.inStock == inStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message,inStock);
}

@override
String toString() {
    return 'ProductAvailability(message: $message, inStock: $inStock)';
}


}

/// @nodoc
abstract mixin class _$ProductAvailabilityCopyWith<$Res> implements $ProductAvailabilityCopyWith<$Res> {
  factory _$ProductAvailabilityCopyWith(_ProductAvailability value, $Res Function(_ProductAvailability) _then) = __$ProductAvailabilityCopyWithImpl;
@override @useResult
$Res call({
 String? message,@JsonKey(name: 'in_stock') bool inStock
});




}
/// @nodoc
class __$ProductAvailabilityCopyWithImpl<$Res>
    implements _$ProductAvailabilityCopyWith<$Res> {
  __$ProductAvailabilityCopyWithImpl(this._self, this._then);

  final _ProductAvailability _self;
  final $Res Function(_ProductAvailability) _then;

/// Create a copy of ProductAvailability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? inStock = null,}) {
  return _then(_ProductAvailability(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProductDetail {

 int get id;@JsonKey(name: 'variant_id') int? get variantId; String get name;@JsonKey(name: 'default_code') String? get defaultCode; ProductBadge? get badge; List<ProductImage> get images; Price get price;@JsonKey(name: 'club_price') Price? get clubPrice;@JsonKey(name: 'price_tables') List<PriceTable> get priceTables; VariantOptions? get variants; List<ProductSpec> get specs; List<DescriptionBlock> get description; ProductAvailability? get availability; ProductRating get rating; List<ProductReview> get reviews; List<Product> get similar; List<Benefit> get benefits;
/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDetailCopyWith<ProductDetail> get copyWith => _$ProductDetailCopyWithImpl<ProductDetail>(this as ProductDetail, _$identity);

  /// Serializes this ProductDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.defaultCode, _this.defaultCode) || other.defaultCode == _this.defaultCode)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&const DeepCollectionEquality().equals(other.images, _this.images)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.clubPrice, _this.clubPrice) || other.clubPrice == _this.clubPrice)&&const DeepCollectionEquality().equals(other.priceTables, _this.priceTables)&&(identical(other.variants, _this.variants) || other.variants == _this.variants)&&const DeepCollectionEquality().equals(other.specs, _this.specs)&&const DeepCollectionEquality().equals(other.description, _this.description)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&const DeepCollectionEquality().equals(other.reviews, _this.reviews)&&const DeepCollectionEquality().equals(other.similar, _this.similar)&&const DeepCollectionEquality().equals(other.benefits, _this.benefits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductDetail;
  return Object.hash(runtimeType,_this.id,_this.variantId,_this.name,_this.defaultCode,_this.badge,const DeepCollectionEquality().hash(_this.images),_this.price,_this.clubPrice,const DeepCollectionEquality().hash(_this.priceTables),_this.variants,const DeepCollectionEquality().hash(_this.specs),const DeepCollectionEquality().hash(_this.description),_this.availability,_this.rating,const DeepCollectionEquality().hash(_this.reviews),const DeepCollectionEquality().hash(_this.similar),const DeepCollectionEquality().hash(_this.benefits));
}

@override
String toString() {
  final _this = this as ProductDetail;
  return 'ProductDetail(id: ${_this.id}, variantId: ${_this.variantId}, name: ${_this.name}, defaultCode: ${_this.defaultCode}, badge: ${_this.badge}, images: ${_this.images}, price: ${_this.price}, clubPrice: ${_this.clubPrice}, priceTables: ${_this.priceTables}, variants: ${_this.variants}, specs: ${_this.specs}, description: ${_this.description}, availability: ${_this.availability}, rating: ${_this.rating}, reviews: ${_this.reviews}, similar: ${_this.similar}, benefits: ${_this.benefits})';
}


}

/// @nodoc
abstract mixin class $ProductDetailCopyWith<$Res>  {
  factory $ProductDetailCopyWith(ProductDetail value, $Res Function(ProductDetail) _then) = _$ProductDetailCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'variant_id') int? variantId, String name,@JsonKey(name: 'default_code') String? defaultCode, ProductBadge? badge, List<ProductImage> images, Price price,@JsonKey(name: 'club_price') Price? clubPrice,@JsonKey(name: 'price_tables') List<PriceTable> priceTables, VariantOptions? variants, List<ProductSpec> specs, List<DescriptionBlock> description, ProductAvailability? availability, ProductRating rating, List<ProductReview> reviews, List<Product> similar, List<Benefit> benefits
});


$ProductBadgeCopyWith<$Res>? get badge;$PriceCopyWith<$Res> get price;$PriceCopyWith<$Res>? get clubPrice;$VariantOptionsCopyWith<$Res>? get variants;$ProductAvailabilityCopyWith<$Res>? get availability;$ProductRatingCopyWith<$Res> get rating;

}
/// @nodoc
class _$ProductDetailCopyWithImpl<$Res>
    implements $ProductDetailCopyWith<$Res> {
  _$ProductDetailCopyWithImpl(this._self, this._then);

  final ProductDetail _self;
  final $Res Function(ProductDetail) _then;

/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? variantId = freezed,Object? name = null,Object? defaultCode = freezed,Object? badge = freezed,Object? images = null,Object? price = null,Object? clubPrice = freezed,Object? priceTables = null,Object? variants = freezed,Object? specs = null,Object? description = null,Object? availability = freezed,Object? rating = null,Object? reviews = null,Object? similar = null,Object? benefits = null,}) {
  return _then(ProductDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,defaultCode: freezed == defaultCode ? _self.defaultCode : defaultCode // ignore: cast_nullable_to_non_nullable
as String?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as ProductBadge?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,clubPrice: freezed == clubPrice ? _self.clubPrice : clubPrice // ignore: cast_nullable_to_non_nullable
as Price?,priceTables: null == priceTables ? _self.priceTables : priceTables // ignore: cast_nullable_to_non_nullable
as List<PriceTable>,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as VariantOptions?,specs: null == specs ? _self.specs : specs // ignore: cast_nullable_to_non_nullable
as List<ProductSpec>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ProductAvailability?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as ProductRating,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<ProductReview>,similar: null == similar ? _self.similar : similar // ignore: cast_nullable_to_non_nullable
as List<Product>,benefits: null == benefits ? _self.benefits : benefits // ignore: cast_nullable_to_non_nullable
as List<Benefit>,
  ));
}
/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductBadgeCopyWith<$Res>? get badge {
    if (_self.badge == null) {
    return null;
  }

  return $ProductBadgeCopyWith<$Res>(_self.badge!, (value) {
    return _then(_self.copyWith(badge: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get clubPrice {
    if (_self.clubPrice == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.clubPrice!, (value) {
    return _then(_self.copyWith(clubPrice: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VariantOptionsCopyWith<$Res>? get variants {
    if (_self.variants == null) {
    return null;
  }

  return $VariantOptionsCopyWith<$Res>(_self.variants!, (value) {
    return _then(_self.copyWith(variants: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductAvailabilityCopyWith<$Res>? get availability {
    if (_self.availability == null) {
    return null;
  }

  return $ProductAvailabilityCopyWith<$Res>(_self.availability!, (value) {
    return _then(_self.copyWith(availability: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRatingCopyWith<$Res> get rating {
  
  return $ProductRatingCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductDetail].
extension ProductDetailPatterns on ProductDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductDetail value)  $default,){
final _that = this;
switch (_that) {
case _ProductDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ProductDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'variant_id')  int? variantId,  String name, @JsonKey(name: 'default_code')  String? defaultCode,  ProductBadge? badge,  List<ProductImage> images,  Price price, @JsonKey(name: 'club_price')  Price? clubPrice, @JsonKey(name: 'price_tables')  List<PriceTable> priceTables,  VariantOptions? variants,  List<ProductSpec> specs,  List<DescriptionBlock> description,  ProductAvailability? availability,  ProductRating rating,  List<ProductReview> reviews,  List<Product> similar,  List<Benefit> benefits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductDetail() when $default != null:
return $default(_that.id,_that.variantId,_that.name,_that.defaultCode,_that.badge,_that.images,_that.price,_that.clubPrice,_that.priceTables,_that.variants,_that.specs,_that.description,_that.availability,_that.rating,_that.reviews,_that.similar,_that.benefits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'variant_id')  int? variantId,  String name, @JsonKey(name: 'default_code')  String? defaultCode,  ProductBadge? badge,  List<ProductImage> images,  Price price, @JsonKey(name: 'club_price')  Price? clubPrice, @JsonKey(name: 'price_tables')  List<PriceTable> priceTables,  VariantOptions? variants,  List<ProductSpec> specs,  List<DescriptionBlock> description,  ProductAvailability? availability,  ProductRating rating,  List<ProductReview> reviews,  List<Product> similar,  List<Benefit> benefits)  $default,) {final _that = this;
switch (_that) {
case _ProductDetail():
return $default(_that.id,_that.variantId,_that.name,_that.defaultCode,_that.badge,_that.images,_that.price,_that.clubPrice,_that.priceTables,_that.variants,_that.specs,_that.description,_that.availability,_that.rating,_that.reviews,_that.similar,_that.benefits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'variant_id')  int? variantId,  String name, @JsonKey(name: 'default_code')  String? defaultCode,  ProductBadge? badge,  List<ProductImage> images,  Price price, @JsonKey(name: 'club_price')  Price? clubPrice, @JsonKey(name: 'price_tables')  List<PriceTable> priceTables,  VariantOptions? variants,  List<ProductSpec> specs,  List<DescriptionBlock> description,  ProductAvailability? availability,  ProductRating rating,  List<ProductReview> reviews,  List<Product> similar,  List<Benefit> benefits)?  $default,) {final _that = this;
switch (_that) {
case _ProductDetail() when $default != null:
return $default(_that.id,_that.variantId,_that.name,_that.defaultCode,_that.badge,_that.images,_that.price,_that.clubPrice,_that.priceTables,_that.variants,_that.specs,_that.description,_that.availability,_that.rating,_that.reviews,_that.similar,_that.benefits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductDetail implements ProductDetail {
  const _ProductDetail({required this.id, @JsonKey(name: 'variant_id') this.variantId, required this.name, @JsonKey(name: 'default_code') this.defaultCode, this.badge,  List<ProductImage> images = const [], required this.price, @JsonKey(name: 'club_price') this.clubPrice, @JsonKey(name: 'price_tables')  List<PriceTable> priceTables = const [], this.variants,  List<ProductSpec> specs = const [],  List<DescriptionBlock> description = const [], this.availability, this.rating = const ProductRating(),  List<ProductReview> reviews = const [],  List<Product> similar = const [],  List<Benefit> benefits = const []}): _images = images,_priceTables = priceTables,_specs = specs,_description = description,_reviews = reviews,_similar = similar,_benefits = benefits;
  factory _ProductDetail.fromJson(Map<String, dynamic> json) => _$ProductDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: 'variant_id') final  int? variantId;
@override final  String name;
@override@JsonKey(name: 'default_code') final  String? defaultCode;
@override final  ProductBadge? badge;
 final  List<ProductImage> _images;
@override@JsonKey() List<ProductImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  Price price;
@override@JsonKey(name: 'club_price') final  Price? clubPrice;
 final  List<PriceTable> _priceTables;
@override@JsonKey(name: 'price_tables') List<PriceTable> get priceTables {
  if (_priceTables is EqualUnmodifiableListView) return _priceTables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priceTables);
}

@override final  VariantOptions? variants;
 final  List<ProductSpec> _specs;
@override@JsonKey() List<ProductSpec> get specs {
  if (_specs is EqualUnmodifiableListView) return _specs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specs);
}

 final  List<DescriptionBlock> _description;
@override@JsonKey() List<DescriptionBlock> get description {
  if (_description is EqualUnmodifiableListView) return _description;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_description);
}

@override final  ProductAvailability? availability;
@override@JsonKey() final  ProductRating rating;
 final  List<ProductReview> _reviews;
@override@JsonKey() List<ProductReview> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

 final  List<Product> _similar;
@override@JsonKey() List<Product> get similar {
  if (_similar is EqualUnmodifiableListView) return _similar;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_similar);
}

 final  List<Benefit> _benefits;
@override@JsonKey() List<Benefit> get benefits {
  if (_benefits is EqualUnmodifiableListView) return _benefits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_benefits);
}


/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDetailCopyWith<_ProductDetail> get copyWith => __$ProductDetailCopyWithImpl<_ProductDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.defaultCode, defaultCode) || other.defaultCode == defaultCode)&&(identical(other.badge, badge) || other.badge == badge)&&const DeepCollectionEquality().equals(other.images, _images)&&(identical(other.price, price) || other.price == price)&&(identical(other.clubPrice, clubPrice) || other.clubPrice == clubPrice)&&const DeepCollectionEquality().equals(other.priceTables, _priceTables)&&(identical(other.variants, variants) || other.variants == variants)&&const DeepCollectionEquality().equals(other.specs, _specs)&&const DeepCollectionEquality().equals(other.description, _description)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.reviews, _reviews)&&const DeepCollectionEquality().equals(other.similar, _similar)&&const DeepCollectionEquality().equals(other.benefits, _benefits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,variantId,name,defaultCode,badge,const DeepCollectionEquality().hash(_images),price,clubPrice,const DeepCollectionEquality().hash(_priceTables),variants,const DeepCollectionEquality().hash(_specs),const DeepCollectionEquality().hash(_description),availability,rating,const DeepCollectionEquality().hash(_reviews),const DeepCollectionEquality().hash(_similar),const DeepCollectionEquality().hash(_benefits));
}

@override
String toString() {
    return 'ProductDetail(id: $id, variantId: $variantId, name: $name, defaultCode: $defaultCode, badge: $badge, images: $images, price: $price, clubPrice: $clubPrice, priceTables: $priceTables, variants: $variants, specs: $specs, description: $description, availability: $availability, rating: $rating, reviews: $reviews, similar: $similar, benefits: $benefits)';
}


}

/// @nodoc
abstract mixin class _$ProductDetailCopyWith<$Res> implements $ProductDetailCopyWith<$Res> {
  factory _$ProductDetailCopyWith(_ProductDetail value, $Res Function(_ProductDetail) _then) = __$ProductDetailCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'variant_id') int? variantId, String name,@JsonKey(name: 'default_code') String? defaultCode, ProductBadge? badge, List<ProductImage> images, Price price,@JsonKey(name: 'club_price') Price? clubPrice,@JsonKey(name: 'price_tables') List<PriceTable> priceTables, VariantOptions? variants, List<ProductSpec> specs, List<DescriptionBlock> description, ProductAvailability? availability, ProductRating rating, List<ProductReview> reviews, List<Product> similar, List<Benefit> benefits
});


@override $ProductBadgeCopyWith<$Res>? get badge;@override $PriceCopyWith<$Res> get price;@override $PriceCopyWith<$Res>? get clubPrice;@override $VariantOptionsCopyWith<$Res>? get variants;@override $ProductAvailabilityCopyWith<$Res>? get availability;@override $ProductRatingCopyWith<$Res> get rating;

}
/// @nodoc
class __$ProductDetailCopyWithImpl<$Res>
    implements _$ProductDetailCopyWith<$Res> {
  __$ProductDetailCopyWithImpl(this._self, this._then);

  final _ProductDetail _self;
  final $Res Function(_ProductDetail) _then;

/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? variantId = freezed,Object? name = null,Object? defaultCode = freezed,Object? badge = freezed,Object? images = null,Object? price = null,Object? clubPrice = freezed,Object? priceTables = null,Object? variants = freezed,Object? specs = null,Object? description = null,Object? availability = freezed,Object? rating = null,Object? reviews = null,Object? similar = null,Object? benefits = null,}) {
  return _then(_ProductDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,defaultCode: freezed == defaultCode ? _self.defaultCode : defaultCode // ignore: cast_nullable_to_non_nullable
as String?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as ProductBadge?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,clubPrice: freezed == clubPrice ? _self.clubPrice : clubPrice // ignore: cast_nullable_to_non_nullable
as Price?,priceTables: null == priceTables ? _self._priceTables : priceTables // ignore: cast_nullable_to_non_nullable
as List<PriceTable>,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as VariantOptions?,specs: null == specs ? _self._specs : specs // ignore: cast_nullable_to_non_nullable
as List<ProductSpec>,description: null == description ? _self._description : description // ignore: cast_nullable_to_non_nullable
as List<DescriptionBlock>,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ProductAvailability?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as ProductRating,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<ProductReview>,similar: null == similar ? _self._similar : similar // ignore: cast_nullable_to_non_nullable
as List<Product>,benefits: null == benefits ? _self._benefits : benefits // ignore: cast_nullable_to_non_nullable
as List<Benefit>,
  ));
}

/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductBadgeCopyWith<$Res>? get badge {
    if (_self.badge == null) {
    return null;
  }

  return $ProductBadgeCopyWith<$Res>(_self.badge!, (value) {
    return _then(_self.copyWith(badge: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get clubPrice {
    if (_self.clubPrice == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.clubPrice!, (value) {
    return _then(_self.copyWith(clubPrice: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VariantOptionsCopyWith<$Res>? get variants {
    if (_self.variants == null) {
    return null;
  }

  return $VariantOptionsCopyWith<$Res>(_self.variants!, (value) {
    return _then(_self.copyWith(variants: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductAvailabilityCopyWith<$Res>? get availability {
    if (_self.availability == null) {
    return null;
  }

  return $ProductAvailabilityCopyWith<$Res>(_self.availability!, (value) {
    return _then(_self.copyWith(availability: value));
  });
}/// Create a copy of ProductDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRatingCopyWith<$Res> get rating {
  
  return $ProductRatingCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}

// dart format on

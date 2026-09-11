// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 int get id; String get name;@JsonKey(name: 'default_code') String? get defaultCode;@JsonKey(name: 'image_url') String? get imageUrl; Price get price;@JsonKey(name: 'club_price') Price? get clubPrice; ProductBadge? get badge;/// Nota din recenzii; null cand produsul n-are niciuna - la fel ca pe site, unde
/// pastila cu nota nici nu apare atunci.
 ProductRating? get rating;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.defaultCode, _this.defaultCode) || other.defaultCode == _this.defaultCode)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.clubPrice, _this.clubPrice) || other.clubPrice == _this.clubPrice)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&(identical(other.rating, _this.rating) || other.rating == _this.rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.id,_this.name,_this.defaultCode,_this.imageUrl,_this.price,_this.clubPrice,_this.badge,_this.rating);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, name: ${_this.name}, defaultCode: ${_this.defaultCode}, imageUrl: ${_this.imageUrl}, price: ${_this.price}, clubPrice: ${_this.clubPrice}, badge: ${_this.badge}, rating: ${_this.rating})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'default_code') String? defaultCode,@JsonKey(name: 'image_url') String? imageUrl, Price price,@JsonKey(name: 'club_price') Price? clubPrice, ProductBadge? badge, ProductRating? rating
});


$PriceCopyWith<$Res> get price;$PriceCopyWith<$Res>? get clubPrice;$ProductBadgeCopyWith<$Res>? get badge;$ProductRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? defaultCode = freezed,Object? imageUrl = freezed,Object? price = null,Object? clubPrice = freezed,Object? badge = freezed,Object? rating = freezed,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,defaultCode: freezed == defaultCode ? _self.defaultCode : defaultCode // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,clubPrice: freezed == clubPrice ? _self.clubPrice : clubPrice // ignore: cast_nullable_to_non_nullable
as Price?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as ProductBadge?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as ProductRating?,
  ));
}
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Product
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
}/// Create a copy of Product
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
}/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $ProductRatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'default_code')  String? defaultCode, @JsonKey(name: 'image_url')  String? imageUrl,  Price price, @JsonKey(name: 'club_price')  Price? clubPrice,  ProductBadge? badge,  ProductRating? rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.defaultCode,_that.imageUrl,_that.price,_that.clubPrice,_that.badge,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'default_code')  String? defaultCode, @JsonKey(name: 'image_url')  String? imageUrl,  Price price, @JsonKey(name: 'club_price')  Price? clubPrice,  ProductBadge? badge,  ProductRating? rating)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.defaultCode,_that.imageUrl,_that.price,_that.clubPrice,_that.badge,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'default_code')  String? defaultCode, @JsonKey(name: 'image_url')  String? imageUrl,  Price price, @JsonKey(name: 'club_price')  Price? clubPrice,  ProductBadge? badge,  ProductRating? rating)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.defaultCode,_that.imageUrl,_that.price,_that.clubPrice,_that.badge,_that.rating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, @JsonKey(name: 'default_code') this.defaultCode, @JsonKey(name: 'image_url') this.imageUrl, required this.price, @JsonKey(name: 'club_price') this.clubPrice, this.badge, this.rating});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'default_code') final  String? defaultCode;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  Price price;
@override@JsonKey(name: 'club_price') final  Price? clubPrice;
@override final  ProductBadge? badge;
/// Nota din recenzii; null cand produsul n-are niciuna - la fel ca pe site, unde
/// pastila cu nota nici nu apare atunci.
@override final  ProductRating? rating;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.defaultCode, defaultCode) || other.defaultCode == defaultCode)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.price, price) || other.price == price)&&(identical(other.clubPrice, clubPrice) || other.clubPrice == clubPrice)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,defaultCode,imageUrl,price,clubPrice,badge,rating);
}

@override
String toString() {
    return 'Product(id: $id, name: $name, defaultCode: $defaultCode, imageUrl: $imageUrl, price: $price, clubPrice: $clubPrice, badge: $badge, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'default_code') String? defaultCode,@JsonKey(name: 'image_url') String? imageUrl, Price price,@JsonKey(name: 'club_price') Price? clubPrice, ProductBadge? badge, ProductRating? rating
});


@override $PriceCopyWith<$Res> get price;@override $PriceCopyWith<$Res>? get clubPrice;@override $ProductBadgeCopyWith<$Res>? get badge;@override $ProductRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? defaultCode = freezed,Object? imageUrl = freezed,Object? price = null,Object? clubPrice = freezed,Object? badge = freezed,Object? rating = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,defaultCode: freezed == defaultCode ? _self.defaultCode : defaultCode // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,clubPrice: freezed == clubPrice ? _self.clubPrice : clubPrice // ignore: cast_nullable_to_non_nullable
as Price?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as ProductBadge?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as ProductRating?,
  ));
}

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Product
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
}/// Create a copy of Product
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
}/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductRatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $ProductRatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}

// dart format on

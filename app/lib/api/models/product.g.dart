// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  defaultCode: json['default_code'] as String?,
  imageUrl: json['image_url'] as String?,
  price: Price.fromJson(json['price'] as Map<String, dynamic>),
  clubPrice: json['club_price'] == null
      ? null
      : Price.fromJson(json['club_price'] as Map<String, dynamic>),
  badge: json['badge'] == null
      ? null
      : ProductBadge.fromJson(json['badge'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'default_code': instance.defaultCode,
  'image_url': instance.imageUrl,
  'price': instance.price,
  'club_price': instance.clubPrice,
  'badge': instance.badge,
};

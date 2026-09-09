// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductImage _$ProductImageFromJson(Map<String, dynamic> json) =>
    _ProductImage(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String?,
      kind:
          $enumDecodeNullable(
            _$ProductImageKindEnumMap,
            json['kind'],
            unknownValue: ProductImageKind.image,
          ) ??
          ProductImageKind.image,
      videoUrl: json['video_url'] as String?,
    );

Map<String, dynamic> _$ProductImageToJson(_ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'kind': _$ProductImageKindEnumMap[instance.kind]!,
      'video_url': instance.videoUrl,
    };

const _$ProductImageKindEnumMap = {
  ProductImageKind.image: 'image',
  ProductImageKind.video: 'video',
};

_ProductAvailability _$ProductAvailabilityFromJson(Map<String, dynamic> json) =>
    _ProductAvailability(
      message: json['message'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductAvailabilityToJson(
  _ProductAvailability instance,
) => <String, dynamic>{
  'message': instance.message,
  'in_stock': instance.inStock,
};

_VariantRow _$VariantRowFromJson(Map<String, dynamic> json) => _VariantRow(
  variantId: (json['variant_id'] as num).toInt(),
  attributes:
      (json['attributes'] as List<dynamic>?)
          ?.map((e) => ProductSpec.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  defaultCode: json['default_code'] as String?,
  availability: json['availability'] == null
      ? null
      : ProductAvailability.fromJson(
          json['availability'] as Map<String, dynamic>,
        ),
  price: Price.fromJson(json['price'] as Map<String, dynamic>),
  subtotal: json['subtotal'] == null
      ? null
      : Price.fromJson(json['subtotal'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VariantRowToJson(_VariantRow instance) =>
    <String, dynamic>{
      'variant_id': instance.variantId,
      'attributes': instance.attributes,
      'default_code': instance.defaultCode,
      'availability': instance.availability,
      'price': instance.price,
      'subtotal': instance.subtotal,
    };

_ProductDetail _$ProductDetailFromJson(Map<String, dynamic> json) =>
    _ProductDetail(
      id: (json['id'] as num).toInt(),
      variantId: (json['variant_id'] as num?)?.toInt(),
      name: json['name'] as String,
      defaultCode: json['default_code'] as String?,
      badge: json['badge'] == null
          ? null
          : ProductBadge.fromJson(json['badge'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      price: Price.fromJson(json['price'] as Map<String, dynamic>),
      clubPrice: json['club_price'] == null
          ? null
          : Price.fromJson(json['club_price'] as Map<String, dynamic>),
      priceTables:
          (json['price_tables'] as List<dynamic>?)
              ?.map((e) => PriceTable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variants: json['variants'] == null
          ? null
          : VariantOptions.fromJson(json['variants'] as Map<String, dynamic>),
      variantRows:
          (json['variant_rows'] as List<dynamic>?)
              ?.map((e) => VariantRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variantTotal: json['variant_total'] == null
          ? null
          : Price.fromJson(json['variant_total'] as Map<String, dynamic>),
      specs:
          (json['specs'] as List<dynamic>?)
              ?.map((e) => ProductSpec.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      brand: json['brand'] == null
          ? null
          : ProductBrand.fromJson(json['brand'] as Map<String, dynamic>),
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => ProductDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      description:
          (json['description'] as List<dynamic>?)
              ?.map((e) => DescriptionBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      availability: json['availability'] == null
          ? null
          : ProductAvailability.fromJson(
              json['availability'] as Map<String, dynamic>,
            ),
      rating: json['rating'] == null
          ? const ProductRating()
          : ProductRating.fromJson(json['rating'] as Map<String, dynamic>),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      similar:
          (json['similar'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      benefits:
          (json['benefits'] as List<dynamic>?)
              ?.map((e) => Benefit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductDetailToJson(_ProductDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'variant_id': instance.variantId,
      'name': instance.name,
      'default_code': instance.defaultCode,
      'badge': instance.badge,
      'images': instance.images,
      'price': instance.price,
      'club_price': instance.clubPrice,
      'price_tables': instance.priceTables,
      'variants': instance.variants,
      'variant_rows': instance.variantRows,
      'variant_total': instance.variantTotal,
      'specs': instance.specs,
      'brand': instance.brand,
      'documents': instance.documents,
      'description': instance.description,
      'availability': instance.availability,
      'rating': instance.rating,
      'reviews': instance.reviews,
      'similar': instance.similar,
      'benefits': instance.benefits,
    };

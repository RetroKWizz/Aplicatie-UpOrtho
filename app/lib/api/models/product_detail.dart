import 'package:freezed_annotation/freezed_annotation.dart';

import 'benefit.dart';
import 'price_table.dart';
import 'product.dart';
import 'product_review.dart';
import 'spec.dart';
import 'variant.dart';

export 'benefit.dart';
export 'description_block.dart';
export 'price.dart';
export 'price_table.dart';
export 'price_tier.dart';
export 'product.dart';
export 'product_badge.dart';
export 'product_review.dart';
export 'spec.dart';
export 'variant.dart';

part 'product_detail.freezed.dart';
part 'product_detail.g.dart';

/// Id-ul intrarii de galerie care reprezinta imaginea principala a produsului.
/// Serverul o trimite mereu prima, cu acest id rezervat.
const mainProductImageId = 0;

/// Tipul unei intrari de galerie. Necunoscutele cad pe `image` — o intrare
/// decorativa nu are voie sa rupa decodarea paginii.
@JsonEnum(valueField: 'value')
enum ProductImageKind {
  image('image'),
  video('video');

  const ProductImageKind(this.value);
  final String value;
}

/// O intrare de galerie. `url` poate lipsi pentru o intrare de tip video fara
/// poza atasata — atunci exista doar `videoUrl`, iar galeria deseneaza un
/// substitut in loc de miniatura.
@freezed
abstract class ProductImage with _$ProductImage {
  const factory ProductImage({
    required int id,
    String? url,
    @JsonKey(unknownEnumValue: ProductImageKind.image)
    @Default(ProductImageKind.image)
    ProductImageKind kind,
    @JsonKey(name: 'video_url') String? videoUrl,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
}

/// Mesajul de disponibilitate. E `null` in contract cand produsul n-are mesaj si
/// nici `show_availability` — atunci sectiunea nu se deseneaza. `message` poate fi
/// null si cand obiectul exista (produs cu `show_availability`, fara text).
@freezed
abstract class ProductAvailability with _$ProductAvailability {
  const factory ProductAvailability({
    String? message,
    @JsonKey(name: 'in_stock') @Default(true) bool inStock,
  }) = _ProductAvailability;

  factory ProductAvailability.fromJson(Map<String, dynamic> json) =>
      _$ProductAvailabilityFromJson(json);
}

/// Raspunsul complet al lui `GET /products/<id>`.
///
/// Reguli de forma, garantate de contract si reflectate aici:
/// - `clubPrice`, `variants`, `availability`, `badge`, `variantId` sunt `null` cand
///   nu se aplica; **fiecare sectiune fara date dispare complet** de pe ecran;
/// - `priceTables`, `specs`, `description`, `reviews`, `similar`, `benefits`,
///   `images` sunt liste goale, niciodata null;
/// - `similar` are exact forma unui produs din `/products`, deci se reia acelasi
///   model `Product` si acelasi `ProductCard`, fara conversii;
/// - `priceTables` e o lista tocmai pentru ca site-ul arata unul, doua sau niciun
///   tabel, cu titluri pe care le stie doar serverul (vezi `PriceTable`); ecranul le
///   deseneaza in ordinea primita si nu presupune niciodata cate sunt.
///
/// Toate sumele sunt siruri gata formatate de server (`formatted`,
/// `listFormatted`) — aplicatia nu face niciodata aritmetica pe bani.
@freezed
abstract class ProductDetail with _$ProductDetail {
  const factory ProductDetail({
    required int id,
    @JsonKey(name: 'variant_id') int? variantId,
    required String name,
    @JsonKey(name: 'default_code') String? defaultCode,
    ProductBadge? badge,
    @Default([]) List<ProductImage> images,
    required Price price,
    @JsonKey(name: 'club_price') Price? clubPrice,
    @JsonKey(name: 'price_tables') @Default([]) List<PriceTable> priceTables,
    VariantOptions? variants,
    @Default([]) List<ProductSpec> specs,
    @Default([]) List<DescriptionBlock> description,
    ProductAvailability? availability,
    @Default(ProductRating()) ProductRating rating,
    @Default([]) List<ProductReview> reviews,
    @Default([]) List<Product> similar,
    @Default([]) List<Benefit> benefits,
  }) = _ProductDetail;

  factory ProductDetail.fromJson(Map<String, dynamic> json) => _$ProductDetailFromJson(json);
}

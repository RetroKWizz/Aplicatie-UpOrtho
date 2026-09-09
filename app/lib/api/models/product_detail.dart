import 'package:freezed_annotation/freezed_annotation.dart';

import 'benefit.dart';
import 'price_table.dart';
import 'product.dart';
import 'product_brand.dart';
import 'product_document.dart';
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
export 'product_brand.dart';
export 'product_document.dart';
export 'product_review.dart';
export 'spec.dart';
export 'variant.dart';
export 'variant_prices.dart';

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

/// Un rand din tabelul de comanda pe variante — ce arata site-ul pe pagina unui
/// produs cu mai multe variante: valorile de atribut ale variantei, codul ei,
/// disponibilitatea si pretul unitar.
///
/// Lista de randuri e goala pentru un produs cu o singura varianta; atunci ecranul
/// pastreaza forma dinainte (selectorul `variants`, cand exista).
///
/// `subtotal` e subtotalul de **pornire**, la cantitatea zero cu care se deschide
/// tabelul — gata formatat de server, ca ecranul sa arate sume reale din primul
/// cadru fara sa scrie el "0,00 lei" (aplicatia nu formateaza bani). Subtotalurile
/// de dupa se cer prin `POST /products/<id>/prices`, pentru ca o cantitate mai mare
/// poate trece un prag de pret. Poate lipsi (server mai vechi): atunci coloana
/// ramane pe liniuta.
@freezed
abstract class VariantRow with _$VariantRow {
  const factory VariantRow({
    @JsonKey(name: 'variant_id') required int variantId,
    @Default([]) List<ProductSpec> attributes,
    @JsonKey(name: 'default_code') String? defaultCode,
    ProductAvailability? availability,
    required Price price,
    Price? subtotal,
  }) = _VariantRow;

  factory VariantRow.fromJson(Map<String, dynamic> json) => _$VariantRowFromJson(json);
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

    /// Tabelul de comanda pe variante. Cand are randuri, ele inlocuiesc selectorul
    /// `variants` pe ecran: fiecare varianta isi are deja randul ei, cu pretul si
    /// cantitatea ei.
    @JsonKey(name: 'variant_rows') @Default([]) List<VariantRow> variantRows,

    /// Totalul de pornire al tabelului de variante (toate cantitatile pe zero),
    /// gata formatat de server. `null` cand nu exista tabel — sau cand serverul e
    /// mai vechi si nu-l trimite, si atunci Totalul ramane pe liniuta pana la
    /// primul raspuns de preturi.
    @JsonKey(name: 'variant_total') Price? variantTotal,
    @Default([]) List<ProductSpec> specs,

    /// Chenarul de brand (logo, nume, descriere). `null` cand produsul n-are
    /// brand — sau cand serverul e mai vechi si nu trimite campul.
    ProductBrand? brand,

    /// Documentele produsului (tabul "Documente" de pe site). Lista goala cand
    /// produsul n-are documente — sau cand serverul e mai vechi si nu trimite
    /// campul; atunci sectiunea lipseste complet de pe ecran.
    @Default([]) List<ProductDocument> documents,
    @Default([]) List<DescriptionBlock> description,
    ProductAvailability? availability,
    @Default(ProductRating()) ProductRating rating,
    @Default([]) List<ProductReview> reviews,
    @Default([]) List<Product> similar,
    @Default([]) List<Benefit> benefits,
  }) = _ProductDetail;

  factory ProductDetail.fromJson(Map<String, dynamic> json) => _$ProductDetailFromJson(json);
}

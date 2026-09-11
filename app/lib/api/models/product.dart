import 'package:freezed_annotation/freezed_annotation.dart';

import 'price.dart';
import 'product_badge.dart';
import 'product_review.dart';

export 'price.dart';
export 'product_badge.dart';
export 'product_review.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Un produs din grila de catalog (`GET /products`). Preturile sunt `Price`
/// gata formatate de server — vezi regula "nicio aritmetica pe bani" din CLAUDE.md.
@freezed
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    @JsonKey(name: 'default_code') String? defaultCode,
    @JsonKey(name: 'image_url') String? imageUrl,
    required Price price,
    @JsonKey(name: 'club_price') Price? clubPrice,
    ProductBadge? badge,
    /// Nota din recenzii; null cand produsul n-are niciuna - la fel ca pe site, unde
    /// pastila cu nota nici nu apare atunci.
    ProductRating? rating,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

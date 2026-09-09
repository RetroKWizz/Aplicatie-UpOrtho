import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_review.freezed.dart';
part 'product_review.g.dart';

/// Media si numarul de recenzii ale produsului. Calculate pe server, pe TOATE
/// recenziile, nu doar pe cele intoarse in `reviews`.
@freezed
abstract class ProductRating with _$ProductRating {
  const factory ProductRating({
    @Default(0.0) double average,
    @Default(0) int count,
  }) = _ProductRating;

  factory ProductRating.fromJson(Map<String, dynamic> json) => _$ProductRatingFromJson(json);
}

/// O recenzie. `author` lipseste cand contactul din Odoo n-are nume, iar `date`
/// vine ca sir ISO (`2026-02-14`) — nu se face aritmetica de calendar pe ea.
@freezed
abstract class ProductReview with _$ProductReview {
  const factory ProductReview({
    String? author,
    @Default(0) int rating,
    String? date,
    @Default('') String text,
  }) = _ProductReview;

  factory ProductReview.fromJson(Map<String, dynamic> json) => _$ProductReviewFromJson(json);
}

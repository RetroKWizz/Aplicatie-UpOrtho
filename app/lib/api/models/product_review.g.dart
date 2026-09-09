// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductRating _$ProductRatingFromJson(Map<String, dynamic> json) =>
    _ProductRating(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductRatingToJson(_ProductRating instance) =>
    <String, dynamic>{'average': instance.average, 'count': instance.count};

_ProductReview _$ProductReviewFromJson(Map<String, dynamic> json) =>
    _ProductReview(
      author: json['author'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      date: json['date'] as String?,
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$ProductReviewToJson(_ProductReview instance) =>
    <String, dynamic>{
      'author': instance.author,
      'rating': instance.rating,
      'date': instance.date,
      'text': instance.text,
    };

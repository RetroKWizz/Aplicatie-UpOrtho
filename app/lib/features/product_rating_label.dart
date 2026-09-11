import '../api/models/product_review.dart';

/// Nota de pe cardul de produs, scrisa cu o zecimala ("5.0"), ca pe site
/// (tema foloseste `'%.1f' % rating_stats['avg']`).
///
/// Null cand produsul n-are nicio recenzie: acolo site-ul nu deseneaza pastila deloc.
String? productRatingLabel(ProductRating? rating) {
  if (rating == null || rating.count == 0) return null;
  return rating.average.toStringAsFixed(1);
}

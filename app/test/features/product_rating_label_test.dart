import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/api/models/product_review.dart';
import 'package:uportho_app/features/product_rating_label.dart';

void main() {
  test('nota se scrie cu o zecimala, ca pe site', () {
    expect(productRatingLabel(const ProductRating(average: 5.0, count: 3)), '5.0');
    expect(productRatingLabel(const ProductRating(average: 4.25, count: 4)), '4.3');
  });

  test('fara recenzii nu exista pastila', () {
    expect(productRatingLabel(null), isNull);
    expect(productRatingLabel(const ProductRating(average: 0.0, count: 0)), isNull);
  });
}

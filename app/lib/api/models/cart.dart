import 'package:freezed_annotation/freezed_annotation.dart';

import 'price.dart';

export 'price.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

/// O linie din cos. Toate sumele vin gata calculate si gata formatate de server:
/// `subtotal` NU e `unitPrice * quantity` calculat aici, pentru ca o cantitate mai
/// mare poate trece un prag al listei de preturi si schimba pretul unitar
/// (CLAUDE.md: aplicatia nu face niciodata aritmetica pe bani).
@freezed
abstract class CartLine with _$CartLine {
  const factory CartLine({
    required int id,
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'variant_id') required int variantId,
    required String name,
    @JsonKey(name: 'variant_name') String? variantName,
    @JsonKey(name: 'default_code') String? defaultCode,
    @JsonKey(name: 'image_url') String? imageUrl,
    required int quantity,
    @JsonKey(name: 'unit_price') required Price unitPrice,
    required Price subtotal,
    String? warning,
  }) = _CartLine;

  factory CartLine.fromJson(Map<String, dynamic> json) => _$CartLineFromJson(json);
}

/// Totalurile cosului. `delivery` si `total` includ TVA, ca tot restul API-ului.
@freezed
abstract class CartAmounts with _$CartAmounts {
  const factory CartAmounts({
    required Price untaxed,
    required Price tax,
    required Price delivery,
    required Price total,
  }) = _CartAmounts;

  factory CartAmounts.fromJson(Map<String, dynamic> json) => _$CartAmountsFromJson(json);
}

/// Progresul catre livrarea gratuita, asa cum il calculeaza magazinul. Lipseste
/// (null) cand magazinul nu are niciun curier cu prag de livrare gratuita.
@freezed
abstract class FreeDeliveryProgress with _$FreeDeliveryProgress {
  const factory FreeDeliveryProgress({
    @JsonKey(name: 'free_over') required Price freeOver,
    @JsonKey(name: 'order_amount') required Price orderAmount,
    required Price remaining,
    required bool reached,
  }) = _FreeDeliveryProgress;

  factory FreeDeliveryProgress.fromJson(Map<String, dynamic> json) =>
      _$FreeDeliveryProgressFromJson(json);
}

/// Cosul intreg. E chiar cosul magazinului: aceeasi sesiune Odoo, deci ce adaugi in
/// aplicatie apare si in browser.
///
/// Un cos inexistent nu e o eroare - vine aceeasi forma cu `orderId` null si `lines`
/// gol, ca ecranul sa aiba un singur drum de randare.
@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    @JsonKey(name: 'order_id') int? orderId,
    @Default(0) int quantity,
    @Default([]) List<CartLine> lines,
    required CartAmounts amounts,
    @JsonKey(name: 'free_delivery') FreeDeliveryProgress? freeDelivery,
    String? warning,
    /// Avertismentele stranse de server la ultima modificare (stoc ajustat, cantitate
    /// redusa). Vin o singura data, in raspunsul modificarii - un `GET /cart` de dupa
    /// nu le mai contine.
    @Default([]) List<String> warnings,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  const Cart._();

  bool get isEmpty => lines.isEmpty;
}

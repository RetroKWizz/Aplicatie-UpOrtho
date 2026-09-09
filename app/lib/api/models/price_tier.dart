import 'package:freezed_annotation/freezed_annotation.dart';

import 'price.dart';

export 'price.dart';

part 'price_tier.freezed.dart';
part 'price_tier.g.dart';

/// Un prag de cantitate: de la `minQty` bucati in sus se aplica `price`. Eticheta
/// (`1+`, `3+`) vine gata scrisa de server, la fel ca suma — aplicatia nu compune
/// niciun text de pret si nu face aritmetica pe bani (vezi CLAUDE.md).
@freezed
abstract class PriceTier with _$PriceTier {
  const factory PriceTier({
    @JsonKey(name: 'min_qty') required int minQty,
    required String label,
    required Price price,
  }) = _PriceTier;

  factory PriceTier.fromJson(Map<String, dynamic> json) => _$PriceTierFromJson(json);
}

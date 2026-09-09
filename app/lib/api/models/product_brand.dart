import 'package:freezed_annotation/freezed_annotation.dart';

import 'description_block.dart';

part 'product_brand.freezed.dart';
part 'product_brand.g.dart';

/// Chenarul de brand de pe pagina de produs: logo, nume si descriere — exact ce
/// arata site-ul deasupra descrierii produsului.
///
/// `null` in raspuns cand produsul n-are brand; atunci sectiunea lipseste complet de
/// pe ecran, ca toate celelalte.
///
/// `description` vine deja in blocuri, ca descrierea produsului — niciodata HTML,
/// aplicatia nu are motor HTML. `logoUrl` e o ruta de imagine autentificata a
/// modulului (logoul chiar se deseneaza in aplicatie), deci are nevoie de aceleasi
/// headere ca restul imaginilor.
///
/// Brandul apare si in tabelul de specificatii: pe site e in amandoua locurile.
@freezed
abstract class ProductBrand with _$ProductBrand {
  const factory ProductBrand({
    required String name,
    @Default([]) List<DescriptionBlock> description,
    @JsonKey(name: 'logo_url') String? logoUrl,
  }) = _ProductBrand;

  factory ProductBrand.fromJson(Map<String, dynamic> json) => _$ProductBrandFromJson(json);
}

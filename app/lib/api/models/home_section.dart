import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

export 'product.dart';

part 'home_section.freezed.dart';
part 'home_section.g.dart';

/// Un rand de produse de pe Acasa, compus in Odoo (Website -> Aplicatie mobila ->
/// Sectiuni pe Acasa). Titlul si ce produse intra se schimba fara release in store.
///
/// Produsele au exact forma din catalog: serverul le trece prin acelasi domeniu si
/// aceeasi ordine, deci un rand de pe Acasa nu poate arata alt pret sau alte produse
/// decat catalogul.
@freezed
abstract class HomeSection with _$HomeSection {
  const factory HomeSection({
    required int id,
    required String title,
    /// Categoria din spatele randului, cand randul e facut dintr-o categorie: "Vezi
    /// toate" duce atunci in catalog, pe ea. Null pentru produse alese de mana.
    @JsonKey(name: 'category_id') int? categoryId,
    @Default([]) List<Product> products,
  }) = _HomeSection;

  factory HomeSection.fromJson(Map<String, dynamic> json) => _$HomeSectionFromJson(json);
}

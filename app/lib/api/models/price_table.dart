import 'package:freezed_annotation/freezed_annotation.dart';

import 'description_block.dart';
import 'price_tier.dart';

export 'description_block.dart';
export 'price_tier.dart';

part 'price_table.freezed.dart';
part 'price_table.g.dart';

/// Un tabel de preturi al paginii de produs, exact cel de pe site.
///
/// Serverul trimite o LISTA de asemenea tabele, nu doua campuri fixe: magazinul
/// arata unul, doua sau niciunul, iar titlurile sunt ale listelor de pret de acolo
/// (pe productie, al doilea e un nume de campanie). De aceea `title` vine de la
/// server si aplicatia nu scrie niciun titlu de tabel.
///
/// `note` e textul de pe lista de pret (`bulk_info` pe site), trimis ca blocuri —
/// niciodata HTML, aplicatia nu are motor HTML. `title` poate lipsi.
@freezed
abstract class PriceTable with _$PriceTable {
  const factory PriceTable({
    String? title,
    @Default([]) List<DescriptionBlock> note,
    @Default([]) List<PriceTier> entries,
  }) = _PriceTable;

  factory PriceTable.fromJson(Map<String, dynamic> json) => _$PriceTableFromJson(json);
}

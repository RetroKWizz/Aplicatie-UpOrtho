import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing.freezed.dart';
part 'pricing.g.dart';

/// Daca preturile se vad in raspunsul primit, si de ce nu, cand nu se vad.
///
/// Vine de la server, si asta e tot rostul lui: aplicatia nu decide din starea ei de
/// autentificare daca are voie sa arate preturi. O sesiune expirata arata inca
/// "autentificat" in aplicatie cat timp nu cere nimic, iar atunci cele doua adevaruri
/// s-ar despica si ecranul ar promite un pret pe care serverul nu l-a trimis.
///
/// Lipsa blocului (server mai vechi) inseamna "preturile se vad": asa se comporta
/// aplicatia dintotdeauna, deci absenta lui nu ascunde nimic pe neasteptate.
@freezed
abstract class Pricing with _$Pricing {
  const factory Pricing({
    @Default(true) bool visible,

    /// De ce lipsesc preturile. Azi serverul trimite doar `sign_in_required`; e un
    /// sir, nu o enumerare, ca un motiv nou sa nu rupa aplicatia veche.
    String? reason,
  }) = _Pricing;

  factory Pricing.fromJson(Map<String, dynamic> json) => _$PricingFromJson(json);
}

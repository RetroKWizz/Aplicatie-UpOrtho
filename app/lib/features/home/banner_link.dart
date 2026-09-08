/// URL-ul extern al unui banner, transformat in `Uri` doar daca e sigur de deschis.
///
/// `launchUrl(..., LaunchMode.externalApplication)` deschide orice aplicatie care
/// pretinde schema respectiva, iar `banner.link.url` vine dintr-un camp de baza de
/// date editabil din backend. Doua capcane:
/// - `Uri.tryParse('')` intoarce un `Uri` valid, fara schema, deci o garda pe null
///   nu prinde nimic;
/// - o schema arbitrara (`tel:`, `mailto:`, `intent:`, o schema custom a altei
///   aplicatii) ar fi deschisa fara sa fie o navigare web.
///
/// Intoarce `null` cand URL-ul lipseste, nu se poate parsa, nu e `http`/`https`
/// sau nu are host. Apelantul nu deschide nimic in cazul asta.
Uri? externalBannerUri(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final uri = Uri.tryParse(raw.trim());
  if (uri == null) return null;
  if (!uri.isScheme('http') && !uri.isScheme('https')) return null;
  if (uri.host.isEmpty) return null;
  return uri;
}

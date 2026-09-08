/// Compara originea (schema + host + port) unui URL absolut cu originea proprie
/// a API-ului. Folosit ca sa nu trimitem cookie-ul de sesiune Odoo catre o alta
/// origine (ex. un viitor CDN extern pentru imagini) - o comparatie pe prefixul
/// stringului (`startsWith`) ar fi ocolita de un URL construit anume sa inceapa
/// la fel, de exemplu http de la apiBaseUrl-ul nostru urmat de un domeniu strain.
bool isSameOrigin(String url, String apiBaseUrl) {
  try {
    final target = Uri.parse(url);
    final base = Uri.parse(apiBaseUrl);
    // Uri.origin arunca StateError daca schema nu e http/https sau host-ul e gol -
    // tratam orice URL "ciudat" ca fiind de alta origine, nu ca eroare.
    return target.origin == base.origin;
  } on FormatException {
    return false;
  } on StateError {
    return false;
  }
}

/// Headerele de imagine (cookie de sesiune Odoo) trebuie atasate doar cand URL-ul
/// imaginii tinteste efectiv originea proprie a API-ului. `ApiClient.absoluteUrl`
/// are un ram pass-through pentru URL-uri deja absolute (pentru raspunsuri viitoare
/// de la backend), asa ca un URL absolut catre alta origine nu trebuie sa mai
/// primeasca acest cookie - vezi FINDING 2 din review-ul fix-ului de autentificare
/// a imaginilor.
Map<String, String>? imageHeadersFor(
  String url, {
  required String apiBaseUrl,
  required Map<String, String>? headers,
}) {
  if (headers == null || headers.isEmpty) return null;
  return isSameOrigin(url, apiBaseUrl) ? headers : null;
}

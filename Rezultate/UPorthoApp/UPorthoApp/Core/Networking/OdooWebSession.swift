import Foundation

/// Erori proprii ale sesiunii web Odoo.
enum OdooWebSessionError: Error, LocalizedError {
    case missingCSRFToken
    case loginFailed
    case notAuthenticated
    case transportError
    case invalidResponse
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .missingCSRFToken:
            return "Nu s-a putut obtine token-ul de securitate de la server."
        case .loginFailed:
            return "Autentificare esuata pe site."
        case .notAuthenticated:
            return "Sesiune web inactiva — autentifica-te intai."
        case .transportError:
            return "Eroare de retea la comunicarea cu site-ul."
        case .invalidResponse:
            return "Raspuns invalid de la site."
        case .serverMessage(let message):
            return message
        }
    }
}

/// Sesiune web autentificata catre uportho.ro (Odoo `website_sale`), separata de
/// `OdooRPCClient` (JSON-RPC pt catalog).
///
/// DE CE un al doilea client: fluxul de cos + checkout al site-ului NU e un API JSON, ci
/// modulul standard Odoo `website_sale` — rute care raspund cu pagini HTML randate
/// server-side (form POST -> redirect -> pagina noua). Ca sa conducem EXACT acelasi flux ca
/// site-ul (toata logica de business — curieri, reguli de plata, totaluri — ramanand in
/// Odoo, nereimplementata la noi), avem nevoie de o sesiune de tip browser: cookie de
/// sesiune + token CSRF, nu autentificare XML-RPC/JSON-RPC prin parola.
///
/// Cookie-ul de sesiune (`session_id`) e gestionat automat de `URLSession` prin
/// `HTTPCookieStorage`-ul propriu (izolat, nu cel partajat al aplicatiei).
actor OdooWebSession {
    private let baseURL: URL
    private let session: URLSession
    private var authenticated = false

    init(baseURL: URL = OdooConfig.baseURL) {
        self.baseURL = baseURL
        // `.ephemeral` (NU `.default` + `HTTPCookieStorage()` instantiat manual): configuratia
        // efemera vine cu un cookie storage PRIVAT DAR FUNCTIONAL, gestionat de sistem — izolat de
        // restul aplicatiei, fara sa fie nevoie sa il cream noi. Bug depistat live (17.07.2026):
        // `HTTPCookieStorage()` apelat direct (nu `.shared`) NU persista efectiv cookie-urile intre
        // cereri pe iOS — fiecare request pornea o sesiune Odoo noua (anonima), astfel incat
        // csrf_token obtinut la un GET nu mai era valid la POST-ul urmator (mereu 400, indiferent
        // de regexul de extragere) si `/web/login` / `/web/session/authenticate` "reuseau" fara sa
        // ramana efectiv autentificati (verificat cu `/web/session/get_session_info` -> uid=nil
        // desi `authenticated=true`).
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        self.session = URLSession(configuration: configuration)
    }

    var isAuthenticated: Bool {
        authenticated
    }

    // MARK: - Autentificare

    /// Autentifica sesiunea web prin `/web/session/authenticate` (endpoint JSON), NU prin
    /// formularul HTML `/web/login`.
    ///
    /// DE CE nu formularul: `/web/login` accepta doar PAROLA de cont; o cheie API (cu care
    /// utilizatorul se poate autentifica la RPC pt catalog) e respinsa acolo -> "Autentificare
    /// esuata pe site" desi catalogul merge. `/web/session/authenticate` foloseste EXACT acelasi
    /// mecanism de credentiale ca `common.authenticate` (clientul JSON-RPC al catalogului),
    /// deci reuseste cu orice credential care deja functioneaza pentru catalog, si — crucial —
    /// seteaza cookie-ul `session_id` necesar rutelor `website_sale` (`/shop/*`).
    ///
    /// La succes, raspunsul e `{"result": {"uid": <int>, ...}}`; la esec, Odoo intoarce un obiect
    /// `error` (AccessDenied). URLSession retine automat cookie-ul de sesiune.
    func login(username: String, password: String) async throws {
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "db": OdooConfig.database,
                "login": username,
                "password": password
            ],
            "id": Int.random(in: 1...100_000)
        ]

        var request = URLRequest(url: baseURL.appendingPathComponent("web/session/authenticate"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let (data, _) = try await performData(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw OdooWebSessionError.invalidResponse
        }
        // Esec explicit de autentificare -> AccessDenied in `error`.
        if json["error"] != nil {
            throw OdooWebSessionError.loginFailed
        }
        // Succes: `result.uid` e un intreg pozitiv (uid == false / lipsa => credential invalid).
        guard let result = json["result"] as? [String: Any],
              let uid = result["uid"] as? Int, uid > 0 else {
            throw OdooWebSessionError.loginFailed
        }

        authenticated = true
    }

    func logout() async {
        authenticated = false
        var request = URLRequest(url: baseURL.appendingPathComponent("web/session/logout"))
        request.httpMethod = "GET"
        _ = try? await performData(for: request)
    }

    // MARK: - Apeluri generice

    /// GET pe o ruta web (relativa la `baseURL`), intorcand HTML-ul raspunsului ca String.
    /// Folosit de `CheckoutService` pentru pasii care randeaza pagini (adrese, checkout, plata).
    func getHTML(path: String) async throws -> String {
        guard authenticated else { throw OdooWebSessionError.notAuthenticated }
        var request = URLRequest(url: try makeURL(path: path))
        request.httpMethod = "GET"
        // Fara asta, cereri identice repetate (ex. `/shop/checkout?try_skip_step=true` dupa
        // crearea unei adrese) pot intoarce un raspuns CACHED de URLSession, mascand schimbari
        // reale de stare pe server — reprodus live 17.07.2026 (lungime raspuns identica byte-cu-
        // byte inainte/dupa crearea unei adrese noi).
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let (data, _) = try await performData(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            throw OdooWebSessionError.invalidResponse
        }
        return html
    }

    /// POST de formular (`application/x-www-form-urlencoded`) pe o ruta web. Adauga automat
    /// `csrf_token` daca apelantul nu l-a inclus deja (rutele `website_sale` il cer). Intoarce
    /// HTML-ul paginii rezultate.
    func postForm(path: String, fields: [String: String]) async throws -> String {
        guard authenticated else { throw OdooWebSessionError.notAuthenticated }

        var allFields = fields
        if allFields["csrf_token"] == nil {
            allFields["csrf_token"] = try await fetchCSRFToken()
        }

        var request = URLRequest(url: try makeURL(path: path))
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.formEncode(allFields).data(using: .utf8)

        let (data, _) = try await performData(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            throw OdooWebSessionError.invalidResponse
        }
        return html
    }

    /// POST JSON-RPC catre o ruta web care raspunde JSON (ex. `/shop/cart/update_json`,
    /// `/shop/carrier_rate_shipment`). Envelope-ul e acelasi JSON-RPC 2.0 ca la `OdooRPCClient`,
    /// dar catre rute `website_sale`, nu catre `/jsonrpc`. Intoarce campul `result`.
    func postJSON(path: String, params: [String: Any]) async throws -> Any {
        guard authenticated else { throw OdooWebSessionError.notAuthenticated }

        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": params,
            "id": Int.random(in: 1...100_000)
        ]
        guard JSONSerialization.isValidJSONObject(payload) else {
            throw OdooWebSessionError.transportError
        }

        var request = URLRequest(url: try makeURL(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, _) = try await performData(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw OdooWebSessionError.invalidResponse
        }
        if let error = json["error"] as? [String: Any] {
            // DBG temporar: "Odoo Server Error" (mesajul de top-nivel) e generic — detaliile
            // reale (numele exceptiei Python + traceback) sunt in `error.data`.
            let dataDict = error["data"] as? [String: Any]
            let detail = (dataDict?["message"] as? String) ?? (dataDict?["name"] as? String)
            let debugTrace = (dataDict?["debug"] as? String)?.prefix(600)
            let message = detail ?? (error["message"] as? String) ?? "Eroare de la server."
            let full = debugTrace.map { "\(message)\n\n[DBG]\n\($0)" } ?? message
            throw OdooWebSessionError.serverMessage(full)
        }
        // Unele rute (ex. `/shop/update_address`) raspund JSON-RPC valid, fara `error`, dar si
        // FARA cheia `result` (verificat live 18.07.2026: `{"jsonrpc":"2.0","id":...}`, nimic
        // altceva) — Odoo omite `result` cand controller-ul intoarce `None`. Absenta lui NU e o
        // eroare (am verificat deja mai sus ca `error` lipseste) — tratam ca succes cu rezultat gol.
        return json["result"] ?? NSNull()
    }

    // MARK: - Helpers

    /// Id-ul `res.partner` al contului autentificat (verificat live 18.07.2026:
    /// `/web/session/get_session_info` -> `result.partner_id`, disponibil pt orice sesiune cu
    /// cookie valid, fara nevoie de uid/parola RPC). Folosit ca sa citim adresele copil ale
    /// contului (vezi `CheckoutService.fetchAddresses`).
    func fetchPartnerId() async throws -> Int {
        let result = try await postJSON(path: "/web/session/get_session_info", params: [:])
        guard let dict = result as? [String: Any], let partnerId = dict["partner_id"] as? Int else {
            throw OdooWebSessionError.invalidResponse
        }
        return partnerId
    }

    /// Token-ul CSRF al sesiunii (per-sesiune in Odoo). Necesar in payload-ul rutelor JSON care
    /// il cer explicit (ex. `/shop/payment/transaction/<id>`).
    func csrfToken() async throws -> String {
        try await fetchCSRFToken()
    }

    /// Token CSRF extras dintr-o pagina anume a sesiunii autentificate. Unele rute
    /// (ex. `/shop/address/submit`) resping token-ul luat de pe `/web/login` (care, la o sesiune
    /// deja autentificata, poate redirectiona) — pentru ele luam csrf-ul chiar de pe pagina
    /// formularului corespunzator (ex. `/shop/address`), garantat valid pt sesiunea curenta.
    func csrfToken(fromPath path: String) async throws -> String {
        let html = try await getHTML(path: path)
        guard let token = Self.extractCSRFToken(from: html) else {
            throw OdooWebSessionError.missingCSRFToken
        }
        return token
    }

    /// Extrage `csrf_token` din HTML-ul unei pagini (formularele `website_sale`/login il pun ca
    /// input ascuns). Il luam de pe pagina de login (accesibila si neautentificat).
    private func fetchCSRFToken() async throws -> String {
        var request = URLRequest(url: baseURL.appendingPathComponent("web/login"))
        request.httpMethod = "GET"
        let (data, _) = try await performData(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            throw OdooWebSessionError.missingCSRFToken
        }
        guard let token = Self.extractCSRFToken(from: html) else {
            throw OdooWebSessionError.missingCSRFToken
        }
        return token
    }

    /// Extrage valoarea `csrf_token` dintr-un input ascuns, ROBUST la ordinea atributelor:
    /// input-ul poate fi `<input name="csrf_token" value="...">` SAU `<input value="..."
    /// name="csrf_token">`, cu alte atribute intercalate. (Vechea versiune cerea `value` imediat
    /// dupa `name` — pe paginile unde intervin alte atribute rezulta csrf gol -> 400 la submit.)
    static func extractCSRFToken(from html: String) -> String? {
        let patterns = [
            "name=\"csrf_token\"[^>]*?\\bvalue=\"([^\"]+)\"",
            "value=\"([^\"]+)\"[^>]*?\\bname=\"csrf_token\""
        ]
        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
                  let match = regex.firstMatch(in: html, options: [], range: range),
                  match.numberOfRanges > 1,
                  let tokenRange = Range(match.range(at: 1), in: html) else { continue }
            return String(html[tokenRange])
        }
        return nil
    }

    private func makeURL(path: String) throws -> URL {
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard let url = URL(string: trimmed, relativeTo: baseURL) else {
            throw OdooWebSessionError.transportError
        }
        return url
    }

    private func performData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw OdooWebSessionError.transportError
        }
    }

    private static func formEncode(_ fields: [String: String]) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+&=")
        return fields.map { key, value in
            let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
            return "\(k)=\(v)"
        }.joined(separator: "&")
    }
}

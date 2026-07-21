import Foundation

/// Conduce fluxul real de checkout al uportho.ro folosind EXACT rutele modulului standard
/// Odoo `website_sale`, prin `OdooWebSession` (cookie de sesiune + CSRF). Nu reimplementeaza
/// nicio logica de business: curieri, tarife, reguli de plata si totalurile raman calculate
/// de Odoo — noi doar POSTam formularele/JSON-ul si citim rezultatul, exact ca browserul.
/// Astfel, orice schimbare facuta in Odoo (curieri noi, alte metode de plata) se reflecta
/// automat, fara modificari in aplicatie.
///
/// Harta rutelor (capturata live pe 15-16.07.2026, comanda de test CMD41597):
///   /shop/cart/update_json   POST JSON  — adauga/actualizeaza linie in coș
///   /shop/checkout           GET  HTML  — adrese (livrare/facturare) + lista curieri
///   /shop/update_address     POST form  — selecteaza o adresa (partner_id + mode)
///   /shop/set_delivery_method POST JSON — seteaza curierul ales
///   /shop/get_delivery_rate  POST JSON  — (re)calculeaza tariful curierului
///   /shop/extra_info         POST form  — nota comenzii
///   /shop/payment            GET  HTML  — metode de plata
///   /shop/payment/transaction POST JSON — creeaza tranzactia (pas de CONFIRMAT live, vezi mai jos)
///   /payment/status          GET  HTML  — pagina de confirmare (nr. comanda)
///
/// NIVELE DE INCREDERE:
///   • Rutele JSON (cart/update_json, get_delivery_rate, set_delivery_method) sunt controllere
///     Odoo standard `type="json"` — stabile, envelope JSON-RPC 2.0 (gestionat de OdooWebSession).
///   • Parsarea HTML (adrese, curieri, metode de plata, referinta comenzii) e mai FRAGILA
///     (depinde de markup-ul theme_prime) — decizie asumata a userului. E izolata in helperele
///     de la finalul fisierului si e defensiva (esueaza curat, nu creeaza date gunoi).
///   • `placeOrder(...)` foloseste ruta de tranzactie; payload-ul exact NU a fost inca verificat
///     byte-cu-byte pe transfer bancar — vezi comentariul de pe metoda. NU se apeleaza dintr-un
///     buton live pana la confirmarea userului (task #30).
actor CheckoutService {
    private let session: OdooWebSession

    init(session: OdooWebSession) {
        self.session = session
    }

    // MARK: - Coș

    /// Adauga `quantity` bucati din varianta `productId` (id de `product.product`, NU de
    /// `product.template`) in coșul server-side. Pt produse fara variante, `productId` e id-ul
    /// variantei implicite (`product.template.product_variant_id`), nu al template-ului.
    @discardableResult
    func addToCart(productId: Int, quantity: Int) async throws -> CartServerState {
        let result = try await session.postJSON(
            path: "/shop/cart/update_json",
            params: ["product_id": productId, "add_qty": quantity]
        )
        return Self.parseCartState(from: result)
    }

    /// Fixeaza cantitatea unei linii existente (`sale.order.line`) la `quantity` (0 = elimina).
    ///
    /// `productId` e OBLIGATORIU aici: controller-ul temei (`ThemePrimeWebsiteSale.cart_update_json`,
    /// suprascrierea locala a rutei standard `website_sale`) declara `product_id` ca parametru
    /// pozitional fara valoare implicita — un POST cu doar `line_id`/`set_qty` (care functioneaza pe
    /// `website_sale` standard) pica cu 200 OK dar payload de eroare JSON-RPC: "cart_update_json()
    /// missing 1 required positional argument: 'product_id'" (reprodus live 21.07.2026, la pasul de
    /// sincronizare a coșului: eliminarea unei linii ramase pe server dintr-o incercare anterioara,
    /// pt un produs care nu mai era in coșul local, bloca tot fluxul de checkout chiar inainte de
    /// pasul de facturare). `syncCart` are deja `productId`-ul (cheia dictionarului `serverLines`) —
    /// il pasam mereu.
    @discardableResult
    func setCartLineQuantity(lineId: Int, productId: Int, quantity: Int) async throws -> CartServerState {
        let result = try await session.postJSON(
            path: "/shop/cart/update_json",
            params: ["line_id": lineId, "product_id": productId, "set_qty": quantity]
        )
        return Self.parseCartState(from: result)
    }

    /// Liniile REALE aflate in acest moment in coșul server-side (`sale.order` draft-ul curent
    /// al utilizatorului), citite din `/shop/cart` (verificat live 18.07.2026: input-uri
    /// `<input class="js_quantity" data-line-id data-product-id value>`). Necesar pt sincronizare
    /// reala cu coșul local — vezi `syncCart`.
    func fetchCartLines() async throws -> [Int: (lineId: Int, quantity: Int)] {
        let html = try await session.getHTML(path: "/shop/cart")
        return Self.parseCartLines(from: html)
    }

    // MARK: - Checkout (adrese + curieri)

    /// Rezultatul unui GET pe `/shop/checkout`: fie pagina reala de checkout (carduri de adresa +
    /// curieri), fie — cand Odoo considera ca mai lipseste o adresa — chiar formularul de adaugare
    /// pt tipul respectiv (`/shop/address`, randat inline, FARA redirect HTTP).
    ///
    /// CAPCANA depistata live (17.07.2026): un formular de adresa nu are NICIUN card
    /// `data-partner-id` (indiferent de tip), deci verificarea naiva "delivery.isEmpty" pe baza
    /// cardurilor gasite cerea mereu din nou LIVRAREA chiar si atunci cand doar FACTURAREA mai
    /// lipsea (contul avea deja o adresa de livrare) — Odoo intorcea formularul de facturare, care
    /// are 0 carduri, identic cu formularul de livrare. Solutia: cand raspunsul e un formular,
    /// citim `address_type`-ul lui direct din pagina (nu il ghicim din cate carduri lipsesc).
    enum CheckoutOrAddressForm {
        case checkout(addresses: [CheckoutAddress], delivery: [DeliveryOption])
        case addressForm(AddressFormSpec)
    }

    func fetchCheckout() async throws -> CheckoutOrAddressForm {
        let html = try await session.getHTML(path: "/shop/checkout?try_skip_step=true")
        if let spec = Self.parseAddressFormSpec(from: html) {
            return .addressForm(spec)
        }
        return .checkout(addresses: Self.parseAddresses(from: html), delivery: Self.parseDeliveryOptions(from: html))
    }

    /// Selecteaza o adresa pt comanda curenta (verificat live: JSON `{address_type, partner_id}`).
    /// `addressType` e "delivery" (livrare) sau "billing" (facturare).
    func selectAddress(partnerId: Int, addressType: String) async throws {
        _ = try await session.postJSON(
            path: "/shop/update_address",
            params: ["address_type": addressType, "partner_id": String(partnerId)]
        )
    }

    // MARK: - Adrese (listare + creare noua)

    /// Adresele copil (livrare/facturare) salvate deja in contul clientului — citite direct prin
    /// `res.partner`, INDEPENDENT de logica interna a lui `/shop/checkout` (care decide singura,
    /// in ordinea ei, ce formular arata — nu ne permite un flux propriu, cu pas de facturare
    /// inaintea celui de livrare). Verificat live 18.07.2026: `POST /web/dataset/call_kw` (aceeasi
    /// sesiune cu cookie, fara uid/parola RPC) -> `res.partner.search_read` pe `parent_id =
    /// <contul curent>`. In `res.partner`, tipul de adresa e `"invoice"` (NU `"billing"` — acela e
    /// doar parametrul rutelor `website_sale`); mapam intern.
    func fetchAddresses(type: String) async throws -> [CheckoutAddress] {
        let partnerId = try await session.fetchPartnerId()
        let partnerType = type == "billing" ? "invoice" : type
        let params: [String: Any] = [
            "model": "res.partner",
            "method": "search_read",
            "args": [
                [["parent_id", "=", partnerId], ["type", "=", partnerType]],
                ["id", "name", "street", "city"]
            ],
            "kwargs": [String: Any]()
        ]
        let result = try await session.postJSON(path: "/web/dataset/call_kw", params: params)
        guard let rows = result as? [[String: Any]] else { return [] }
        return rows.compactMap { row in
            guard let id = row["id"] as? Int else { return nil }
            let name = row["name"] as? String ?? ""
            let street = row["street"] as? String
            let city = row["city"] as? String
            let detail = [street, city].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
            let label = detail.isEmpty ? name : "\(name) — \(detail)"
            return CheckoutAddress(id: id, partnerId: id, mode: type, name: label)
        }
    }

    /// Formularul de adaugare adresa pt tipul cerut ("delivery"/"billing"). GET pe
    /// `/shop/address?address_type=<tip>` (verificat live: parametrul controleaza tipul randat,
    /// INDIFERENT de ce adrese exista deja — asa putem oferi mereu optiunea "adauga adresa noua",
    /// chiar daca utilizatorul are deja una).
    func fetchAddressForm(addressType: String) async throws -> AddressFormSpec? {
        let html = try await session.getHTML(path: "/shop/address?address_type=\(addressType)")
        return Self.parseAddressFormSpec(from: html)
    }

    /// Localitatile din registru pt un judet (verificat live 17.07.2026: `POST
    /// /shop/state_infos/<stateId>` -> JSON-RPC `{cities: [[id, "Nume (Jud)", "cod_postal"], ...]}`).
    /// Instanta uportho.ro impune orase din registru — `/shop/address/submit` respinge un `city`
    /// text liber fara `city_id` corespunzator (`invalid_fields: [city_id]`).
    func fetchCities(stateId: Int) async throws -> [CityOption] {
        let result = try await session.postJSON(path: "/shop/state_infos/\(stateId)", params: [:])
        guard let dict = result as? [String: Any],
              let rows = dict["cities"] as? [[Any]] else { return [] }
        return rows.compactMap { row -> CityOption? in
            guard row.count >= 2,
                  let id = (row[0] as? Int) ?? (row[0] as? Double).map(Int.init),
                  let name = row[1] as? String else { return nil }
            let zip = (row.count > 2 ? row[2] as? String : nil) ?? ""
            return CityOption(id: id, name: name, zip: zip)
        }
    }

    /// Trimite o adresa noua prin `POST /shop/address/submit` (ruta standard `website_sale`,
    /// Odoo 18 — verificat live pe uportho.ro, 16.07.2026: JS-ul face `rpc('/shop/address/submit',
    /// new FormData(form))` si citeste `result.redirectUrl`). Campurile merg form-urlencoded
    /// (`csrf_token` adaugat automat de `OdooWebSession.postForm`).
    ///
    /// Raspunsul e JSON: la succes contine `redirectUrl` (pasul urmator, decis de Odoo — poate fi
    /// alt formular de adresa sau pagina de checkout); la eroare, `invalid_fields`/`messages`.
    /// Intoarce `redirectUrl` (informativ); controlul revine la `pendingAddressForm()`, care re-cere
    /// serverului ce mai lipseste — nu reimplementam secventa billing/delivery, o dicteaza Odoo.
    @discardableResult
    func submitAddress(draft: CheckoutAddressDraft, addressType: String, requiredFields: String) async throws -> String {
        var fields: [String: String] = [
            "name": draft.name,
            "email": draft.email,
            "phone": draft.phone,
            "company_name": draft.companyName,
            "vat": draft.vat,
            "street": draft.street,
            "street2": draft.street2,
            "city": draft.city,
            "zip": draft.zip,
            "country_id": String(draft.countryId),
            "address_type": addressType,
            "required_fields": requiredFields
        ]
        if let county = draft.countyId {
            fields["state_id"] = String(county)
        }
        if let cityId = draft.cityId {
            fields["city_id"] = String(cityId)
        }
        // csrf luat DE PE pagina formularului de adresa (garantat valid pt sesiune) — ruta
        // `/shop/address/submit` respinge cu 400 (HTML) un csrf lipsa/gresit.
        fields["csrf_token"] = try await session.csrfToken(fromPath: "/shop/address?address_type=\(addressType)")

        let body = try await session.postForm(path: "/shop/address/submit", fields: fields)
        return try Self.parseAddressSubmitResult(from: body)
    }

    // MARK: - Livrare (curier)

    /// Seteaza curierul ales pe comanda curenta. Cheia e `dm_id` (== `data-dm-id`, verificat live),
    /// NU `carrier_id`.
    func setDeliveryMethod(dmId: Int) async throws {
        _ = try await session.postJSON(
            path: "/shop/set_delivery_method",
            params: ["dm_id": String(dmId)]
        )
    }

    /// (Re)calculeaza tariful unui curier. Raspuns verificat live: `{success, price, carrier_price,
    /// is_free_delivery, amount_delivery}`. Returnam `price` numeric (0 la livrare gratuita).
    func deliveryRate(dmId: Int) async throws -> Decimal? {
        let result = try await session.postJSON(
            path: "/shop/get_delivery_rate",
            params: ["dm_id": String(dmId)]
        )
        guard let dict = result as? [String: Any] else { return nil }
        if (dict["is_free_delivery"] as? Bool) == true { return 0 }
        if let price = dict["price"] { return Self.decimal(fromLoose: price) }
        if let amount = dict["amount_delivery"] { return Self.decimal(fromLoose: amount) }
        return nil
    }

    // MARK: - Info suplimentare

    // Nota `/shop/extra_info` e un widget `/website/form/` separat si optional — se sare
    // (GET-ul catre `/shop/payment` finalizeaza pasul). Nu o expunem.

    // MARK: - Plata

    /// Citeste pagina de plata: metodele disponibile SI contextul formularului (necesar pt tranzactie).
    func fetchPayment() async throws -> (options: [PaymentOption], context: PaymentContext?) {
        let html = try await session.getHTML(path: "/shop/payment")
        return (Self.parsePaymentOptions(from: html), Self.parsePaymentContext(from: html))
    }

    /// Plaseaza comanda REALA cu metoda de plata aleasa. Flux verificat LIVE (16.07.2026, CMD41604):
    ///
    /// 1. POST `context.transactionRoute` (ex. `/shop/payment/transaction/<orderId>`) cu:
    ///    `{provider_id, payment_method_id, token_id: null, amount, flow: "redirect",
    ///      tokenization_requested: false, landing_route, is_validation: false, access_token, csrf_token}`
    ///    → raspuns `{reference: "CMD...", redirect_form_html: "<form action=.../payment/custom/process>...>"}`.
    ///    (Transfer bancar / `custom` foloseste flow "redirect", NU "direct".)
    /// 2. Se submite formularul de redirect (POST `/payment/custom/process` cu `reference`), care
    ///    finalizeaza comanda si redirectioneaza la `landing_route` -> `/payment/status`.
    ///
    /// Referinta comenzii vine DIRECT din raspunsul tranzactiei — fara parsare de HTML.
    func placeOrder(providerId: Int, paymentMethodId: Int, context: PaymentContext) async throws -> OrderConfirmation {
        let csrf = try await session.csrfToken()
        let params: [String: Any] = [
            "provider_id": providerId,
            "payment_method_id": paymentMethodId,
            "token_id": NSNull(),
            "amount": NSDecimalNumber(decimal: context.amount).doubleValue,
            "flow": "redirect",
            "tokenization_requested": false,
            "landing_route": context.landingRoute,
            "is_validation": false,
            "access_token": context.accessToken,
            "csrf_token": csrf
        ]

        let result = try await session.postJSON(path: context.transactionRoute, params: params)
        guard let dict = result as? [String: Any],
              let reference = dict["reference"] as? String else {
            throw OdooWebSessionError.serverMessage("Tranzactie esuata (fara referinta).")
        }

        // Submite formularul de redirect (finalizeaza comanda pt provider offline).
        if let redirectHTML = dict["redirect_form_html"] as? String,
           let action = Self.formAction(in: redirectHTML) {
            var fields = Self.hiddenInputs(in: redirectHTML)
            fields["csrf_token"] = csrf
            _ = try? await session.postForm(path: action, fields: fields)
        }

        let amount = (dict["amount"]).flatMap { Self.decimal(fromLoose: $0) } ?? context.amount
        return OrderConfirmation(reference: reference, amountRON: amount)
    }
}

// MARK: - Parsare raspunsuri

private extension CheckoutService {

    static func parseCartState(from result: Any) -> CartServerState {
        let dict = result as? [String: Any] ?? [:]
        let count = (dict["cart_quantity"] as? Int)
            ?? (dict["cart_quantity"] as? Double).map(Int.init)
            ?? 0
        let lineId = (dict["line_id"] as? Int)
            ?? (dict["line_id"] as? Double).map(Int.init)
        return CartServerState(itemCount: count, lineId: lineId)
    }

    /// Liniile de coș din HTML-ul `/shop/cart`: `<input class="js_quantity" data-line-id
    /// data-product-id value>` (verificat live 18.07.2026). Cheia e `product_id` (== varianta),
    /// ca sa se poata reconcilia direct cu coșul local (indexat tot dupa `product.product`).
    static func parseCartLines(from html: String) -> [Int: (lineId: Int, quantity: Int)] {
        var results: [Int: (lineId: Int, quantity: Int)] = [:]
        for tag in openingTags(in: html, containingAttribute: "data-line-id") {
            guard let productId = tagAttributeInt("data-product-id", in: tag),
                  let lineId = tagAttributeInt("data-line-id", in: tag) else { continue }
            let quantity = tagAttribute("value", in: tag).flatMap { Int(Double($0) ?? 0) } ?? 0
            results[productId] = (lineId: lineId, quantity: quantity)
        }
        return results
    }

    /// Adresele de pe checkout. Fiecare card e un element cu `data-address-type`
    /// ("delivery"/"billing") si `data-partner-id="<id>"` (verificat live 16.07.2026).
    /// Numele/adresa (textul cardului) nu se extrag din HTML brut (fragil) — UI-ul cade pe
    /// eticheta "Adresa #id"; pastram `mode` ca sa filtram adresele de livrare.
    static func parseAddresses(from html: String) -> [CheckoutAddress] {
        var results: [CheckoutAddress] = []
        var seen = Set<String>()
        for tag in openingTags(in: html, containingAttribute: "data-address-type") {
            guard let partnerId = tagAttributeInt("data-partner-id", in: tag),
                  let mode = tagAttribute("data-address-type", in: tag) else { continue }
            let key = "\(mode)#\(partnerId)"
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            results.append(CheckoutAddress(id: partnerId, partnerId: partnerId, mode: mode, name: ""))
        }
        return results
    }

    /// Detecteaza daca `html` e formularul `/shop/address` si-i extrage specificatia. Ancora e
    /// actiunea `/shop/address/submit`; `address_type`/`required_fields` sunt input-uri ascunse.
    static func parseAddressFormSpec(from html: String) -> AddressFormSpec? {
        guard html.contains("/shop/address/submit") else { return nil }
        let addressType = inputTags(in: html, withName: "address_type")
            .compactMap { tagAttribute("value", in: $0) }.first ?? "delivery"
        let required = inputTags(in: html, withName: "required_fields")
            .compactMap { tagAttribute("value", in: $0) }.first ?? "name,country_id"
        return AddressFormSpec(addressType: addressType, requiredFields: required)
    }

    /// Interpreteaza raspunsul JSON al `/shop/address/submit`. La succes intoarce `redirectUrl`;
    /// la eroare arunca un mesaj citibil compus din `messages`/`invalid_fields`. Raspunsul poate
    /// veni direct (`{redirectUrl}`) sau invelit intr-un `{result:{...}}` (envelope JSON-RPC).
    static func parseAddressSubmitResult(from body: String) throws -> String {
        guard let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw OdooWebSessionError.invalidResponse
        }
        let payload = (json["result"] as? [String: Any]) ?? json

        if let url = payload["redirectUrl"] as? String, !url.isEmpty {
            return url
        }

        var reasons: [String] = []
        if let messages = payload["messages"] as? [Any] {
            reasons += messages.compactMap { ($0 as? [String: Any])?["message"] as? String ?? $0 as? String }
        } else if let message = payload["message"] as? String {
            reasons.append(message)
        }
        let invalidNames: [String]
        if let list = payload["invalid_fields"] as? [Any] {
            invalidNames = list.compactMap { $0 as? String }
        } else if let dict = payload["invalid_fields"] as? [String: Any] {
            invalidNames = Array(dict.keys)
        } else {
            invalidNames = []
        }
        if !invalidNames.isEmpty {
            reasons.append("Campuri lipsa sau invalide: \(invalidNames.joined(separator: ", ")).")
        }

        throw OdooWebSessionError.serverMessage(
            reasons.isEmpty ? "Adresa nu a putut fi salvata." : reasons.joined(separator: " ")
        )
    }

    /// Curierii: input-uri `<input name="o_delivery_radio" data-dm-id="<carrierId>"
    /// data-delivery-type="...">`. `data-dm-id` E id-ul de `delivery.carrier` (== `carrier_id`
    /// pt `/shop/set_delivery_method`). Numele vine din eticheta dedicata
    /// `<label class="o_delivery_carrier_label" for="o_delivery_<id>">NUME</label>` (randata imediat
    /// dupa input, in acelasi `<div class="d-flex form-check">`) — NU din textul intregului rand.
    ///
    /// BUG reprodus live (21.07.2026): textul randului mai contine, mai jos, un
    /// `<span class="o_wsale_delivery_price_badge" name="price">Selectați pentru a calcula tariful
    /// de livrare</span>` — placeholder-ul pe care JS-ul site-ului il inlocuieste cu tariful real
    /// dupa un apel AJAX (`/shop/get_delivery_rate`), pe care aplicatia nu-l declanseaza (nu executam
    /// JS). Cand `rowText` (tot textul dintre acest radio si urmatorul) era folosit direct ca sursa
    /// pt nume, acest placeholder ajungea concatenat dupa numele curierului — "Fan Courier Selectați
    /// pentru a calcula tariful de livrare" — afisat garbled in UI (asta a fost eroarea semnalata la
    /// pasul de livrare). Extragem numele STRICT din `<label>`; `rowText` ramane folosit doar pt
    /// detectia "gratuit"/pretului numeric (cand exista deja un tarif fix in HTML).
    static func parseDeliveryOptions(from html: String) -> [DeliveryOption] {
        var results: [DeliveryOption] = []
        var seen = Set<Int>()
        let tags = inputTags(in: html, withName: "o_delivery_radio")
        for (index, tag) in tags.enumerated() {
            guard let carrierId = tagAttributeInt("data-dm-id", in: tag) else { continue }
            guard !seen.contains(carrierId) else { continue }
            seen.insert(carrierId)
            let rowText = rowText(after: tag, in: html, until: index + 1 < tags.count ? tags[index + 1] : nil)
            let isFree = rowText.range(of: "gratuit", options: .caseInsensitive) != nil
            let price = decimal(fromLoose: rowText)
            let inputId = tagAttribute("id", in: tag)
            let name = inputId.flatMap { carrierLabelName(forInputId: $0, in: html) }
                ?? cleanCarrierName(rowText)
            results.append(DeliveryOption(
                id: carrierId, carrierId: carrierId, name: name,
                priceRON: isFree ? 0 : price, isFree: isFree
            ))
        }
        return results
    }

    /// Metodele de plata: `<input name="o_payment_radio" data-provider-id="5"
    /// data-payment-option-id="217" data-payment-method-code="wire_transfer">` (verificat live).
    static func parsePaymentOptions(from html: String) -> [PaymentOption] {
        var results: [PaymentOption] = []
        var seen = Set<Int>()
        for tag in inputTags(in: html, withName: "o_payment_radio") {
            guard let providerId = tagAttributeInt("data-provider-id", in: tag),
                  let methodId = tagAttributeInt("data-payment-option-id", in: tag) else { continue }
            guard !seen.contains(methodId) else { continue }
            seen.insert(methodId)
            let code = tagAttribute("data-payment-method-code", in: tag) ?? ""
            results.append(PaymentOption(
                id: methodId, providerId: providerId, paymentMethodId: methodId, code: code
            ))
        }
        return results
    }

    /// Contextul de plata din `<form ... class="o_payment_form" data-amount data-currency-id
    /// data-partner-id data-access-token data-transaction-route data-landing-route ...>`.
    /// Ancoram pe `data-transaction-route` (unic pe pagina).
    static func parsePaymentContext(from html: String) -> PaymentContext? {
        guard let tag = regexFirst(in: html, pattern: "(<form\\b[^>]*\\bdata-transaction-route=\"[^\"]+\"[^>]*>)")
                ?? openingTags(in: html, containingAttribute: "data-transaction-route").first,
              let route = tagAttribute("data-transaction-route", in: tag),
              let token = tagAttribute("data-access-token", in: tag) else { return nil }
        let amount = tagAttribute("data-amount", in: tag).flatMap { Decimal(string: $0) } ?? 0
        let currencyId = tagAttributeInt("data-currency-id", in: tag) ?? 0
        let partnerId = tagAttributeInt("data-partner-id", in: tag) ?? 0
        let landing = tagAttribute("data-landing-route", in: tag) ?? "/shop/payment/validate"
        return PaymentContext(
            amount: amount, currencyId: currencyId, partnerId: partnerId,
            accessToken: token, transactionRoute: route, landingRoute: landing
        )
    }

    /// `action="..."` al primului `<form>` dintr-un fragment HTML.
    static func formAction(in html: String) -> String? {
        regexFirst(in: html, pattern: "<form\\b[^>]*\\baction=\"([^\"]+)\"")
    }

    /// Perechile `name`/`value` ale input-urilor ascunse dintr-un fragment HTML.
    static func hiddenInputs(in html: String) -> [String: String] {
        var fields: [String: String] = [:]
        for tag in regexAll(in: html, pattern: "(<input\\b[^>]*>)") {
            if let name = tagAttribute("name", in: tag) {
                fields[name] = tagAttribute("value", in: tag) ?? ""
            }
        }
        return fields
    }

    // MARK: Utilitare de parsare per-tag (robuste: extrag atribute dintr-un SINGUR tag)

    /// Toate tag-urile `<input ...>` cu `name="<name>"`, ca substring-uri intregi.
    static func inputTags(in html: String, withName name: String) -> [String] {
        regexAll(in: html, pattern: "(<input\\b[^>]*\\bname=\"\(name)\"[^>]*>)")
    }

    /// Toate tag-urile de deschidere care contin atributul dat (ex. `data-address-type`).
    static func openingTags(in html: String, containingAttribute attr: String) -> [String] {
        regexAll(in: html, pattern: "(<[a-zA-Z][^>]*\\b\(attr)=\"[^\"]*\"[^>]*>)")
    }

    /// Valoarea unui atribut dintr-un tag deja izolat.
    static func tagAttribute(_ attr: String, in tag: String) -> String? {
        regexFirst(in: tag, pattern: "\\b\(attr)=\"([^\"]*)\"")
    }

    static func tagAttributeInt(_ attr: String, in tag: String) -> Int? {
        tagAttribute(attr, in: tag).flatMap { Int($0) }
    }

    /// Textul vizibil (fara tag-uri) care urmeaza dupa `tag`, pana la `next` (sau ~300 caractere).
    /// Folosit pt numele/tariful curierului, care sunt in eticheta de langa input.
    static func rowText(after tag: String, in html: String, until next: String?) -> String {
        guard let start = html.range(of: tag)?.upperBound else { return "" }
        let end: String.Index
        if let next, let nextRange = html.range(of: next, range: start..<html.endIndex) {
            end = nextRange.lowerBound
        } else {
            end = html.index(start, offsetBy: 300, limitedBy: html.endIndex) ?? html.endIndex
        }
        return stripTags(String(html[start..<end]))
    }

    static func stripTags(_ s: String) -> String {
        let noTags = s.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        return noTags.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Numele curierului, extras strict din `<label class="o_delivery_carrier_label" for="<inputId>">
    /// NUME</label>` (verificat live 21.07.2026) — sursa robusta, spre deosebire de `rowText`
    /// (tot textul dintre doi radio-i), care include si placeholder-ul de pret necalculat
    /// ("Selectați pentru a calcula tariful de livrare"). `nil` daca eticheta nu se gaseste
    /// (markup schimbat) — apelantul cade pe `cleanCarrierName(rowText)`.
    static func carrierLabelName(forInputId inputId: String, in html: String) -> String? {
        let escapedId = NSRegularExpression.escapedPattern(for: inputId)
        guard let match = regexFirst(
            in: html,
            pattern: "<label\\b[^>]*\\bfor=\"\(escapedId)\"[^>]*>([\\s\\S]*?)</label>"
        ) else { return nil }
        let text = stripTags(match)
        return text.isEmpty ? nil : text
    }

    /// Curata numele curierului: scoate pretul/"gratuit" si placeholder-ul de pret necalculat
    /// ("Selectați pentru a calcula tariful de livrare") din textul randului. Fallback defensiv,
    /// folosit doar cand `carrierLabelName` nu gaseste eticheta dedicata.
    static func cleanCarrierName(_ rowText: String) -> String {
        var name = rowText
        name = name.replacingOccurrences(of: "\\d[\\d.]*,\\d{2}\\s*lei", with: "", options: [.regularExpression, .caseInsensitive])
        name = name.replacingOccurrences(of: "gratuit", with: "", options: .caseInsensitive)
        name = name.replacingOccurrences(of: "Selectați pentru a calcula tariful de livrare", with: "", options: .caseInsensitive)
        name = name.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Utilitare regex / numerice

    static func regexInts(in text: String, pattern: String) -> [Int] {
        regexAll(in: text, pattern: pattern).compactMap { Int($0) }
    }

    static func regexAll(in text: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            guard match.numberOfRanges > 1, let r = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[r])
        }
    }

    static func regexFirst(in text: String, pattern: String) -> String? {
        regexAll(in: text, pattern: pattern).first
    }

    /// Converteste o suma "libera" (numar JSON, sau string ca "2,48 lei" / "1.063,09") in Decimal.
    /// Trateaza formatul romanesc: `.` = separator de mii, `,` = zecimale.
    static func decimal(fromLoose value: Any) -> Decimal? {
        if let d = value as? Double { return Decimal(d) }
        if let i = value as? Int { return Decimal(i) }
        guard let s = value as? String else { return nil }
        // Pastreaza doar cifre, `.` si `,`; apoi normalizeaza la formatul Decimal (punct zecimal).
        let filtered = s.filter { $0.isNumber || $0 == "." || $0 == "," }
        guard !filtered.isEmpty else { return nil }
        let normalized = filtered.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }
}

import Foundation
import UIKit
import SwiftUI

/// Erori specifice implementarii reale a `OdooClient`.
enum RealOdooClientError: Error, LocalizedError {
    case invalidCredentials
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email sau parola incorecte."
        case .notAuthenticated:
            return "Trebuie sa fii autentificat pentru aceasta actiune."
        }
    }
}

/// Randuri brute (deja tipizate din raspunsul JSON-RPC) folosite intern la asamblarea
/// catalogului — vezi sectiunea "Catalog" din `RealOdooClient`.
private struct CategoryRow {
    let id: Int
    let name: String
    let parentId: Int?
    /// Id-urile produselor taguite DIRECT pe aceasta categorie (nu si pe subcategorii) —
    /// `buildCategoryTree` face uniunea recursiva cu subcategoriile ca sa afiseze un numar
    /// total corect (un produs poate fi taguit pe mai multe categorii, de-aia Set, nu suma).
    let productTemplateIds: Set<Int>
}

private struct VariantRow {
    let id: Int
    let templateId: Int
    let sku: String
    let priceRON: Decimal
    let inStock: Bool
    let attributeValueIds: [Int]
}

/// Un singur rand brut `product.pricelist.item`, indiferent de scope (`applied_on`).
/// Vezi `PricelistRuleIndex` pt gruparea in memorie si `RealOdooClient.effectivePrice`
/// pt algoritmul de selectie intre reguli aplicabile la produs / categorie / global.
private struct PricelistRuleRow {
    let pricelistId: Int
    let appliedOn: String
    let productTemplateId: Int?
    let categId: Int?
    let minQuantity: Double
    let computePrice: String
    let percentPrice: Decimal
    let fixedPrice: Decimal
}

/// Index in memorie al tuturor regulilor de pricelist relevante pt pagina curenta de produse,
/// grupate dupa scope (`1_product` / `2_product_category` / `3_global`) ca sa poata fi gasite
/// rapid, fara nicio interogare suplimentara, regulile aplicabile unui produs dat.
private struct PricelistRuleIndex {
    var productRules: [Int: [Int: [PricelistRuleRow]]] = [:]   // pricelistId -> product_tmpl_id -> reguli
    var categoryRules: [Int: [Int: [PricelistRuleRow]]] = [:]  // pricelistId -> categ_id -> reguli
    var globalRules: [Int: [PricelistRuleRow]] = [:]           // pricelistId -> reguli

    /// Toate regulile aplicabile (din toate cele 3 scope-uri combinate) unui produs dat,
    /// pt un pricelist dat — INAINTE de filtrarea dupa `min_quantity`.
    func applicableRules(pricelistId: Int, productTemplateId: Int, categId: Int?) -> [PricelistRuleRow] {
        var result = productRules[pricelistId]?[productTemplateId] ?? []
        if let categId, let categoryMatches = categoryRules[pricelistId]?[categId] {
            result += categoryMatches
        }
        if let global = globalRules[pricelistId] {
            result += global
        }
        return result
    }
}

private struct AttributeValueRow {
    let label: String
    let value: String
}

/// Un rand brut `account.tax` — folosit ca sa calculam TVA per-produs dinamic in loc de o
/// cota fixa. Vezi `RealOdooClient.taxMultiplier(forTaxIds:taxesById:)`.
private struct TaxRow {
    let amount: Decimal
    let priceInclude: Bool
}

/// Implementare reala a `OdooClient`, folosind JSON-RPC catre instanta Odoo a uportho.ro.
///
/// REGULA STRICTA (vezi CLAUDE.md / .claude/agents/odoo-integration.md): aceasta
/// implementare foloseste DOAR metode de citire — `authenticate`, `read`,
/// `search_read`. Niciodata `write`, `create`, `unlink` sau alte metode de scriere.
///
/// `fetchBanners` cloneaza sliderul REAL de pe homepage-ul uportho.ro — parseaza sectiunea
/// `s_banner_12` din `arch_db`-ul view-ului `website.homepage` (nu exista un model dedicat de
/// "banner de site"/promotie in Odoo, deci nu se citeste un model separat, ci HTML-ul paginii).
///
/// `fetchCategories`/`fetchProducts`/`fetchBanners` folosesc date reale din Odoo DOAR cand exista o
/// sesiune autentificata (`uid`/`password` in memorie, setate de `login`) — accesul
/// XML-RPC/JSON-RPC la `product.public.category`/`product.template` necesita un
/// utilizator autentificat (verificat empiric: apel anonim -> `AccessDenied`). Cand
/// userul NU e logat (ex. Acasa/Catalog rasfoite ca guest, la fel ca pe site), se cade
/// pe `MockOdooClient` ca sa nu ramana ecranele goale — decizie de design care merita
/// discutata cu Mihai (varianta corecta pe termen lung ar fi un cont tehnic dedicat
/// doar-citire pt catalog, sau expunerea catalogului prin alt canal, nu prin credentiale
/// personale de portal hardcodate in aplicatie).
actor RealOdooClient: OdooClient {
    private let rpc: OdooRPCClient
    private let catalogFallback = MockOdooClient()

    /// ID-urile pricelist-urilor relevante (confirmate manual in Odoo, read-only).
    private static let publicPricelistId = 45
    private static let orthoClubPricelistId = 59

    /// ID-ul site-ului "uportho.ro 2025" in Odoo — confirmat empiric ca instanta e
    /// MULTI-WEBSITE: aceeasi baza de date gazduieste si `uportho.com 2025` (varianta in
    /// engleza, alt website_id), plus alte site-uri (tunealigners.ro, ortho-shop.ro etc).
    /// `product.public.category` NU e filtrata automat de Odoo dupa website la citire prin
    /// API — fara acest filtru explicit, categoriile arata amestecat romana+engleza (134 in
    /// total, doar 78 apartin de fapt uportho.ro). Filtrul se aplica la `fetchCategoryRows`.
    private static let websiteId = 11

    /// Fallback DOAR pt cazul (neasteptat) in care citirea `account.tax` esueaza la runtime
    /// (ex. dreptul de citire e revocat din nou in viitor) — TVA se citeste acum DINAMIC per
    /// produs din `product.template.taxes_id` -> `account.tax.amount` (vezi `fetchTaxRows`),
    /// dupa ce contul de test a primit drept de citire read-only pe contabilitate. Confirmat
    /// empiric pe toate cele 539 de produse publicate: o singura taxa per produs, uniform 21%,
    /// `price_include=false`. Aceasta constanta ramane doar ca plasa de siguranta.
    private static let fallbackVatMultiplier: Decimal = 1.21

    /// Fara categorie selectata (ex. Acasa) am trage tot catalogul public (537 produse) —
    /// payload prea mare pt un singur ecran mobil. Limitam rezonabil; o paginare reala e o
    /// imbunatatire ulterioara, separata de acest task. Cu categorie selectata NU limitam
    /// (cea mai mare categorie are ~72 produse, payload OK).
    private static let defaultCatalogLimit = 60

    /// Context de limba trimis explicit la fiecare `execute_kw` de citire text (nume produse,
    /// categorii, atribute) — CONFIRMAT EMPIRIC: fara acest context Odoo intoarce textul in
    /// ENGLEZA, indiferent de `res.users.lang` al contului autentificat (preferinta de limba a
    /// userului NU se aplica automat la apeluri XML-RPC/JSON-RPC, trebuie fortata per-apel).
    private static let roContext: [String: Any] = ["lang": "ro_RO"]

    /// Sesiune in memorie, NU persistata (Keychain se adauga intr-o etapa viitoare,
    /// doar la cerere explicita).
    private var uid: Int?
    private var username: String?
    private var password: String?

    init(baseURL: URL = OdooConfig.baseURL) {
        self.rpc = OdooRPCClient(baseURL: baseURL)
    }

    var isAuthenticated: Bool {
        uid != nil
    }

    // MARK: - Autentificare

    @discardableResult
    func login(username: String, password: String) async throws -> Bool {
        let result = try await rpc.call(
            service: "common",
            method: "authenticate",
            args: [OdooConfig.database, username, password, [String: Any]()]
        )

        // Odoo intoarce `false` (nu eroare) la credentiale gresite.
        guard let authenticatedUid = Self.asInt(result), authenticatedUid > 0 else {
            throw RealOdooClientError.invalidCredentials
        }

        self.uid = authenticatedUid
        self.username = username
        self.password = password
        return true
    }

    func logout() async {
        uid = nil
        username = nil
        password = nil
    }

    // MARK: - Cont

    func fetchAccount() async throws -> UserAccount {
        guard let uid, let password else {
            throw RealOdooClientError.notAuthenticated
        }

        let usersResult = try await rpc.call(
            service: "object",
            method: "execute_kw",
            args: [
                OdooConfig.database, uid, password,
                "res.users", "read",
                [[uid], ["name", "login", "email", "partner_id"]]
            ]
        )

        guard let users = usersResult as? [[String: Any]], let user = users.first else {
            throw OdooRPCError.invalidResponse
        }

        let name = user["name"] as? String ?? ""
        let email = (user["email"] as? String) ?? (user["login"] as? String) ?? ""

        var vatNumber: String?
        if let partnerRef = user["partner_id"] as? [Any], let partnerId = Self.asInt(partnerRef.first) {
            let partnersResult = try await rpc.call(
                service: "object",
                method: "execute_kw",
                args: [
                    OdooConfig.database, uid, password,
                    "res.partner", "read",
                    [[partnerId], ["vat"]]
                ]
            )
            if let partners = partnersResult as? [[String: Any]], let partner = partners.first {
                // Odoo intoarce `false` (Bool), nu null/empty string, cand campul Char e gol —
                // cast-ul la String esueaza natural in acel caz, deci vatNumber ramane nil.
                vatNumber = partner["vat"] as? String
            }
        }

        return UserAccount(id: uid, name: name, email: email, vatNumber: vatNumber)
    }

    // MARK: - Facturi

    func fetchInvoices() async throws -> [Invoice] {
        guard let uid, let password else {
            throw RealOdooClientError.notAuthenticated
        }

        let partnerId = try await currentPartnerId(uid: uid, password: password)

        let domain: [Any] = [
            ["partner_id", "=", partnerId],
            ["move_type", "=", "out_invoice"],
            ["state", "=", "posted"]
        ]
        let fields = ["name", "invoice_date", "invoice_date_due", "amount_residual", "payment_state"]

        let movesResult = try await rpc.call(
            service: "object",
            method: "execute_kw",
            args: [
                OdooConfig.database, uid, password,
                "account.move", "search_read",
                [domain, fields]
            ]
        )

        guard let moves = movesResult as? [[String: Any]] else {
            throw OdooRPCError.invalidResponse
        }

        return moves.compactMap(Self.makeInvoice(from:))
    }

    // MARK: - Banner (continut controlat din Odoo Studio — model custom `x_app_banner`)

    /// Gradient/icon de rezerva pt cazul (neasteptat) in care un banner nu are imagine
    /// incarcata in Odoo — rotite ciclic intre bannere, ca sa nu arate toate identic.
    private static let bannerFallbackStyles: [(symbolName: String, gradientColors: [Color])] = [
        ("newspaper.fill", [Color(red: 0.42, green: 0.25, blue: 0.63), Color(red: 0.60, green: 0.41, blue: 0.80)]),
        ("doc.text.fill", [Color(red: 0.20, green: 0.45, blue: 0.55), Color(red: 0.30, green: 0.65, blue: 0.70)]),
        ("text.book.closed.fill", [Color(red: 0.85, green: 0.35, blue: 0.30), Color(red: 0.95, green: 0.55, blue: 0.25)])
    ]

    /// Bannerele de pe Acasa (hero + promo) vin dintr-un model custom Odoo Studio
    /// (`x_app_banner`), NU din parsarea HTML a homepage-ului — un `search_read` obisnuit,
    /// la fel ca la produse/categorii, controlat direct de Mihai din Odoo (Website Builder
    /// nu mai are nicio legatura), fara sa depinda de structura interna a temei sau de
    /// upgrade-ul planificat la Odoo 19.
    ///
    /// Nume tehnice de campuri (confirmate din Odoo, `Settings > Technical > Models >
    /// x_app_banner > Fields`):
    ///   x_name              — titlu (eticheta afisata in formular: "Titlu")
    ///   x_studio_subtitlu   — subtitlu
    ///   x_studio_buton      — text CTA
    ///   x_studio_plasare    — selection: "Hero" / "Promo"
    ///   x_studio_tip_link   — selection: "Categorie" / "URL extern" / "Fara link"
    ///   x_studio_categorie  — many2one -> product.public.category (cand tip link = Categorie)
    ///   x_studio_url_extern — link extern (cand tip link = URL extern)
    ///   x_studio_image      — imagine (servita via /web/image/x_app_banner/<id>/x_studio_image,
    ///                         la fel ca la poza de produs — NU o citim in `fields`, doar
    ///                         construim URL-ul din id, ca sa nu tragem base64 inutil)
    ///   x_studio_sequence   — ordine (din feature-ul "Sortare personalizata" din Studio)
    ///   x_active            — activ/arhivat (din feature-ul "Arhivare" din Studio — NU e
    ///                         campul standard Odoo `active`, deci se filtreaza EXPLICIT in
    ///                         domain, nu se aplica automat ca la modelele native)
    func fetchBanners() async throws -> [Banner] {
        guard let uid, let password else {
            return try await catalogFallback.fetchBanners()
        }
        let rows = try await searchRead(
            model: "x_app_banner",
            domain: [["x_active", "=", true]],
            fields: [
                "id", "x_name", "x_studio_subtitlu", "x_studio_buton", "x_studio_plasare",
                "x_studio_tip_link", "x_studio_categorie", "x_studio_url_extern", "x_studio_image"
            ],
            order: "x_studio_sequence asc",
            uid: uid, password: password
        )
        let banners = rows.compactMap { Self.makeAppBanner(fromRow: $0) }
        guard !banners.isEmpty else {
            return try await catalogFallback.fetchBanners()
        }
        return banners
    }

    private static func makeAppBanner(fromRow row: [String: Any]) -> Banner? {
        guard let id = asInt(row["id"]) else { return nil }
        let title = (row["x_name"] as? String) ?? ""
        let subtitle = (row["x_studio_subtitlu"] as? String) ?? ""
        let ctaRaw = row["x_studio_buton"] as? String
        let ctaText = (ctaRaw?.isEmpty == false) ? ctaRaw! : "Vezi produse"
        let isHero = (row["x_studio_plasare"] as? String)?.caseInsensitiveCompare("Hero") == .orderedSame

        let linkType = (row["x_studio_tip_link"] as? String) ?? "Fara link"
        var categoryId: Int?
        var linkURL: URL?
        if linkType.caseInsensitiveCompare("Categorie") == .orderedSame {
            categoryId = asMany2OneId(row["x_studio_categorie"])
        } else if linkType.caseInsensitiveCompare("URL extern") == .orderedSame,
                  let urlString = row["x_studio_url_extern"] as? String, !urlString.isEmpty {
            linkURL = URL(string: urlString)
        }

        // Ruta publica `/web/image/x_app_banner/<id>/x_studio_image` NU functioneaza (drepturi
        // de acces separate de XML-RPC, verificat live — raspunde mereu cu placeholder-ul
        // generic Odoo). Cititm imaginea direct ca base64 prin acelasi canal XML-RPC autentificat
        // care deja citeste restul campurilor cu succes, fara sa umblam la drepturi in Odoo.
        let imageData = (row["x_studio_image"] as? String).flatMap { Data(base64Encoded: $0) }
        let style = bannerFallbackStyles[id % bannerFallbackStyles.count]

        return Banner(
            id: id, title: title, subtitle: subtitle, ctaText: ctaText,
            symbolName: style.symbolName, gradientColors: style.gradientColors,
            imageData: imageData, categoryId: categoryId, linkURL: linkURL, isHero: isHero
        )
    }

    func fetchCategories() async throws -> [ProductCategory] {
        guard let uid, let password else {
            return try await catalogFallback.fetchCategories()
        }
        let rows = try await fetchCategoryRows(uid: uid, password: password)
        return Self.buildCategoryTree(from: rows)
    }

    func fetchProducts(category: String?) async throws -> [Product] {
        guard let uid, let password else {
            return try await catalogFallback.fetchProducts(category: category)
        }

        let categoryRows = try await fetchCategoryRows(uid: uid, password: password)
        let categoryNameById = Dictionary(uniqueKeysWithValues: categoryRows.map { ($0.id, $0.name) })

        var domain: [Any] = [["website_published", "=", true]]
        if let category {
            let matchingIds = categoryRows.filter { $0.name == category }.map(\.id)
            guard !matchingIds.isEmpty else { return [] }
            // Confirmat pe site-ul real (`/shop?category=416` -> 40 produse): a naviga o
            // categorie arata produsele taguite DIRECT pe ea SI pe toate subcategoriile ei
            // recursiv (ex. "Bracketi" are doar 2 produse taguite direct, restul zecilor de
            // bracketi reali sunt taguiti pe subcategoriile "Bracketi metalici"/"estetici"/etc).
            // Fara asta, categoriile-parinte arata aproape goale.
            let allIds = Self.collectDescendantIds(startingFrom: matchingIds, in: categoryRows)
            domain.append(["public_categ_ids", "in", allIds])
        }
        let limit: Int? = category == nil ? Self.defaultCatalogLimit : nil

        // `order: "website_sequence, name"` — `website_sequence` e campul dedicat ordinii din
        // Website > Shop (drag&drop), diferit de `sequence` (folosit la categorii) — confirmat
        // prin `fields_get` pe `product.template`. Fara asta, ordinea implicita (id-uri) nu
        // coincide cu ce arata site-ul.
        let templateRows = try await searchRead(
            model: "product.template", domain: domain,
            fields: ["id", "name", "list_price", "public_categ_ids", "categ_id", "qty_available", "taxes_id"],
            order: "website_sequence, name",
            limit: limit, uid: uid, password: password
        )
        guard !templateRows.isEmpty else { return [] }

        let templateIds = templateRows.compactMap { Self.asInt($0["id"]) }
        // `categ_id` = categoria interna/contabila a produsului (folosita de regulile de
        // pricelist la nivel de categorie), DIFERITA de `public_categ_ids` (folosit doar
        // pt afisarea/filtrarea pe site).
        var categIdByTemplate: [Int: Int] = [:]
        var taxIdsByTemplate: [Int: [Int]] = [:]
        for row in templateRows {
            guard let id = Self.asInt(row["id"]) else { continue }
            if let categId = Self.asMany2OneId(row["categ_id"]) {
                categIdByTemplate[id] = categId
            }
            taxIdsByTemplate[id] = (row["taxes_id"] as? [Any])?.compactMap(Self.asInt) ?? []
        }
        let distinctCategIds = Array(Set(categIdByTemplate.values))
        let distinctTaxIds = Array(Set(taxIdsByTemplate.values.flatMap { $0 }))

        // Batched: cate un singur query pt toate variantele, cate un singur query per scope
        // de pricelist (produs / categorie / global), si un singur `read` pt toate taxele
        // relevante — niciodata produs-cu-produs intr-un loop.
        async let variantsTask = fetchVariantRows(templateIds: templateIds, uid: uid, password: password)
        async let ruleIndexTask = fetchPricelistRuleIndex(
            templateIds: templateIds, categIds: distinctCategIds, uid: uid, password: password
        )
        async let taxRowsTask = fetchTaxRows(ids: distinctTaxIds, uid: uid, password: password)

        let variants = try await variantsTask
        let ruleIndex = try await ruleIndexTask
        // Citirea taxelor poate esua (ex. dreptul e revocat din nou) — nu trebuie sa pice tot
        // catalogul pt asta, cadem pe `fallbackVatMultiplier` per produs in acel caz.
        let taxesById = (try? await taxRowsTask) ?? [:]

        let attributeValueIds = Array(Set(variants.flatMap { $0.attributeValueIds }))
        let attributeValues = try await fetchAttributeValueRows(ids: attributeValueIds, uid: uid, password: password)

        let variantsByTemplate = Dictionary(grouping: variants, by: { $0.templateId })

        return templateRows.compactMap { row -> Product? in
            guard let id = Self.asInt(row["id"]), let name = row["name"] as? String else { return nil }
            let listPrice = Self.asDecimal(row["list_price"]) ?? 0
            let qty = Self.asDouble(row["qty_available"]) ?? 0
            let categIds = (row["public_categ_ids"] as? [Any])?.compactMap(Self.asInt) ?? []
            let categoryName = categIds.first.flatMap { categoryNameById[$0] } ?? (category ?? "")
            let vatMultiplier = Self.taxMultiplier(forTaxIds: taxIdsByTemplate[id] ?? [], taxesById: taxesById)

            return Self.makeProduct(
                id: id, name: name, listPrice: listPrice,
                categId: categIdByTemplate[id], categoryName: categoryName,
                inStock: qty > 0,
                variants: variantsByTemplate[id] ?? [],
                attributeValues: attributeValues,
                ruleIndex: ruleIndex,
                vatMultiplier: vatMultiplier
            )
        }
    }

    // MARK: - Descriere produs (on-demand, NU la fetch-ul eager de catalog)

    /// Citeste `product.template.website_description` (HTML) pt un singur produs, on-demand
    /// (apelat din ecranul de detaliu, NU din `fetchProducts` — 538 de produse x parsing HTML
    /// ar incetini inutil catalogul, care oricum nu afiseaza descrierea in grid/lista).
    ///
    /// PROBLEMA descoperita empiric: `website_description` contine efectiv DOUA blocuri HTML
    /// complete suprapuse (unul RO, unul EN), fiecare invelit intr-un `<section
    /// data-visibility-value-lang='[{"code":"ro_RO",...}]'>...</section>` — separarea pe site
    /// se face DOAR prin CSS client-side, serverul trimite ambele. Filtram noi insine (vezi
    /// `filterRomanianSections`), pastram doar continutul RO (+ orice continut netaguit), apoi
    /// convertim la text simplu lizibil.
    func fetchProductDescription(productId: Int) async throws -> String? {
        guard let uid, let password else {
            return try await catalogFallback.fetchProductDescription(productId: productId)
        }

        let rows = try await read(
            model: "product.template", ids: [productId], fields: ["website_description"],
            uid: uid, password: password
        )

        // Odoo intoarce `false` (Bool), nu null/empty string, cand campul HTML e gol.
        guard let row = rows.first,
              let rawHTML = row["website_description"] as? String,
              !rawHTML.isEmpty else {
            return nil
        }

        let filteredHTML = Self.filterRomanianSections(from: rawHTML)
        guard let plainText = await Self.htmlToPlainText(filteredHTML) else { return nil }
        let cleaned = Self.cleanupPlainText(plainText)
        return cleaned.isEmpty ? nil : cleaned
    }

    /// Pastreaza doar blocurile `<section>` de top-level (fara nesting adanc) al caror atribut
    /// `data-visibility-value-lang` contine `"ro_RO"`. Elimina complet blocurile taguite cu alt
    /// cod de limba. Blocurile FARA acest atribut (continut netaguit/comun) se pastreaza.
    private static func filterRomanianSections(from html: String) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: "<section\\b([^>]*)>.*?</section\\s*>",
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else {
            return html
        }

        let nsHTML = html as NSString
        let fullRange = NSRange(location: 0, length: nsHTML.length)
        let matches = regex.matches(in: html, options: [], range: fullRange)

        var result = ""
        var lastEnd = 0
        for match in matches {
            let matchRange = match.range

            // Continut dintre blocuri (sau inainte de primul) — netaguit, se pastreaza mereu.
            if matchRange.location > lastEnd {
                let precedingRange = NSRange(location: lastEnd, length: matchRange.location - lastEnd)
                result += nsHTML.substring(with: precedingRange)
            }

            let attributesRange = match.range(at: 1)
            let attributes = attributesRange.location != NSNotFound ? nsHTML.substring(with: attributesRange) : ""

            if attributes.contains("data-visibility-value-lang") {
                if attributes.contains("ro_RO") {
                    result += nsHTML.substring(with: matchRange)
                }
                // else: bloc taguit cu alt cod de limba (ex. en_US) — eliminat complet.
            } else {
                // Sectiune fara tag de limba -> continut comun, se pastreaza.
                result += nsHTML.substring(with: matchRange)
            }

            lastEnd = matchRange.location + matchRange.length
        }
        if lastEnd < nsHTML.length {
            result += nsHTML.substring(with: NSRange(location: lastEnd, length: nsHTML.length - lastEnd))
        }
        return result
    }

    /// Converteste un fragment HTML la text simplu lizibil, cu paragrafe si diacritice corect
    /// decodate. `NSAttributedString(data:options:documentAttributes:)` cu `.documentType: .html`
    /// nu e documentat ca fiind sigur in afara main thread-ului pe toate platformele — rulat
    /// explicit pe `MainActor` ca sa evitam surprize.
    @MainActor
    private static func htmlToPlainText(_ html: String) -> String? {
        guard let data = html.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        return attributed.string
    }

    /// Trim whitespace la inceput/final si colapseaza randuri goale multiple consecutive la unul
    /// singur, pt lizibilitate (HTML->text simplu tinde sa lase multe linii goale succesive).
    private static func cleanupPlainText(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        var collapsed: [String] = []
        var previousWasBlank = false
        for line in lines {
            if line.isEmpty {
                if !previousWasBlank {
                    collapsed.append("")
                }
                previousWasBlank = true
            } else {
                collapsed.append(line)
                previousWasBlank = false
            }
        }
        while collapsed.first == "" { collapsed.removeFirst() }
        while collapsed.last == "" { collapsed.removeLast() }
        return collapsed.joined(separator: "\n")
    }

    // MARK: - Catalog: helpers de retea (batched, read-only)

    private func fetchCategoryRows(uid: Int, password: String) async throws -> [CategoryRow] {
        // `order: "sequence, name"` — aceeasi ordine ca pe site (drag&drop in Website > eCommerce
        // > Categorii). `Dictionary(grouping:)` din `buildCategoryTree` pastreaza ordinea de
        // insertie, deci sortarea aici se propaga corect la fiecare nivel al arborelui.
        let rows = try await searchRead(
            model: "product.public.category", domain: [["website_id", "=", Self.websiteId]],
            fields: ["id", "name", "parent_id", "product_tmpl_ids"],
            order: "sequence, name",
            uid: uid, password: password
        )
        return rows.compactMap { row in
            guard let id = Self.asInt(row["id"]), let name = row["name"] as? String else { return nil }
            let parentId = Self.asMany2OneId(row["parent_id"])
            let productTemplateIds = Set((row["product_tmpl_ids"] as? [Any])?.compactMap(Self.asInt) ?? [])
            return CategoryRow(id: id, name: name, parentId: parentId, productTemplateIds: productTemplateIds)
        }
    }

    private func fetchVariantRows(templateIds: [Int], uid: Int, password: String) async throws -> [VariantRow] {
        guard !templateIds.isEmpty else { return [] }
        let rows = try await searchRead(
            model: "product.product",
            domain: [["product_tmpl_id", "in", templateIds]],
            fields: [
                "id", "product_tmpl_id", "default_code", "lst_price",
                "qty_available", "product_template_attribute_value_ids"
            ],
            uid: uid, password: password
        )
        return rows.compactMap { row in
            guard let id = Self.asInt(row["id"]),
                  let templateId = Self.asMany2OneId(row["product_tmpl_id"]) else { return nil }
            let sku = (row["default_code"] as? String) ?? ""
            let price = Self.asDecimal(row["lst_price"]) ?? 0
            let qty = Self.asDouble(row["qty_available"]) ?? 0
            let attributeValueIds = (row["product_template_attribute_value_ids"] as? [Any])?.compactMap(Self.asInt) ?? []
            return VariantRow(
                id: id, templateId: templateId, sku: sku,
                priceRON: price, inStock: qty > 0, attributeValueIds: attributeValueIds
            )
        }
    }

    /// Un singur `read` batched pe toate `product.template.attribute.value` relevante —
    /// se citesc `attribute_id`/`product_attribute_value_id` (Many2one -> tuple [id, nume]),
    /// NU campul `.name` deja formatat "Label: Value" (parsing fragil de string, evitat intentionat).
    private func fetchAttributeValueRows(ids: [Int], uid: Int, password: String) async throws -> [Int: AttributeValueRow] {
        guard !ids.isEmpty else { return [:] }
        let rows = try await read(
            model: "product.template.attribute.value", ids: ids,
            fields: ["attribute_id", "product_attribute_value_id"],
            uid: uid, password: password
        )
        var map: [Int: AttributeValueRow] = [:]
        for row in rows {
            guard let id = Self.asInt(row["id"]) else { continue }
            let label = Self.many2OneLabel(row["attribute_id"]) ?? ""
            let value = Self.many2OneLabel(row["product_attribute_value_id"]) ?? ""
            map[id] = AttributeValueRow(label: label, value: value)
        }
        return map
    }

    /// Un singur `read` batched pe toate `account.tax` relevante pt pagina curenta de produse
    /// (id-urile colectate din `product.template.taxes_id`) — folosit pt calculul dinamic al
    /// TVA per produs (vezi `taxMultiplier`).
    private func fetchTaxRows(ids: [Int], uid: Int, password: String) async throws -> [Int: TaxRow] {
        guard !ids.isEmpty else { return [:] }
        let rows = try await read(
            model: "account.tax", ids: ids, fields: ["amount", "price_include"],
            uid: uid, password: password
        )
        var map: [Int: TaxRow] = [:]
        for row in rows {
            guard let id = Self.asInt(row["id"]), let amount = Self.asDecimal(row["amount"]) else { continue }
            let priceInclude = (row["price_include"] as? Bool) ?? false
            map[id] = TaxRow(amount: amount, priceInclude: priceInclude)
        }
        return map
    }

    /// Trage TOATE regulile de pricelist relevante pt pagina curenta de produse, intr-un
    /// singur query per scope (`1_product` / `2_product_category` / `3_global`) — fiecare
    /// query acopera ambele pricelist-uri (Public 45 + Ortho Club 59) printr-un filtru `in`,
    /// deci maxim 3 query-uri in total, indiferent de cate produse sunt in pagina curenta.
    /// Vezi `PricelistRuleIndex`/`effectivePrice` pt cum se folosesc rezultatele.
    private func fetchPricelistRuleIndex(
        templateIds: [Int], categIds: [Int], uid: Int, password: String
    ) async throws -> PricelistRuleIndex {
        guard !templateIds.isEmpty else { return PricelistRuleIndex() }

        let fields = [
            "pricelist_id", "product_tmpl_id", "categ_id", "applied_on",
            "min_quantity", "compute_price", "percent_price", "fixed_price"
        ]
        let pricelistIds: [Any] = [Self.publicPricelistId, Self.orthoClubPricelistId]

        async let productRowsTask = searchRead(
            model: "product.pricelist.item",
            domain: [
                ["applied_on", "=", "1_product"],
                ["product_tmpl_id", "in", templateIds],
                ["pricelist_id", "in", pricelistIds]
            ],
            fields: fields, uid: uid, password: password
        )
        async let categoryRowsTask = searchRead(
            model: "product.pricelist.item",
            domain: [
                ["applied_on", "=", "2_product_category"],
                ["categ_id", "in", categIds],
                ["pricelist_id", "in", pricelistIds]
            ],
            fields: fields, uid: uid, password: password
        )
        async let globalRowsTask = searchRead(
            model: "product.pricelist.item",
            domain: [
                ["applied_on", "=", "3_global"],
                ["pricelist_id", "in", pricelistIds]
            ],
            fields: fields, uid: uid, password: password
        )

        let productRows = try await productRowsTask
        let categoryRows = try await categoryRowsTask
        let globalRows = try await globalRowsTask

        var index = PricelistRuleIndex()
        for row in productRows {
            guard let rule = Self.makePricelistRuleRow(from: row), let templateId = rule.productTemplateId else { continue }
            index.productRules[rule.pricelistId, default: [:]][templateId, default: []].append(rule)
        }
        for row in categoryRows {
            guard let rule = Self.makePricelistRuleRow(from: row), let categId = rule.categId else { continue }
            index.categoryRules[rule.pricelistId, default: [:]][categId, default: []].append(rule)
        }
        for row in globalRows {
            guard let rule = Self.makePricelistRuleRow(from: row) else { continue }
            index.globalRules[rule.pricelistId, default: []].append(rule)
        }
        return index
    }

    private static func makePricelistRuleRow(from row: [String: Any]) -> PricelistRuleRow? {
        guard let pricelistId = asMany2OneId(row["pricelist_id"]),
              let appliedOn = row["applied_on"] as? String,
              let minQuantity = asDouble(row["min_quantity"]) else { return nil }
        return PricelistRuleRow(
            pricelistId: pricelistId,
            appliedOn: appliedOn,
            productTemplateId: asMany2OneId(row["product_tmpl_id"]),
            categId: asMany2OneId(row["categ_id"]),
            minQuantity: minQuantity,
            computePrice: row["compute_price"] as? String ?? "",
            percentPrice: asDecimal(row["percent_price"]) ?? 0,
            fixedPrice: asDecimal(row["fixed_price"]) ?? 0
        )
    }

    /// Wrapper generic peste `execute_kw` / `search_read`, batched (fields + limit optional).
    ///
    /// Include intotdeauna contextul de limba (`roContext`) — foloseste acest helper pentru
    /// TOATE citirile de text tradus (categorii, produse, variante, pricelist).
    private func searchRead(
        model: String, domain: [Any], fields: [String], order: String? = nil, limit: Int? = nil,
        uid: Int, password: String
    ) async throws -> [[String: Any]] {
        var kwargs: [String: Any] = ["fields": fields, "context": Self.roContext]
        if let order { kwargs["order"] = order }
        if let limit { kwargs["limit"] = limit }
        let result = try await rpc.call(
            service: "object", method: "execute_kw",
            args: [OdooConfig.database, uid, password, model, "search_read", [domain], kwargs]
        )
        guard let rows = result as? [[String: Any]] else { throw OdooRPCError.invalidResponse }
        return rows
    }

    /// Wrapper generic peste `execute_kw` / `read` (cand id-urile sunt deja cunoscute).
    ///
    /// Include intotdeauna contextul de limba (`roContext`) — vezi `searchRead`.
    private func read(
        model: String, ids: [Int], fields: [String], uid: Int, password: String
    ) async throws -> [[String: Any]] {
        guard !ids.isEmpty else { return [] }
        let result = try await rpc.call(
            service: "object", method: "execute_kw",
            args: [OdooConfig.database, uid, password, model, "read", [ids, fields], ["context": Self.roContext]]
        )
        guard let rows = result as? [[String: Any]] else { throw OdooRPCError.invalidResponse }
        return rows
    }

    // MARK: - Catalog: asamblare in memorie

    /// Colecteaza id-urile categoriilor de start SI toate subcategoriile lor recursive
    /// (copii, nepoti etc.) — vezi comentariul din `fetchProducts` pt de ce e necesar.
    private static func collectDescendantIds(startingFrom startIds: [Int], in rows: [CategoryRow]) -> [Int] {
        let childrenByParent = Dictionary(grouping: rows, by: { $0.parentId })
        var result = Set(startIds)
        var queue = startIds
        while let current = queue.popLast() {
            for child in childrenByParent[current] ?? [] {
                if result.insert(child.id).inserted {
                    queue.append(child.id)
                }
            }
        }
        return Array(result)
    }

    private static func buildCategoryTree(from rows: [CategoryRow]) -> [ProductCategory] {
        let byParent = Dictionary(grouping: rows, by: { $0.parentId })
        // `productCount` afisat trebuie sa reflecte TOTALUL din categorie + subcategorii (ca pe
        // site), nu doar produsele taguite direct — de-aia `build` propaga si multimea de
        // id-uri de produse (uniune, nu suma, ca un produs taguit pe mai multe subcategorii sa
        // nu fie numarat de mai multe ori).
        func build(_ row: CategoryRow) -> (category: ProductCategory, productIds: Set<Int>) {
            let children = (byParent[row.id] ?? []).map(build)
            let allProductIds = children.reduce(into: row.productTemplateIds) { $0.formUnion($1.productIds) }
            let category = ProductCategory(
                id: row.id, name: row.name, productCount: allProductIds.count,
                subcategories: children.map(\.category)
            )
            return (category, allProductIds)
        }
        return (byParent[nil] ?? []).map { build($0).category }
    }

    private static func makeProduct(
        id: Int, name: String, listPrice: Decimal, categId: Int?,
        categoryName: String, inStock: Bool,
        variants: [VariantRow], attributeValues: [Int: AttributeValueRow],
        ruleIndex: PricelistRuleIndex, vatMultiplier: Decimal
    ) -> Product {
        let priceRONNoVAT = effectivePrice(
            qty: 1, pricelistId: publicPricelistId, productTemplateId: id, categId: categId,
            listPrice: listPrice, ruleIndex: ruleIndex
        ) ?? listPrice
        let priceRON = applyVAT(priceRONNoVAT, multiplier: vatMultiplier)

        let orthoClubPriceRON = effectivePrice(
            qty: 1, pricelistId: orthoClubPricelistId, productTemplateId: id, categId: categId,
            listPrice: listPrice, ruleIndex: ruleIndex
        ).map { applyVAT($0, multiplier: vatMultiplier) }

        let tiers = priceTiers(
            productTemplateId: id, categId: categId, listPrice: listPrice,
            pricelistId: publicPricelistId, ruleIndex: ruleIndex, vatMultiplier: vatMultiplier
        )

        // "Pretul taiat" afisat pe site NU vine din campul `compare_list_price` — verificat
        // empiric (comparare directa cu HTML-ul randat live): pt un produs ("DURAN 100buc",
        // tmpl 21532), site-ul arata 1.063,09 lei taiat, exact `list_price * 1.21`, in timp ce
        // `compare_list_price` din Odoo era 2025.0 (eroare de date/camp nefolosit de acest theme
        // pt afisare). Site-ul foloseste efectiv `list_price` (cu TVA), nu campul de comparare.
        // Afisam pretul taiat DOAR cand reprezinta o reducere reala (mai mare ca pretul curent) —
        // altfel site-ul nu arata nicio linie taiata (pret unic, fara "reducere" vizuala).
        let listPriceWithVAT = applyVAT(listPrice, multiplier: vatMultiplier)
        let originalPriceRON: Decimal? = listPriceWithVAT > priceRON ? listPriceWithVAT : nil

        let imageURL = URL(string: "https://www.uportho.ro/web/image/product.template/\(id)/image_512")

        // BUG reparat: pretul de varianta NU trebuie sa fie `lst_price`-ul brut al variantei
        // (fara reducere, fara TVA) — asta arata un pret complet diferit (si mai mare) decat
        // pretul corect afisat pe cardul din lista. Aplicam ACEEASI regula de pricelist +
        // TVA ca la produs, dar pornind de la `lst_price`-ul propriu al variantei (nu de la
        // `list_price`-ul template-ului) — asta tine cont corect de eventuale suprataxe pe
        // combinatie de atribute (`price_extra`), deja incluse in `lst_price` de Odoo.
        let productVariants = variants.map { variant -> ProductVariant in
            let attributes = variant.attributeValueIds
                .compactMap { attributeValues[$0] }
                .map { VariantAttribute(label: $0.label, value: $0.value) }
            let variantPriceNoVAT = effectivePrice(
                qty: 1, pricelistId: publicPricelistId, productTemplateId: id, categId: categId,
                listPrice: variant.priceRON, ruleIndex: ruleIndex
            ) ?? variant.priceRON
            let variantPrice = applyVAT(variantPriceNoVAT, multiplier: vatMultiplier)
            // Tabelul de comanda pe variante (ca pe site) are nevoie de tiers PROPRII per
            // varianta, nu doar de un singur pret — recalculate identic cu tiers-ul produsului,
            // dar pornind de la pretul brut al VARIANTEI (`variant.priceRON`), ca sa reflecte
            // corect eventualele suprataxe de combinatie (`price_extra`).
            let variantTiers = priceTiers(
                productTemplateId: id, categId: categId, listPrice: variant.priceRON,
                pricelistId: publicPricelistId, ruleIndex: ruleIndex, vatMultiplier: vatMultiplier
            )
            return ProductVariant(
                id: variant.id, sku: variant.sku, attributes: attributes,
                priceRON: variantPrice, inStock: variant.inStock, priceTiers: variantTiers
            )
        }

        return Product(
            id: id, name: name, category: categoryName, imageURL: imageURL,
            originalPriceRON: originalPriceRON, priceRON: priceRON, orthoClubPriceRON: orthoClubPriceRON,
            priceTiers: tiers, rating: nil, inStock: inStock, variants: productVariants,
            // Id-ul variantei implicite (`product.product`) — mereu exista cel putin o varianta
            // auto per template in Odoo, chiar si fara atribute. Il folosim la coș cand produsul
            // nu are variante selectabile (vezi `CartItem.productProductId`).
            defaultVariantId: variants.first?.id
        )
    }

    /// Aplica un multiplicator de TVA unui pret FARA TVA calculat din pricelist, si rotunjeste
    /// la 2 zecimale cu rotunjire standard (nu trunchiere).
    private static func applyVAT(_ priceWithoutVAT: Decimal, multiplier: Decimal) -> Decimal {
        let withVAT = priceWithoutVAT * multiplier
        var rounded = Decimal()
        var mutableValue = withVAT
        NSDecimalRound(&rounded, &mutableValue, 2, .plain)
        return rounded
    }

    /// Calculeaza multiplicatorul de TVA (ex. 1.21 pt 21%) al unui produs, DINAMIC, din taxele
    /// lui reale (`taxes_id` -> `account.tax`), citite doar-citire dupa ce contul de test a
    /// primit drept de citire pe contabilitate. Doar taxele cu `price_include=false` se aduna
    /// la pret (cele cu `price_include=true` sunt deja incluse in `list_price`, nu se aplica
    /// din nou). Daca produsul nu are nicio taxa asociata SAU taxa nu a putut fi citita (id
    /// lipsa din `taxesById`, ex. citirea batched a esuat), cade pe `fallbackVatMultiplier`.
    private static func taxMultiplier(forTaxIds taxIds: [Int], taxesById: [Int: TaxRow]) -> Decimal {
        guard !taxIds.isEmpty else { return fallbackVatMultiplier }
        // Daca NICIUNA din taxele produsului nu a putut fi gasita in `taxesById` (citirea
        // batched a esuat sau id-uri lipsa), nu avem cum sa stim cota reala -> fallback. Daca
        // GASIM taxele dar toate au `price_include=true`, multiplicatorul corect e 1 (deja
        // incluse in `list_price`), NU fallback-ul (care ar adauga TVA a doua oara, gresit).
        guard taxIds.contains(where: { taxesById[$0] != nil }) else { return fallbackVatMultiplier }
        var multiplier: Decimal = 1
        for taxId in taxIds {
            guard let tax = taxesById[taxId], !tax.priceInclude else { continue }
            multiplier *= (1 + tax.amount / 100)
        }
        return multiplier
    }

    /// Algoritmul de pret confirmat empiric (vezi task Odoo): dintre toate regulile
    /// `product.pricelist.item` aplicabile unui produs (scope produs + categoria lui
    /// contabila + global, combinate) pt un pricelist si o cantitate date, alege regula cu
    /// `min_quantity <= qty` cea mai SPECIFICA (`1_product` > `2_product_category` >
    /// `3_global`), si la egalitate de specificitate pe cea cu `min_quantity` cea mai mare
    /// (cea mai apropiata de `qty` fara sa-l depaseasca). Intoarce pretul FARA TVA rezultat
    /// din formula regulii alese, sau `nil` daca nu exista NICIO regula aplicabila (nici
    /// macar globala) — apelantul decide fallback-ul (`list_price` brut pt pricelist-ul
    /// Public, `nil`/fara discount pt Ortho Club).
    private static func effectivePrice(
        qty: Double, pricelistId: Int, productTemplateId: Int, categId: Int?,
        listPrice: Decimal, ruleIndex: PricelistRuleIndex
    ) -> Decimal? {
        let candidates = ruleIndex
            .applicableRules(pricelistId: pricelistId, productTemplateId: productTemplateId, categId: categId)
            .filter { $0.minQuantity <= qty }
        guard !candidates.isEmpty else { return nil }

        func specificityRank(_ appliedOn: String) -> Int {
            switch appliedOn {
            case "1_product": return 0
            case "2_product_category": return 1
            default: return 2 // "3_global"
            }
        }

        var best = candidates[0]
        for candidate in candidates.dropFirst() {
            let candidateRank = specificityRank(candidate.appliedOn)
            let bestRank = specificityRank(best.appliedOn)
            if candidateRank < bestRank
                || (candidateRank == bestRank && candidate.minQuantity > best.minQuantity) {
                best = candidate
            }
        }

        switch best.computePrice {
        case "percentage":
            return listPrice * (1 - best.percentPrice / 100)
        case "fixed":
            return best.fixedPrice
        default:
            // Caz neasteptat, defensiv: nu am intalnit alta valoare decat
            // "percentage"/"fixed" in explorarea read-only, dar nu crapam daca apare.
            print("RealOdooClient: compute_price neasteptat '\(best.computePrice)' pt product.template \(productTemplateId) in pricelist \(pricelistId), fallback la list_price")
            return listPrice
        }
    }

    /// Construieste `priceTiers` pt un singur produs: aduna toate valorile DISTINCTE de
    /// `min_quantity` din regulile aplicabile produsului (toate cele 3 scope-uri combinate),
    /// calculeaza pretul efectiv (CU TVA) la fiecare prag prin `effectivePrice`, si elimina
    /// pragurile consecutive al caror pret calculat e identic cu cel anterior — reproduce
    /// exact comportamentul site-ului (ex. un produs cu praguri Odoo la min_quantity 0, 1, 4
    /// arata pe site doar 2 randuri, "1+ Buc." si "4+ Buc.", pt ca 0 si 1 dau acelasi pret).
    private static func priceTiers(
        productTemplateId: Int, categId: Int?, listPrice: Decimal,
        pricelistId: Int, ruleIndex: PricelistRuleIndex, vatMultiplier: Decimal
    ) -> [PriceTier] {
        let rawMinQuantities = ruleIndex
            .applicableRules(pricelistId: pricelistId, productTemplateId: productTemplateId, categId: categId)
            .map { $0.minQuantity }

        // "aplicabil de la cantitatea 0 in sus" in Odoo == practic pretul valabil si la
        // cantitatea 1 (nu poti cumpara 0 bucati) — normalizam ORICE prag <= 1 la cantitatea
        // afisata "1+" INAINTE de a calcula pretul (nu dupa). Confirmat empiric pe produsul de
        // test (tmpl 17210): un prag brut 0 vine DOAR dintr-o regula globala fara reducere
        // (0%), iar un prag brut 1 vine dintr-o regula de categorie CU reducere — daca am
        // calcula pretul separat la qty=0 vs qty=1 am obtine doua randuri diferite ambele
        // afisate "1+" (gresit). Calculand la aceeasi cantitate normalizata (1), regula cea
        // mai specifica aplicabila la acea cantitate e aleasa o singura data, corect.
        let displayQuantities = Set(rawMinQuantities.map { max(Int($0.rounded()), 1) }).sorted()

        var tiers: [PriceTier] = []
        for displayQuantity in displayQuantities {
            let priceNoVAT = effectivePrice(
                qty: Double(displayQuantity), pricelistId: pricelistId, productTemplateId: productTemplateId,
                categId: categId, listPrice: listPrice, ruleIndex: ruleIndex
            ) ?? listPrice
            let price = applyVAT(priceNoVAT, multiplier: vatMultiplier)

            if let last = tiers.last, last.priceRON == price {
                continue
            }
            tiers.append(PriceTier(minQuantity: displayQuantity, priceRON: price))
        }
        return tiers
    }

    // MARK: - Helpers

    private func currentPartnerId(uid: Int, password: String) async throws -> Int {
        let usersResult = try await rpc.call(
            service: "object",
            method: "execute_kw",
            args: [
                OdooConfig.database, uid, password,
                "res.users", "read",
                [[uid], ["partner_id"]]
            ]
        )

        guard let users = usersResult as? [[String: Any]],
              let user = users.first,
              let partnerRef = user["partner_id"] as? [Any],
              let partnerId = Self.asInt(partnerRef.first) else {
            throw OdooRPCError.invalidResponse
        }
        return partnerId
    }

    private static let odooDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    private static func makeInvoice(from move: [String: Any]) -> Invoice? {
        guard let id = asInt(move["id"]), let number = move["name"] as? String else {
            return nil
        }

        let invoiceDate = (move["invoice_date"] as? String).flatMap(odooDateFormatter.date(from:)) ?? Date()
        let dueDate = (move["invoice_date_due"] as? String).flatMap(odooDateFormatter.date(from:)) ?? invoiceDate

        let amountResidual = (move["amount_residual"] as? Double)
            ?? (move["amount_residual"] as? NSNumber)?.doubleValue
            ?? 0

        let paymentState = move["payment_state"] as? String ?? ""
        let status: InvoiceStatus = paymentState == "paid" ? .paid : .awaitingPayment

        return Invoice(
            id: id,
            number: number,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
            amountDueRON: Decimal(amountResidual),
            status: status
        )
    }

    /// Odoo/JSONSerialization intoarce numerele ca `NSNumber` sau `Int` in functie de context —
    /// helper unic de conversie sigura la `Int`.
    private static func asInt(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        return nil
    }

    private static func asDouble(_ value: Any?) -> Double? {
        if let doubleValue = value as? Double {
            return doubleValue
        }
        if let intValue = value as? Int {
            return Double(intValue)
        }
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        return nil
    }

    private static func asDecimal(_ value: Any?) -> Decimal? {
        guard let doubleValue = asDouble(value) else { return nil }
        return Decimal(doubleValue)
    }

    /// Campurile Many2one vin din Odoo ca tuplu `[id, "nume"]`, sau `false` cand sunt goale
    /// (ex. `parent_id` la o categorie radacina) — cast-ul la `[Any]` esueaza natural pt `false`.
    private static func asMany2OneId(_ value: Any?) -> Int? {
        guard let tuple = value as? [Any], let first = tuple.first else { return nil }
        return asInt(first)
    }

    private static func many2OneLabel(_ value: Any?) -> String? {
        guard let tuple = value as? [Any], tuple.count > 1 else { return nil }
        return tuple[1] as? String
    }
}

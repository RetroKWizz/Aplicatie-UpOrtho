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

    // MARK: - Banner (sliderul real de pe homepage, snippet `s_banner_12`)

    /// `website_id` al site-ului "uportho.ro 2025" — instanta Odoo gazduieste MAI MULTE site-uri
    /// (tunealigners.ro, ortho-shop.ro etc.) care au TOATE cate un `ir.ui.view` cu acelasi
    /// `key = "website.homepage"` — fara acest filtru am putea citi din greseala homepage-ul
    /// altui site. Confirmat manual, read-only.
    private static let homepageWebsiteId = 11

    /// Prefixul linkurilor de categorie folosite de sloturile sliderului
    /// (`/shop/category/<slug>-<id>`) — folosit ca sa distingem CTA-ul relevant de alte
    /// linkuri intamplatoare din acelasi slot.
    private static let shopCategoryLinkPrefix = "/shop/category/"

    /// Gradient/icon de rezerva pt cazul (neasteptat) in care un slot nu are imagine valida —
    /// rotite ciclic intre sloturi, ca sa nu arate toate identic.
    private static let bannerFallbackStyles: [(symbolName: String, gradientColors: [Color])] = [
        ("newspaper.fill", [Color(red: 0.42, green: 0.25, blue: 0.63), Color(red: 0.60, green: 0.41, blue: 0.80)]),
        ("doc.text.fill", [Color(red: 0.20, green: 0.45, blue: 0.55), Color(red: 0.30, green: 0.65, blue: 0.70)]),
        ("text.book.closed.fill", [Color(red: 0.85, green: 0.35, blue: 0.30), Color(red: 0.95, green: 0.55, blue: 0.25)])
    ]

    /// Bannerele de pe Acasa clonează acum sliderul REAL de pe homepage-ul uportho.ro (snippet
    /// `s_banner_12` din `website.homepage`), NU postari de blog — vezi investigatia care a
    /// precedat acest task. Fara sesiune autentificata, sau daca parsarea esueaza complet
    /// (structura paginii s-a schimbat radical), cadem pe `MockOdooClient` (la fel ca la catalog).
    func fetchBanners() async throws -> [Banner] {
        guard let uid, let password else {
            return try await catalogFallback.fetchBanners()
        }
        if let banners = try? await fetchHomepageSliderBanners(uid: uid, password: password), !banners.isEmpty {
            return banners
        }
        return try await catalogFallback.fetchBanners()
    }

    /// Gaseste dinamic view-ul homepage-ului site-ului uportho.ro (NU hardcodat dupa id — vezi
    /// comentariul de la `homepageWebsiteId`), citeste `arch_db` (HTML-ul complet al paginii) si
    /// parseaza sectiunea `s_banner_12`.
    private func fetchHomepageSliderBanners(uid: Int, password: String) async throws -> [Banner]? {
        let viewRows = try await searchRead(
            model: "ir.ui.view",
            domain: [["key", "=", "website.homepage"], ["website_id", "=", Self.homepageWebsiteId]],
            fields: ["id"],
            limit: 1, uid: uid, password: password
        )
        guard let viewId = viewRows.first.flatMap({ Self.asInt($0["id"]) }) else { return nil }

        let archRows = try await read(
            model: "ir.ui.view", ids: [viewId], fields: ["arch_db"], uid: uid, password: password
        )
        guard let arch = archRows.first?["arch_db"] as? String, !arch.isEmpty else { return nil }

        return Self.parseSliderBanners(fromHomepageArch: arch)
    }

    /// Parseaza sectiunea `<section data-snippet="s_banner_12">...</section>` si extrage
    /// fiecare slot (`o_grid_item`) din interior — vezi comentariile helperelor de mai jos pt
    /// detalii. Regex-parsing simplu, NU un parser HTML complet generic (acelasi stil ca
    /// `filterRomanianSections` mai sus).
    private static func parseSliderBanners(fromHomepageArch arch: String) -> [Banner]? {
        guard let sectionContent = extractBannerSectionContent(fromArch: arch) else { return nil }
        let slots = splitGridItems(fromSectionContent: sectionContent)
        guard !slots.isEmpty else { return nil }

        let banners = slots.enumerated().compactMap { index, slotHTML in
            makeSliderBanner(fromSlotHTML: slotHTML, fallbackStyleIndex: index)
        }
        return banners.isEmpty ? nil : banners
    }

    /// Izoleaza continutul dintre `<section ... data-snippet="s_banner_12" ...>` si
    /// urmatorul `</section>` — presupune (confirmat empiric) ca sectiunea nu are alte
    /// `<section>` imbricate in interior, deci un lazy-match e suficient (la fel ca la
    /// descrierea de produs, NU se justifica un parser HTML complet).
    private static func extractBannerSectionContent(fromArch arch: String) -> String? {
        guard let openRegex = try? NSRegularExpression(
            pattern: "<section\\b(?=[^>]*data-snippet=\"s_banner_12\")[^>]*>",
            options: [.caseInsensitive]
        ) else { return nil }

        let nsArch = arch as NSString
        let fullRange = NSRange(location: 0, length: nsArch.length)
        guard let openMatch = openRegex.firstMatch(in: arch, range: fullRange) else { return nil }

        let contentStart = openMatch.range.location + openMatch.range.length
        let searchRange = NSRange(location: contentStart, length: nsArch.length - contentStart)
        let closeRange = nsArch.range(of: "</section>", options: [], range: searchRange)
        guard closeRange.location != NSNotFound else { return nil }

        return nsArch.substring(with: NSRange(location: contentStart, length: closeRange.location - contentStart))
    }

    /// Imparte continutul sectiunii in N sloturi, dupa fiecare `<div class="... o_grid_item
    /// ...">` gasit — NU presupune un numar fix de sloturi (Dan poate adauga/scoate sloturi din
    /// Website Builder). Fiecare slot e continutul de la inceputul div-ului sau pana la
    /// inceputul urmatorului (sau finalul sectiunii pt ultimul).
    private static func splitGridItems(fromSectionContent content: String) -> [String] {
        guard let regex = try? NSRegularExpression(
            pattern: "<div\\b[^>]*class=\"[^\"]*\\bo_grid_item\\b[^\"]*\"[^>]*>",
            options: [.caseInsensitive]
        ) else { return [] }

        let nsContent = content as NSString
        let matches = regex.matches(in: content, range: NSRange(location: 0, length: nsContent.length))
        guard !matches.isEmpty else { return [] }

        return matches.enumerated().map { index, match in
            let start = match.range.location
            let end = index + 1 < matches.count ? matches[index + 1].range.location : nsContent.length
            return nsContent.substring(with: NSRange(location: start, length: end - start))
        }
    }

    /// Extrage un `Banner` dintr-un singur slot HTML: imagine (`img src`), badge de discount
    /// (`h5`, poate contine markup `<font>` in interior), titlu (concatenarea tuturor `h3`-urilor
    /// din slot), si CTA + id de categorie (din primul `<a href="/shop/category/...">`).
    private static func makeSliderBanner(fromSlotHTML html: String, fallbackStyleIndex: Int) -> Banner? {
        guard let rawImageSrc = firstCapturedGroup(pattern: "<img\\b[^>]*\\bsrc=\"([^\"]+)\"", in: html),
              let imageURL = URL(string: rawImageSrc, relativeTo: OdooConfig.baseURL)?.absoluteURL else {
            return nil
        }

        let badgeRaw = firstCapturedGroup(
            pattern: "<h5\\b[^>]*>(.*?)</h5>", in: html, options: [.dotMatchesLineSeparators, .caseInsensitive]
        )
        let badge = badgeRaw.map(stripHTMLTags) ?? ""

        let titleParts = allCapturedGroups(
            pattern: "<h3\\b[^>]*>(.*?)</h3>", in: html, options: [.dotMatchesLineSeparators, .caseInsensitive]
        ).map(stripHTMLTags).filter { !$0.isEmpty }
        let title = titleParts.joined(separator: " ")
        guard !title.isEmpty else { return nil }

        var ctaText = "Vezi produse"
        var categoryId: Int?
        if let anchor = firstShopCategoryAnchor(in: html) {
            let anchorText = stripHTMLTags(anchor.text)
            if !anchorText.isEmpty { ctaText = anchorText }
            categoryId = extractTrailingId(fromPath: anchor.href)
        }

        let style = bannerFallbackStyles[fallbackStyleIndex % bannerFallbackStyles.count]
        // Id stabil, nu conteaza pt navigare (doar `categoryId` conteaza) — folosit doar ca
        // `Identifiable` pt `ForEach`/`TabView` selection.
        let id = categoryId ?? fallbackStyleIndex

        return Banner(
            id: id, title: title, subtitle: badge, ctaText: ctaText,
            symbolName: style.symbolName, gradientColors: style.gradientColors,
            imageURL: imageURL, categoryId: categoryId
        )
    }

    /// Primul `<a href="...">...</a>` din slot al carui href contine `/shop/category/` — sloturile
    /// pot avea si alte linkuri (ex. imaginea insasi ar putea fi invelita intr-un `<a>`), dar CTA-ul
    /// de categorie e cel relevant pt navigare.
    private static func firstShopCategoryAnchor(in html: String) -> (href: String, text: String)? {
        guard let regex = try? NSRegularExpression(
            pattern: "<a\\b[^>]*\\bhref=\"([^\"]+)\"[^>]*>(.*?)</a>",
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else { return nil }

        let nsHTML = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsHTML.length))
        for match in matches where match.numberOfRanges > 2 {
            let href = nsHTML.substring(with: match.range(at: 1))
            guard href.contains(shopCategoryLinkPrefix) else { continue }
            let text = nsHTML.substring(with: match.range(at: 2))
            return (href, text)
        }
        return nil
    }

    /// Extrage id-ul numeric de la finalul unui path gen `/shop/category/mini-implanturi-596`
    /// (`product.public.category.id` real din Odoo).
    private static func extractTrailingId(fromPath path: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: "-(\\d+)/?$") else { return nil }
        let nsPath = path as NSString
        guard let match = regex.firstMatch(in: path, range: NSRange(location: 0, length: nsPath.length)),
              match.numberOfRanges > 1 else { return nil }
        return Int(nsPath.substring(with: match.range(at: 1)))
    }

    /// Prima grupa capturata a unui regex intr-un text, sau `nil` daca nu se potriveste.
    private static func firstCapturedGroup(
        pattern: String, in text: String, options: NSRegularExpression.Options = []
    ) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let nsText = text as NSString
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)),
              match.numberOfRanges > 1 else { return nil }
        return nsText.substring(with: match.range(at: 1))
    }

    /// Toate grupele capturate (una per match) ale unui regex intr-un text.
    private static func allCapturedGroups(
        pattern: String, in text: String, options: NSRegularExpression.Options = []
    ) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return [] }
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        return matches.compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            return nsText.substring(with: match.range(at: 1))
        }
    }

    /// Elimina tag-urile HTML dintr-un fragment scurt (ex. continutul unui `<h5>`/`<h3>`/`<a>`) si
    /// decodeaza entitatile HTML comune intalnite pe site (`&nbsp;` etc.) — parsing simplu, NU un
    /// decoder HTML complet (suficient pt fragmente scurte de titlu/badge/CTA).
    private static func stripHTMLTags(_ html: String) -> String {
        let withoutTags = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // "&amp;" TREBUIE decodat PRIMUL — sursa de pe site contine des entitati dublu-codate
        // (ex. literal "&amp;nbsp;" in arch_db), asa ca decodand intai "&amp;"->"&" obtinem
        // "&nbsp;" abia apoi, gata sa fie decodat corect la pasul urmator. Ordinea inversa
        // lasa "&nbsp;" netradus, vizibil ca text brut in UI (bug confirmat vizual).
        let decoded = withoutTags
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
        let collapsedWhitespace = decoded.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return collapsedWhitespace.trimmingCharacters(in: .whitespacesAndNewlines)
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

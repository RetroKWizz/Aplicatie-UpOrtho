import SwiftUI

struct Banner: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let ctaText: String
    let symbolName: String
    let gradientColors: [Color]
    /// Imagine reala de coperta, cand exista. `nil` pt bannerele mock/fallback, care se
    /// afiseaza doar cu gradient + icon SF Symbol.
    let imageURL: URL?
    /// Bytes bruti ai imaginii, cititi direct prin XML-RPC (`x_app_banner.x_studio_image`) —
    /// ruta publica `/web/image/...` NU functioneaza pt modele custom Odoo Studio (drepturi de
    /// acces separate de cele XML-RPC, verificat live: raspunde mereu cu placeholder-ul generic
    /// Odoo, indiferent de id). Cand exista, are prioritate fata de `imageURL`.
    let imageData: Data?
    /// Id-ul REAL (`product.public.category.id`) al categoriei Odoo catre care trimite bannerul,
    /// extras din linkul `/shop/category/<slug>-<id>` al sliderului de pe homepage. `nil` cand
    /// bannerul nu are link de categorie recunoscut — in acel caz vezi `linkURL`.
    let categoryId: Int?
    /// Link-ul BRUT (orice `<a href>` gasit in sectiunea bannerului pe homepage), rezolvat absolut
    /// — ex. un short-link Odoo `/r/xxx` folosit pt bannere de marketing care nu trimit catre o
    /// categorie de produse. Cand `categoryId` e `nil` dar `linkURL` exista, bannerul se deschide
    /// intr-un browser in-app catre acest link — vezi `linkURL` ramane "live": daca linkul e
    /// schimbat in Odoo Website Builder, la urmatoarea incarcare a homepage-ului bannerul trimite
    /// automat catre noua destinatie, fara nicio schimbare de cod.
    let linkURL: URL?
    /// `true` pt bannerul hero de sus de pe homepage (sectiune "singura", fara sloturi multiple —
    /// ex. `s_text_block`/`s_picture` Ixion), `false` pt bannerele din grila de promo de mai jos
    /// (sectiuni cu sloturi `o_grid_item`, ex. `s_banner_12`) — HomeView le afiseaza in doua zone
    /// separate, la fel ca pe site (hero singur sus, apoi grila de categorii/branduri, apoi grila
    /// de promo cu 2 carduri), NU toate amestecate intr-un singur carusel.
    let isHero: Bool

    init(
        id: Int, title: String, subtitle: String, ctaText: String,
        symbolName: String, gradientColors: [Color], imageURL: URL? = nil, imageData: Data? = nil,
        categoryId: Int? = nil, linkURL: URL? = nil, isHero: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.symbolName = symbolName
        self.gradientColors = gradientColors
        self.imageURL = imageURL
        self.imageData = imageData
        self.categoryId = categoryId
        self.linkURL = linkURL
        self.isHero = isHero
    }
}

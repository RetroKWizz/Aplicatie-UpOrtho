import SwiftUI

struct Banner: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let ctaText: String
    let symbolName: String
    let gradientColors: [Color]
    /// Imagine reala de coperta (ex. slot din sliderul homepage `s_banner_12`), cand exista.
    /// `nil` pt bannerele mock/fallback, care se afiseaza doar cu gradient + icon SF Symbol.
    let imageURL: URL?
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

    init(
        id: Int, title: String, subtitle: String, ctaText: String,
        symbolName: String, gradientColors: [Color], imageURL: URL? = nil, categoryId: Int? = nil,
        linkURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.symbolName = symbolName
        self.gradientColors = gradientColors
        self.imageURL = imageURL
        self.categoryId = categoryId
        self.linkURL = linkURL
    }
}

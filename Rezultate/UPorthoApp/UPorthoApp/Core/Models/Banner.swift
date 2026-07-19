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
    /// bannerul nu are link de categorie (ex. mock/fallback) — in acel caz bannerul nu e apasabil.
    let categoryId: Int?

    init(
        id: Int, title: String, subtitle: String, ctaText: String,
        symbolName: String, gradientColors: [Color], imageURL: URL? = nil, categoryId: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.symbolName = symbolName
        self.gradientColors = gradientColors
        self.imageURL = imageURL
        self.categoryId = categoryId
    }
}

import Foundation

struct VariantAttribute: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let value: String
}

struct ProductVariant: Identifiable, Hashable {
    let id: Int
    let sku: String
    let attributes: [VariantAttribute]
    let priceRON: Decimal
    let inStock: Bool
    /// Preturi pe praguri de cantitate, specifice acestei variante (ex. 1+/3+/10+/20+ Buc.) —
    /// la fel ca `Product.priceTiers`, dar calculate pe pretul propriu al variantei, nu al
    /// produsului. Foloseste-le ca sa determini pretul/unitate corect pt orice cantitate aleasa
    /// intr-un tabel de comanda pe variante (gaseste tier-ul cu minQuantity cel mai mare <= qty).
    let priceTiers: [PriceTier]

    var summary: String {
        attributes.map(\.value).joined(separator: " / ")
    }

    /// Pretul/unitate aplicabil pt o cantitate data, dupa acelasi tier ca pe site (cel mai mare
    /// prag <= qty; daca niciun tier nu se potriveste, pretul de baza `priceRON`).
    func unitPrice(forQuantity quantity: Int) -> Decimal {
        let applicable = priceTiers.filter { $0.minQuantity <= quantity }
        return applicable.max(by: { $0.minQuantity < $1.minQuantity })?.priceRON ?? priceRON
    }
}

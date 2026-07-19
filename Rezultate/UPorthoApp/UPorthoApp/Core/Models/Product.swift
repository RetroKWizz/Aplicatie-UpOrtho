import Foundation

struct PriceTier: Identifiable, Hashable {
    var id: Int { minQuantity }
    let minQuantity: Int
    let priceRON: Decimal
}

struct Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let category: String
    let imageURL: URL?
    let originalPriceRON: Decimal?
    let priceRON: Decimal
    let orthoClubPriceRON: Decimal?
    let priceTiers: [PriceTier]
    let rating: Double?
    let inStock: Bool
    let variants: [ProductVariant]
    /// Id-ul variantei implicite (`product.product`, adica `product.template.product_variant_id`)
    /// pt produsele FARA variante selectabile de utilizator. `Product.id` e id de
    /// `product.template`, dar coșul Odoo cere id de `product.product` — asta il ofera pt
    /// produsele fara atribute (unde `variants` e gol dpdv UI). `nil` pt datele mock.
    let defaultVariantId: Int?

    init(
        id: Int, name: String, category: String, imageURL: URL?,
        originalPriceRON: Decimal?, priceRON: Decimal, orthoClubPriceRON: Decimal?,
        priceTiers: [PriceTier], rating: Double?, inStock: Bool, variants: [ProductVariant],
        defaultVariantId: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.imageURL = imageURL
        self.originalPriceRON = originalPriceRON
        self.priceRON = priceRON
        self.orthoClubPriceRON = orthoClubPriceRON
        self.priceTiers = priceTiers
        self.rating = rating
        self.inStock = inStock
        self.variants = variants
        self.defaultVariantId = defaultVariantId
    }

    var discountPercent: Int? {
        guard let originalPriceRON, originalPriceRON > priceRON, originalPriceRON > 0 else { return nil }
        let ratio = (originalPriceRON - priceRON) / originalPriceRON
        let ratioAsDouble = NSDecimalNumber(decimal: ratio).doubleValue
        return Int(ratioAsDouble * 100)
    }

    /// Pretul/unitate aplicabil pt o cantitate data, dupa tier-ul de cantitate potrivit (cel mai
    /// mare prag <= qty; fallback la `priceRON` daca niciun tier nu se potriveste) — la fel ca
    /// `ProductVariant.unitPrice(forQuantity:)`, folosit de cos cand produsul nu are variante.
    func unitPrice(forQuantity quantity: Int) -> Decimal {
        let applicable = priceTiers.filter { $0.minQuantity <= quantity }
        return applicable.max(by: { $0.minQuantity < $1.minQuantity })?.priceRON ?? priceRON
    }
}

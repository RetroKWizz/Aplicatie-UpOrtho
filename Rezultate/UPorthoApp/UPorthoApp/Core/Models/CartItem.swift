import Foundation

struct CartItem: Identifiable, Hashable {
    let id: UUID
    let product: Product
    let variant: ProductVariant?
    var quantity: Int

    init(id: UUID = UUID(), product: Product, variant: ProductVariant?, quantity: Int) {
        self.id = id
        self.product = product
        self.variant = variant
        self.quantity = quantity
    }

    /// Pretul/unitate corect pt cantitatea DIN LINIE (nu pretul de baza qty=1) — foloseste
    /// tier-urile de cantitate ale variantei/produsului, la fel cum se calculeaza deja pretul
    /// live in `ProductDetailView`. Bug reparat: inainte se folosea mereu `priceRON` (qty=1),
    /// ceea ce facea ca o linie cu cantitate mare sa fie taxata la pretul cel mai mare din
    /// tabel, in loc de reducerea de cantitate promisa userului pe ecranul de detaliu.
    var unitPriceRON: Decimal {
        if let variant {
            return variant.unitPrice(forQuantity: quantity)
        }
        return product.unitPrice(forQuantity: quantity)
    }

    var subtotalRON: Decimal {
        unitPriceRON * Decimal(quantity)
    }

    /// Id-ul de `product.product` (varianta) pt coșul Odoo: varianta aleasa daca exista, altfel
    /// varianta implicita a produsului. `nil` doar pt datele mock (fara integrare reala) — la
    /// datele reale din `RealOdooClient` una dintre cele doua e mereu prezenta.
    var productProductId: Int? {
        variant?.id ?? product.defaultVariantId
    }
}

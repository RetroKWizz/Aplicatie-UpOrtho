import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published var discountCode: String = ""
    @Published private(set) var appliedDiscountRON: Decimal = 0

    /// DOAR informativ (pt randul "TVA inclusa" din sumar) — NU se aduna la total. Toate
    /// preturile din `CartItem`/`Product`/`ProductVariant` sunt DEJA cu TVA inclus (la fel ca pe
    /// site, "Taxe incluse"), calculate real din Odoo (`RealOdooClient.applyVAT`). Cota de 21%
    /// e cea confirmata empiric ca standard pe toate produsele (vezi comentariul echivalent din
    /// `RealOdooClient.fallbackVatMultiplier`) — folosita aici doar pt afisarea sumei de TVA deja
    /// continuta in subtotal, nu ca taxa suplimentara.
    private let vatRate: Decimal = 0.21

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotalRON: Decimal {
        items.reduce(0) { $0 + $1.subtotalRON }
    }

    /// Suma de TVA DEJA continuta in `subtotalRON` (nu adaugata) — extrasa invers din pretul cu
    /// taxa inclusa: `pret_cu_tva * cota / (1 + cota)`. BUG reparat: inainte se aduna inca o
    /// data TVA peste un subtotal care deja o continea, dublandu-l fata de pretul real promis
    /// userului pe ecranele de produs/catalog.
    var vatRON: Decimal {
        let netAmount = subtotalRON - appliedDiscountRON
        return netAmount * vatRate / (1 + vatRate)
    }

    var totalRON: Decimal {
        subtotalRON - appliedDiscountRON
    }

    func add(product: Product, variant: ProductVariant?, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == product.id && $0.variant?.id == variant?.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, variant: variant, quantity: quantity))
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func updateQuantity(_ item: CartItem, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
    }

    /// Cod mock - va fi validat prin Odoo (pricelist/coupon) cand avem integrarea reala.
    func applyDiscountCode() {
        guard !discountCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        appliedDiscountRON = subtotalRON * 0.10
    }

    /// Goleste coșul local dupa plasarea cu succes a unei comenzi — altfel produsele raman
    /// afisate desi au fost deja trimise pe server si comanda s-a confirmat (bug raportat
    /// 18.07.2026: "dupa ce trimit comanda coșul nu face refresh").
    func clear() {
        items.removeAll()
        discountCode = ""
        appliedDiscountRON = 0
    }
}

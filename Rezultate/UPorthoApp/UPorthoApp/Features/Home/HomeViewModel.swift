import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var banners: [Banner] = []
    @Published var categories: [ProductCategory] = []
    @Published var deals: [Product] = []
    @Published var recommended: [Product] = []
    @Published var isLoading = false

    /// Clientul e primit la `load`, NU la init. Motiv: cand era stocat la init prin
    /// `@StateObject(wrappedValue: HomeViewModel(client:))`, `@Environment(\.odooClient)` inca nu
    /// era propagat, deci se captura clientul MOCK implicit (banner/produse mock). Citind clientul
    /// din environment abia in `.task`, folosim mereu instanta reala (`RealOdooClient`).
    func load(client: OdooClient) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let banners = client.fetchBanners()
            async let categories = client.fetchCategories()
            async let allProducts = client.fetchProducts(category: nil)

            self.banners = try await banners
            self.categories = try await categories
            let products = try await allProducts
            deals = products.filter { $0.discountPercent != nil }
            recommended = products.filter { $0.discountPercent == nil }
        } catch {
            print("Eroare la incarcarea Acasa: \(error)")
        }
    }
}

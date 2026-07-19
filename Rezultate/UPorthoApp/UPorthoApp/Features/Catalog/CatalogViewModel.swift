import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published var categories: [ProductCategory] = []
    @Published var products: [Product] = []
    @Published var selectedCategory: String?
    @Published var isLoading = false

    // Clientul e primit la `load`/`select`, nu la init — vezi motivul din `HomeViewModel`
    // (evitam capturarea clientului MOCK din cauza timing-ului `@StateObject` + `@Environment`).
    func load(client: OdooClient) async {
        isLoading = true
        defer { isLoading = false }
        do {
            categories = try await client.fetchCategories()
            products = try await client.fetchProducts(category: selectedCategory)
        } catch {
            print("Eroare la incarcarea catalogului: \(error)")
        }
    }

    func select(category: String?, client: OdooClient) async {
        selectedCategory = category
        do {
            products = try await client.fetchProducts(category: category)
        } catch {
            print("Eroare la filtrarea produselor: \(error)")
        }
    }
}

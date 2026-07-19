import SwiftUI

struct CategoryProductsView: View {
    let category: ProductCategory

    @State private var products: [Product] = []
    @State private var isLoading = false
    @Environment(\.odooClient) private var client

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isLoading { ProgressView() }
        }
        .task {
            await loadProducts()
        }
        .refreshable {
            await loadProducts()
        }
    }

    private func loadProducts() async {
        isLoading = true
        products = (try? await client.fetchProducts(category: category.name)) ?? []
        isLoading = false
    }
}

import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel = CatalogViewModel()
    @Environment(\.odooClient) private var client
    @Environment(\.scenePhase) private var scenePhase

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    categoryChips

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.products) { product in
                            NavigationLink(value: product) {
                                ProductCardView(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Catalog")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task {
                await viewModel.load(client: client)
            }
            .refreshable {
                if let selectedCategory = viewModel.selectedCategory {
                    await viewModel.select(category: selectedCategory, client: client)
                } else {
                    await viewModel.load(client: client)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                // La fel ca pe Acasa — reincarca din Odoo cand aplicatia revine in prim-plan,
                // pastrand categoria selectata curent (nu reseta filtrul la "Toate").
                guard newPhase == .active else { return }
                Task {
                    if let selectedCategory = viewModel.selectedCategory {
                        await viewModel.select(category: selectedCategory, client: client)
                    } else {
                        await viewModel.load(client: client)
                    }
                }
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "Toate", isSelected: viewModel.selectedCategory == nil) {
                    Task { await viewModel.select(category: nil, client: client) }
                }

                ForEach(viewModel.categories) { category in
                    chip(title: category.name, isSelected: viewModel.selectedCategory == category.name) {
                        Task { await viewModel.select(category: category.name, client: client) }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CatalogView()
        .environmentObject(CartViewModel())
}

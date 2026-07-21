import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.odooClient) private var client
    @State private var bannerIndex = 0
    @State private var presentedBannerURL: URL?

    private let bannerTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    searchBar

                    if !viewModel.banners.isEmpty {
                        TabView(selection: $bannerIndex) {
                            ForEach(Array(viewModel.banners.enumerated()), id: \.element.id) { index, banner in
                                bannerSlot(for: banner)
                                    .padding(.horizontal)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: 200)
                        .onReceive(bannerTimer) { _ in
                            withAnimation {
                                bannerIndex = (bannerIndex + 1) % viewModel.banners.count
                            }
                        }
                    }

                    quickCategories

                    productSection(title: "Oferta zilei", products: viewModel.deals)
                    productSection(title: "Recomandate pentru tine", products: viewModel.recommended)
                }
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("UpOrtho")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .navigationDestination(for: ProductCategory.self) { category in
                CategoryProductsView(category: category)
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
                await viewModel.load(client: client)
            }
            .sheet(isPresented: Binding(
                get: { presentedBannerURL != nil },
                set: { isPresented in if !isPresented { presentedBannerURL = nil } }
            )) {
                if let presentedBannerURL {
                    SafariView(url: presentedBannerURL)
                }
            }
        }
    }

    /// Bannerul de pe homepage navigheaza catre destinatia lui REALA din Odoo, oricare ar fi ea —
    /// "live", fara nimic hardcodat in aplicatie:
    /// - daca are `categoryId` (link `/shop/category/...`), navigheaza in-app catre categoria Odoo
    ///   reala legata de el, cautata recursiv in arborele deja incarcat de `viewModel.categories`
    ///   (`ProductCategory.findCategory(withId:)`);
    /// - altfel, daca are orice alt `linkURL` (ex. short-link de marketing), il deschide intr-un
    ///   browser in-app — orice link pus pe banner in Website Builder functioneaza, fara sa fie
    ///   nevoie de vreo schimbare de cod cand se schimba linkul acolo;
    /// - altfel (banner mock/fallback fara niciun link), ramane doar vizual, neapasabil.
    @ViewBuilder
    private func bannerSlot(for banner: Banner) -> some View {
        if let categoryId = banner.categoryId, let category = viewModel.categories.findCategory(withId: categoryId) {
            NavigationLink(value: category) {
                BannerCardView(banner: banner)
            }
            .buttonStyle(.plain)
        } else if let linkURL = banner.linkURL {
            Button {
                presentedBannerURL = linkURL
            } label: {
                BannerCardView(banner: banner)
            }
            .buttonStyle(.plain)
        } else {
            BannerCardView(banner: banner)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            Text("Cauta bracketi, arcuri, elastomeri...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private var quickCategories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(viewModel.categories) { category in
                    NavigationLink(value: category) {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 56, height: 56)
                                .overlay {
                                    Image(systemName: CategoryIcon.symbolName(for: category.name))
                                        .foregroundStyle(Color.accentColor)
                                }
                            Text(category.name)
                                .font(.caption2)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 70)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private func productSection(title: String, products: [Product]) -> some View {
        Group {
            if !products.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.title3.bold())
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(products) { product in
                                NavigationLink(value: product) {
                                    ProductCardView(product: product)
                                        .frame(width: 160)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CartViewModel())
}

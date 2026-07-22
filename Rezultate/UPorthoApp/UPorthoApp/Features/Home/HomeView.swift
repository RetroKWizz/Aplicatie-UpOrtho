import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.odooClient) private var client
    @Environment(\.scenePhase) private var scenePhase
    @State private var bannerIndex = 0
    @State private var presentedBannerURL: URL?

    private let bannerTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    searchBar

                    // Hero-ul singur de sus (ex. Ixion) — la fel ca pe site, NU e amestecat intr-un
                    // carusel cu cardurile de promo de mai jos, si NU e fortat intr-o inaltime fixa
                    // mica (imaginea are titlu/CTA "coapte" in ea, deci are nevoie de tot spatiul
                    // dat de aspect-ratio-ul ei — vezi `HeroBannerView`). Daca vreodata exista mai
                    // multe hero-uri (mai multe sectiuni "singure" pe homepage), tot ramane un mic
                    // carusel — dar un singur hero (cazul de azi) se afiseaza static, fara swipe.
                    if !heroBanners.isEmpty {
                        if heroBanners.count == 1 {
                            heroBannerSlot(for: heroBanners[0])
                                .padding(.horizontal)
                        } else {
                            TabView(selection: $bannerIndex) {
                                ForEach(Array(heroBanners.enumerated()), id: \.element.id) { index, banner in
                                    heroBannerSlot(for: banner)
                                        .padding(.horizontal)
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .always))
                            .frame(height: 220)
                            .onReceive(bannerTimer) { _ in
                                // Nu avansam carusel-ul cat timp un banner e deschis intr-un
                                // `SafariView` deasupra — altfel utilizatorul revine din Safari si
                                // gaseste alt banner selectat decat cel pe care l-a apasat.
                                guard presentedBannerURL == nil else { return }
                                withAnimation {
                                    bannerIndex = (bannerIndex + 1) % heroBanners.count
                                }
                            }
                        }
                    }

                    quickCategories

                    // Grila de promo de mai jos (ex. "Brackeți metalici" / "Ligaturi elastice") —
                    // 2 carduri unul langa altul, la fel ca pe site, fiecare cu titlu/subtitlu/CTA
                    // proprii (NU un carusel cu hero-ul de sus).
                    if !promoBanners.isEmpty {
                        promoBannerGrid
                    }

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
            .onChange(of: scenePhase) { newPhase in
                // Reincarca datele din Odoo de fiecare data cand aplicatia revine in prim-plan
                // (nu doar la prima deschidere / pull-to-refresh) — homepage-ul e editat live din
                // Website Builder, deci vrem ca App-ul sa reflecte mereu ce e ACUM pe site, nu ce
                // era la ultima deschidere.
                if newPhase == .active {
                    Task { await viewModel.load(client: client) }
                }
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

    private var heroBanners: [Banner] { viewModel.banners.filter(\.isHero) }
    private var promoBanners: [Banner] { viewModel.banners.filter { !$0.isHero } }

    /// Grila de promo de sub categorii — 2 carduri unul langa altul (ca pe site); daca sunt mai
    /// mult de 2, restul se vad prin scroll orizontal, fara sa strice layout-ul de 2 coloane.
    private var promoBannerGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(promoBanners) { banner in
                    bannerSlot(for: banner)
                        .frame(width: 260, height: 170)
                }
            }
            .padding(.horizontal)
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

    /// La fel ca `bannerSlot`, dar pt hero (`HeroBannerView` in loc de `BannerCardView`).
    @ViewBuilder
    private func heroBannerSlot(for banner: Banner) -> some View {
        if let categoryId = banner.categoryId, let category = viewModel.categories.findCategory(withId: categoryId) {
            NavigationLink(value: category) {
                HeroBannerView(banner: banner)
            }
            .buttonStyle(.plain)
        } else if let linkURL = banner.linkURL {
            Button {
                presentedBannerURL = linkURL
            } label: {
                HeroBannerView(banner: banner)
            }
            .buttonStyle(.plain)
        } else {
            HeroBannerView(banner: banner)
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

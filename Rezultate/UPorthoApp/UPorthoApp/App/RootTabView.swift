import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var cart: CartViewModel
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Acasa", systemImage: "house.fill") }
                .tag(0)

            CatalogView()
                .tabItem { Label("Catalog", systemImage: "square.grid.2x2.fill") }
                .tag(1)

            NavigationStack {
                CartView()
            }
            .tabItem { Label("Cos", systemImage: "cart.fill") }
            .badge(cart.itemCount > 0 ? "\(cart.itemCount)" : nil)
            .tag(2)

            AccountView()
                .tabItem { Label("Cont", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(CartViewModel())
        .environmentObject(SessionStore(client: MockOdooClient()))
}

import SwiftUI

@main
struct UPorthoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var cart = CartViewModel()

    /// Instanta unica de `OdooClient` (implementare reala, JSON-RPC) partajata in toata
    /// aplicatia prin environment, in loc de instantieri separate ad-hoc de MockOdooClient.
    private let odooClient: OdooClient

    @StateObject private var session: SessionStore

    init() {
        let client: OdooClient = RealOdooClient()
        self.odooClient = client
        _session = StateObject(wrappedValue: SessionStore(client: client))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(cart)
                .environmentObject(session)
                .environment(\.odooClient, odooClient)
        }
    }
}

/// Gate de autentificare la nivel de aplicatie: catalogul real (categorii/produse) din
/// Odoo necesita o sesiune autentificata (apel anonim -> AccessDenied), deci userul
/// trebuie sa se logheze inainte de a vedea orice continut, nu doar in tab-ul Cont.
private struct AppRootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isRestoringSession {
                ProgressView()
            } else if session.isAuthenticated {
                RootTabView()
            } else {
                LoginView()
            }
        }
        .task {
            await session.restoreSession()
        }
    }
}

import Foundation

/// Stare de autentificare la nivel de aplicatie — gate-ul de login se aplica
/// intregii aplicatii (nu doar tab-ului Cont), pentru ca fara sesiune autentificata
/// Odoo returneaza AccessDenied pe `product.template`/`product.public.category`.
@MainActor
final class SessionStore: ObservableObject {
    @Published var isAuthenticated = false
    /// True la pornire, cat timp incercam auto-login din Keychain — folosit pentru
    /// a arata un ecran scurt de loading in loc de un flash catre ecranul de login.
    @Published var isRestoringSession = true
    @Published var loginError: String?
    @Published var isLoggingIn = false

    private let client: OdooClient

    init(client: OdooClient) {
        self.client = client
    }

    /// Incearca auto-login din credentialele salvate in Keychain, daca exista.
    /// La esec (parola invalida / eroare retea), curata Keychain-ul silentios —
    /// e un logout normal de sesiune expirata, nu o eroare de afisat agresiv.
    func restoreSession() async {
        defer { isRestoringSession = false }

        guard let credentials = KeychainStore.loadCredentials() else {
            isAuthenticated = false
            return
        }

        do {
            let success = try await client.login(username: credentials.username, password: credentials.password)
            isAuthenticated = success
            if !success {
                KeychainStore.clear()
            }
        } catch {
            KeychainStore.clear()
            isAuthenticated = false
        }
    }

    func login(username: String, password: String) async {
        loginError = nil

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty, !password.isEmpty else {
            loginError = "Introdu email si parola."
            return
        }

        isLoggingIn = true
        defer { isLoggingIn = false }

        do {
            let success = try await client.login(username: trimmedUsername, password: password)
            if success {
                KeychainStore.save(username: trimmedUsername, password: password)
            }
            isAuthenticated = success
        } catch {
            isAuthenticated = false
            loginError = error.localizedDescription
        }
    }

    func logout() async {
        await client.logout()
        KeychainStore.clear()
        isAuthenticated = false
    }
}

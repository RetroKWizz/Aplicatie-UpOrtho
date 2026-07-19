import Foundation
import Security

/// Helper minimal pentru salvarea credentialelor de sesiune Odoo in iOS Keychain
/// (`kSecClassGenericPassword`) — NU folosim UserDefaults pentru parola, ar insemna
/// credentiale in clar in plist.
enum KeychainStore {
    private static let service = "ro.uportho.app.session"

    /// Salveaza username + parola in Keychain, suprascriind orice intrare existenta.
    static func save(username: String, password: String) {
        clear()

        guard let passwordData = password.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    /// Citeste perechea username+parola salvata, daca exista.
    static func loadCredentials() -> (username: String, password: String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let item = result as? [String: Any],
              let username = item[kSecAttrAccount as String] as? String,
              let passwordData = item[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            return nil
        }

        return (username: username, password: password)
    }

    /// Sterge orice credentiale salvate pentru serviciul aplicatiei.
    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}

import Foundation

/// Configurare pentru conexiunea reala la instanta Odoo a uportho.ro.
///
/// Nici `baseURL`, nici `database` nu sunt secrete: `database` a fost aflat public
/// printr-un apel neautentificat la `POST /web/database/list`. Credentialele de login
/// (username/parola) NU se stocheaza aici — sunt introduse de utilizator si tinute
/// doar in memorie de catre `RealOdooClient`, pana implementam persistare (Keychain)
/// intr-o etapa viitoare, la cerere explicita.
enum OdooConfig {
    static let baseURL = URL(string: "https://www.uportho.ro")!
    static let database = "uportho-main-4035869"
}

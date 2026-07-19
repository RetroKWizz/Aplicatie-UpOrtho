import SwiftUI

/// Cheie de environment pentru injectarea unei singure instante partajate de `OdooClient`
/// in intreaga aplicatie (RealOdooClient e un `actor`, deci nu poate fi `@EnvironmentObject`,
/// care necesita `ObservableObject`).
private struct OdooClientKey: EnvironmentKey {
    static let defaultValue: OdooClient = MockOdooClient()
}

extension EnvironmentValues {
    var odooClient: OdooClient {
        get { self[OdooClientKey.self] }
        set { self[OdooClientKey.self] = newValue }
    }
}

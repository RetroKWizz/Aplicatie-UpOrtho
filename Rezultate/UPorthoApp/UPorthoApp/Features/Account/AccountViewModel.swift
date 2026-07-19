import Foundation

@MainActor
final class AccountViewModel: ObservableObject {
    @Published var account: UserAccount?
    @Published var invoices: [Invoice] = []
    @Published var isLoading = false

    // Clientul e primit la `load` (nu la init) — vezi motivul din `HomeViewModel`.
    func load(client: OdooClient) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let account = client.fetchAccount()
            async let invoices = client.fetchInvoices()
            self.account = try await account
            self.invoices = try await invoices
        } catch {
            print("Eroare la incarcarea contului: \(error)")
        }
    }
}

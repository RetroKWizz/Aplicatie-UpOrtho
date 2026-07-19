import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @Environment(\.odooClient) private var client
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            accountContent
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Contul meu")
                .task {
                    await viewModel.load(client: client)
                }
        }
    }

    // MARK: - Continut autentificat

    private var accountContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let account = viewModel.account {
                    accountCard(account)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Facturi")
                        .font(.title3.bold())
                        .padding(.horizontal)

                    if viewModel.invoices.isEmpty && !viewModel.isLoading {
                        Text("Nu ai facturi momentan.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(viewModel.invoices) { invoice in
                                InvoiceRowView(invoice: invoice)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Button(role: .destructive) {
                    Task { await session.logout() }
                } label: {
                    Text("Delogare")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }

    private func accountCard(_ account: UserAccount) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(Text(String(account.name.prefix(1))).font(.headline).foregroundStyle(Color.accentColor))

                VStack(alignment: .leading) {
                    Text(account.name).font(.headline)
                    Text(account.email).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }

            if let vat = account.vatNumber {
                Text("CUI: \(vat)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .padding(.horizontal)
    }

}

private struct InvoiceRowView: View {
    let invoice: Invoice

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.number).font(.subheadline.weight(.semibold))
                Text("Scadenta: \(invoice.dueDate, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(invoice.amountDueRON, format: .currency(code: "RON"))
                    .font(.subheadline.bold())

                statusPill
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    private var statusPill: some View {
        let isPaid = invoice.status == .paid
        return Text(invoice.status.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isPaid ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundStyle(isPaid ? .green : .orange)
            .clipShape(Capsule())
    }
}

#Preview {
    AccountView()
        .environmentObject(SessionStore(client: MockOdooClient()))
}

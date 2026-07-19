import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartViewModel

    var body: some View {
        Group {
            if cart.items.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .navigationTitle("Cosul meu")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("Cosul tau este gol")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 10) {
                    ForEach(cart.items) { item in
                        CartRowView(item: item)
                    }
                }
                .padding(.horizontal)

                discountCodeField

                summaryCard
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                CheckoutView()
            } label: {
                Text("Finalizare comanda")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.bar)
        }
    }

    private var discountCodeField: some View {
        HStack {
            TextField("Card cadou sau cod de reducere", text: $cart.discountCode)
                .textFieldStyle(.roundedBorder)
            Button("Aplica") {
                cart.applyDiscountCode()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    private var summaryCard: some View {
        VStack(spacing: 8) {
            summaryRow("Subtotal", cart.subtotalRON)
            if cart.appliedDiscountRON > 0 {
                summaryRow("Reducere", -cart.appliedDiscountRON, tint: .green)
            }
            summaryRow("TVA inclusa (21%)", cart.vatRON)
            Divider()
            summaryRow("Total", cart.totalRON, emphasized: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func summaryRow(_ title: String, _ amount: Decimal, tint: Color? = nil, emphasized: Bool = false) -> some View {
        HStack {
            Text(title).font(emphasized ? .headline : .subheadline)
            Spacer()
            Text(amount, format: .currency(code: "RON"))
                .font(emphasized ? .headline : .subheadline)
                .foregroundStyle(tint ?? .primary)
        }
    }
}

private struct CartRowView: View {
    @EnvironmentObject private var cart: CartViewModel
    let item: CartItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 56, height: 56)
                .overlay { Image(systemName: "shippingbox").foregroundStyle(.tertiary) }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name).font(.subheadline.weight(.medium))
                if let variant = item.variant {
                    Text(variant.summary).font(.caption).foregroundStyle(.secondary)
                }
                Text(item.unitPriceRON, format: .currency(code: "RON"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)

                Stepper(value: Binding(
                    get: { item.quantity },
                    set: { cart.updateQuantity(item, quantity: $0) }
                ), in: 0...99) {
                    Text("Buc: \(item.quantity)").font(.caption)
                }
                .fixedSize()
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(item.subtotalRON, format: .currency(code: "RON")).font(.subheadline.bold())
                Button("Elimina") { cart.remove(item) }
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        CartView()
            .environmentObject(CartViewModel())
    }
}

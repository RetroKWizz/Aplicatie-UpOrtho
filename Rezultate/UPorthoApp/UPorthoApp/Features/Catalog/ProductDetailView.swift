import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(\.odooClient) private var client

    @EnvironmentObject private var cart: CartViewModel
    /// Cantitate aleasa per varianta, cheie = variant.id. Folosit doar cand produsul are variante
    /// (tabel multi-rand, cate o linie de comanda per varianta).
    @State private var quantities: [Int: Int] = [:]
    /// Cantitate pt fallback-ul simplu, cand produsul NU are variante.
    @State private var fallbackQuantity = 1
    @State private var didJustAdd = false
    @State private var description: String?
    @State private var isLoadingDescription = false

    private var unitPrice: Decimal {
        product.priceRON
    }

    /// Suma subtotalurilor tuturor variantelor cu cantitate > 0.
    private var grandTotal: Decimal {
        product.variants.reduce(Decimal(0)) { partial, variant in
            let qty = quantities[variant.id] ?? 0
            guard qty > 0 else { return partial }
            return partial + variant.unitPrice(forQuantity: qty) * Decimal(qty)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productImage

                VStack(alignment: .leading, spacing: 6) {
                    Text(product.category.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(product.name)
                        .font(.title2.bold())

                    if let rating = product.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                            Text(String(format: "%.1f", rating))
                        }
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        PriceText(
                            value: unitPrice,
                            wholeFont: .title2.bold(),
                            decimalFont: .subheadline.bold(),
                            color: Color.accentColor
                        )

                        if let original = product.originalPriceRON {
                            Text(original, format: .currency(code: "RON"))
                                .font(.subheadline)
                                .strikethrough()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                if !product.priceTiers.isEmpty {
                    sectionCard(title: "Oferta generala in functie de cantitate") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(product.priceTiers) { tier in
                                VStack(spacing: 4) {
                                    Text("\(tier.minQuantity)+ Buc.")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text(tier.priceRON, format: .currency(code: "RON"))
                                        .font(.subheadline.bold())
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }

                if let memberPrice = product.orthoClubPriceRON {
                    sectionCard(title: "Pret membri Ortho Club") {
                        HStack {
                            Image(systemName: "star.fill").foregroundStyle(Color.accentColor)
                            Text(memberPrice, format: .currency(code: "RON")).font(.subheadline.bold())
                            Spacer()
                        }
                    }
                }

                if !product.variants.isEmpty {
                    sectionCard(title: "Variante disponibile") {
                        VStack(spacing: 8) {
                            ForEach(product.variants) { variant in
                                variantRow(variant)
                            }

                            Divider().padding(.top, 4)

                            HStack {
                                Text("Total general")
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(grandTotal, format: .currency(code: "RON"))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }

                if let description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    sectionCard(title: "Descriere") {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                } else if isLoadingDescription {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Detalii produs")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            addToCartBar
        }
        .task {
            isLoadingDescription = true
            description = try? await client.fetchProductDescription(productId: product.id)
            isLoadingDescription = false
        }
    }

    private var productImage: some View {
        AsyncImage(url: product.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
        } placeholder: {
            Image(systemName: "shippingbox")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.subheadline.weight(.semibold))
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    /// Binding custom peste dictionarul `quantities`, cu clamp 0...99, pt Stepper-ul fiecarui rand.
    private func quantityBinding(for variantId: Int) -> Binding<Int> {
        Binding(
            get: { quantities[variantId] ?? 0 },
            set: { quantities[variantId] = max(0, min(99, $0)) }
        )
    }

    /// Rand de tabel pt o singura varianta: linia 1 = atribute/cod/stoc + pret pe unitate
    /// (recalculat live dupa cantitate), linia 2 = stepper cantitate + subtotal.
    private func variantRow(_ variant: ProductVariant) -> some View {
        let qty = quantities[variant.id] ?? 0
        let unit = variant.unitPrice(forQuantity: max(qty, 1))
        let subtotal = unit * Decimal(qty)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(variant.summary).font(.footnote.weight(.medium))
                        .foregroundStyle(.primary)
                    Text("Cod: \(variant.sku)").font(.caption2).foregroundStyle(.secondary)
                    Text(variant.inStock ? "In stoc" : "Stoc epuizat")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(variant.inStock ? .green : .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(unit, format: .currency(code: "RON"))
                        .font(.subheadline.bold())
                        .lineLimit(1)
                        .fixedSize()
                    Text("/ buc.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                HStack(spacing: 0) {
                    Button {
                        quantityBinding(for: variant.id).wrappedValue -= 1
                    } label: {
                        Image(systemName: "minus")
                            .font(.caption.weight(.bold))
                            .frame(width: 30, height: 28)
                    }
                    .buttonStyle(.plain)
                    .disabled(qty <= 0)

                    Text("\(qty)")
                        .font(.subheadline.weight(.semibold))
                        .frame(minWidth: 26)

                    Button {
                        quantityBinding(for: variant.id).wrappedValue += 1
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                            .frame(width: 30, height: 28)
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(variant.inStock ? Color.accentColor : .secondary)
                .background(Color(.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(!variant.inStock)
                .opacity(variant.inStock ? 1 : 0.4)

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text("Subtotal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(subtotal, format: .currency(code: "RON"))
                        .font(.subheadline.bold())
                        .foregroundStyle(qty > 0 ? Color.accentColor : .secondary)
                }
            }
        }
        .padding(10)
        .background(qty > 0 ? Color.accentColor.opacity(0.08) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var addToCartBar: some View {
        if product.variants.isEmpty {
            HStack(spacing: 12) {
                Stepper(value: $fallbackQuantity, in: 1...99) {
                    Text("Cantitate: \(fallbackQuantity)")
                        .font(.subheadline.weight(.medium))
                }
                .fixedSize()

                addToCartButton(isEnabled: product.inStock) {
                    cart.add(product: product, variant: nil, quantity: fallbackQuantity)
                }
            }
            .padding()
            .background(.bar)
        } else {
            VStack(spacing: 10) {
                HStack {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(grandTotal, format: .currency(code: "RON"))
                        .font(.title3.bold())
                        .foregroundStyle(Color.accentColor)
                    Spacer()
                }

                addToCartButton(isEnabled: grandTotal > 0) {
                    for variant in product.variants {
                        let qty = quantities[variant.id] ?? 0
                        guard qty > 0 else { continue }
                        cart.add(product: product, variant: variant, quantity: qty)
                    }
                    quantities = [:]
                }
            }
            .padding()
            .background(.bar)
        }
    }

    /// Butonul comun de "Adauga in cos" cu feedback vizual "Adaugat", reutilizat de ambele
    /// variante ale barii de jos (cu si fara tabel de variante).
    private func addToCartButton(isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            withAnimation { didJustAdd = true }
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                withAnimation { didJustAdd = false }
            }
        } label: {
            Label(didJustAdd ? "Adaugat" : "Adauga in cos", systemImage: didJustAdd ? "checkmark" : "cart.badge.plus")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(didJustAdd ? .green : Color.accentColor)
        .disabled(!isEnabled)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product(
            id: 1, name: "Set bracketi metalici Atlas Mini .022", category: "Bracketi",
            imageURL: nil, originalPriceRON: 330, priceRON: 148.5, orthoClubPriceRON: 148.5,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 264)],
            rating: nil, inStock: true, variants: []
        ))
        .environmentObject(CartViewModel())
    }
}

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: product.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .overlay {
                            Image(systemName: "shippingbox")
                                .font(.system(size: 32))
                                .foregroundStyle(.tertiary)
                        }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let discount = product.discountPercent {
                    Text("-\(discount)%")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange, in: Capsule())
                        .foregroundStyle(.white)
                        .padding(8)
                }

                if !product.inStock {
                    VStack {
                        Spacer()
                        Text("Stoc epuizat")
                            .font(.caption2.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.6))
                            .foregroundStyle(.white)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Text(product.category.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(product.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 38, alignment: .top)

            // Rezervam mereu 2 linii pt acest bloc (pret curent + pret taiat), la fel ca la nume
            // si la randul Ortho Club mai jos, ca inaltimea cardurilor sa ramana uniforma in grid
            // indiferent daca produsul are sau nu pret redus.
            VStack(alignment: .leading, spacing: 1) {
                PriceText(
                    value: product.priceRON,
                    wholeFont: .footnote.bold(),
                    decimalFont: .caption2.bold(),
                    color: Color.accentColor
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Text(product.originalPriceRON ?? 0, format: .currency(code: "RON"))
                    .font(.caption2)
                    .strikethrough()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .opacity(product.originalPriceRON == nil ? 0 : 1)
            }

            // Rezervam mereu acest rand (chiar si gol) ca inaltimea cardurilor sa ramana uniforma in grid,
            // indiferent daca produsul are sau nu pret Ortho Club.
            Label {
                if let memberPrice = product.orthoClubPriceRON, memberPrice < product.priceRON {
                    Text("Ortho Club: ") + Text(memberPrice, format: .currency(code: "RON")).bold()
                } else {
                    Text("Ortho Club: -")
                }
            } icon: {
                Image(systemName: "star.fill")
            }
            .font(.caption2)
            .foregroundStyle(Color.accentColor)
            .opacity(product.orthoClubPriceRON != nil && product.orthoClubPriceRON! < product.priceRON ? 1 : 0)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    ProductCardView(product: Product(
        id: 1, name: "Set bracketi metalici Atlas Mini .022", category: "Bracketi",
        imageURL: nil, originalPriceRON: 330, priceRON: 148.5, orthoClubPriceRON: 140,
        priceTiers: [], rating: nil, inStock: true, variants: []
    ))
    .padding()
}

import SwiftUI

/// Afiseaza un pret in stil compact "eMAG-like": partea intreaga cu font mare/bold,
/// iar partea zecimala (si sufixul monedei) intr-un font vizibil mai mic, alaturat pe
/// aceeasi linie (ex. "148" mare + ",50" mic + " RON" mic).
///
/// Doar un pattern de UX (marimi de font diferite pe aceeasi linie), nu o copiere vizuala
/// a vreunei aplicatii anume — accentul de culoare ramane mereu cel al brandului UpOrtho.
struct PriceText: View {
    let value: Decimal
    var wholeFont: Font = .subheadline.bold()
    var decimalFont: Font = .caption2.bold()
    var color: Color = .primary
    var showsCurrencySuffix: Bool = true

    var body: some View {
        let parts = Self.priceParts(value)
        Text(parts.whole)
            .font(wholeFont)
            .foregroundColor(color)
        + Text("," + parts.decimals)
            .font(decimalFont)
            .foregroundColor(color)
        + (showsCurrencySuffix
            ? Text(" RON").font(decimalFont).foregroundColor(color)
            : Text(""))
    }

    /// Separa un `Decimal` (rotunjit corect la 2 zecimale) in partea intreaga formatata
    /// cu separator de mii romanesc "." si partea zecimala pe 2 cifre.
    static func priceParts(_ value: Decimal) -> (whole: String, decimals: String) {
        var rounded = Decimal()
        var input = value
        NSDecimalRound(&rounded, &input, 2, .plain)

        let scaledCents = NSDecimalNumber(decimal: rounded * 100).intValue
        let wholeInt = scaledCents / 100
        let centsInt = abs(scaledCents % 100)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        let wholeString = formatter.string(from: NSNumber(value: wholeInt)) ?? "\(wholeInt)"

        return (wholeString, String(format: "%02d", centsInt))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        PriceText(value: 148.5, wholeFont: .footnote.bold(), decimalFont: .caption2.bold(), color: .purple)
        PriceText(value: 14599.9, wholeFont: .title.bold(), decimalFont: .subheadline.bold(), color: .purple)
        PriceText(value: 9, wholeFont: .footnote.bold(), decimalFont: .caption2.bold(), color: .purple)
    }
    .padding()
}

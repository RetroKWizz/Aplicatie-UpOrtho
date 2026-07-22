import SwiftUI
import UIKit

/// Hero-ul singur de sus (ex. Ixion) — spre deosebire de `BannerCardView` (cardurile mici de
/// promo, cu titlu/subtitlu/CTA desenate de aplicatie peste o imagine), hero-ul are TOTUL "copt"
/// in imagine (badge, titlu, buton) — la fel ca pe site, unde sectiunea nu are inaltime fixa, ci
/// se scaleaza dupa latime. `scaledToFit()` arata imaginea INTREAGA, fara crop agresiv (spre
/// deosebire de un `.frame` cu inaltime fixa + `.fill`, care taia varful cu titlul).
struct HeroBannerView: View {
    let banner: Banner

    var body: some View {
        Group {
            if let imageData = banner.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if let imageURL = banner.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(colors: banner.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 170)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: banner.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 170)
                    .overlay {
                        Image(systemName: banner.symbolName)
                            .font(.system(size: 90))
                            .foregroundStyle(.white.opacity(0.3))
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

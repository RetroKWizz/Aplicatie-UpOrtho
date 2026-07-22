import SwiftUI
import UIKit

struct BannerCardView: View {
    let banner: Banner

    var body: some View {
        ZStack {
            LinearGradient(colors: banner.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)

            if let imageData = banner.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                // Overlay intunecat peste imaginea reala, ca titlul/subtitlul (text alb) sa
                // ramana lizibil indiferent de cat de deschisa la culoare e imaginea de coperta.
                LinearGradient(
                    colors: [.black.opacity(0.55), .black.opacity(0.15)],
                    startPoint: .bottom, endPoint: .top
                )
            } else if let imageURL = banner.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                // Overlay intunecat peste imaginea reala, ca titlul/subtitlul (text alb) sa
                // ramana lizibil indiferent de cat de deschisa la culoare e imaginea de coperta.
                LinearGradient(
                    colors: [.black.opacity(0.55), .black.opacity(0.15)],
                    startPoint: .bottom, endPoint: .top
                )
            } else {
                Image(systemName: banner.symbolName)
                    .font(.system(size: 110))
                    .foregroundStyle(.white.opacity(0.15))
                    .offset(x: 90, y: 10)
            }

            // Bannerele fara titlu structurat (h3) sunt imagini "flatten" cu textul si CTA-ul
            // deja "coapte" in imagine (ex. hero-ul Ixion din Website Builder, cu propriul buton
            // "Precomandă acum" desenat in imagine) — desenarea peste ele a inca unui titlu/CTA
            // ar produce text dublat si ilizibil, si pe site nu exista un asemenea overlay
            // generic, asa ca in acel caz afisam DOAR imaginea, la fel ca pe site.
            if !banner.title.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text(banner.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text(banner.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(banner.ctaText)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.white, in: Capsule())
                        .foregroundStyle(banner.gradientColors.first ?? .accentColor)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    BannerCardView(banner: Banner(
        id: 1, title: "Alatura-te Ortho Club", subtitle: "Preturi speciale pentru membri",
        ctaText: "Vezi beneficii", symbolName: "star.circle.fill",
        gradientColors: [.purple, .indigo]
    ))
    .padding()
}

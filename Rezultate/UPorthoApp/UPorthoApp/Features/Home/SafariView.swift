import SwiftUI
import SafariServices

/// Deschide un link extern intr-un browser in-app (nu paraseste aplicatia) — folosit pt bannere
/// de pe homepage al caror link nu e o categorie Odoo cunoscuta (ex. short-link de marketing).
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

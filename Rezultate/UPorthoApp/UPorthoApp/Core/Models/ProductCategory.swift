import Foundation

struct ProductCategory: Identifiable, Hashable {
    let id: Int
    let name: String
    let productCount: Int
    let subcategories: [ProductCategory]

    /// Cauta recursiv (in sine + toate subcategoriile, la orice adancime) categoria cu id-ul
    /// dat — folosit la navigarea din bannerele sliderului real de pe Acasa, care contin doar
    /// id-ul de categorie Odoo extras din href, nu obiectul intreg.
    func findCategory(withId id: Int) -> ProductCategory? {
        if self.id == id { return self }
        for subcategory in subcategories {
            if let match = subcategory.findCategory(withId: id) {
                return match
            }
        }
        return nil
    }
}

extension Array where Element == ProductCategory {
    /// Vezi `ProductCategory.findCategory(withId:)` — cauta in toate categoriile de top nivel.
    func findCategory(withId id: Int) -> ProductCategory? {
        for category in self {
            if let match = category.findCategory(withId: id) {
                return match
            }
        }
        return nil
    }
}

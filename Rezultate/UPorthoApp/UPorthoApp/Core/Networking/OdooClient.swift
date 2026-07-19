import Foundation
import SwiftUI

protocol OdooClient {
    var isAuthenticated: Bool { get async }
    func login(username: String, password: String) async throws -> Bool
    func logout() async

    func fetchBanners() async throws -> [Banner]
    func fetchCategories() async throws -> [ProductCategory]
    func fetchProducts(category: String?) async throws -> [Product]
    func fetchAccount() async throws -> UserAccount
    func fetchInvoices() async throws -> [Invoice]

    /// Descriere lunga (HTML pe site) a unui produs, filtrata la continut in romana si
    /// convertita la text simplu. `nil` daca produsul nu are descriere. Se cere on-demand
    /// (ecranul de detaliu), NU la fetch-ul eager de catalog — vezi `RealOdooClient`.
    func fetchProductDescription(productId: Int) async throws -> String?
}

/// Date mock, pana configuram accesul real la API-ul Odoo (XML-RPC/JSON-RPC) pentru uportho.ro.
final class MockOdooClient: OdooClient {
    /// Stare triviala, doar pentru a respecta protocolul OdooClient — nu simuleaza
    /// validare reala de credentiale, mereu reuseste.
    private var authenticated = false

    var isAuthenticated: Bool {
        authenticated
    }

    func login(username: String, password: String) async throws -> Bool {
        authenticated = true
        return true
    }

    func logout() async {
        authenticated = false
    }

    private let banners: [Banner] = [
        Banner(
            id: 1, title: "Alatura-te Ortho Club",
            subtitle: "Preturi speciale pentru membri la sute de produse",
            ctaText: "Vezi beneficii", symbolName: "star.circle.fill",
            gradientColors: [Color(red: 0.42, green: 0.25, blue: 0.63), Color(red: 0.60, green: 0.41, blue: 0.80)]
        ),
        Banner(
            id: 2, title: "Pana la -60% Bracketi",
            subtitle: "Stoc limitat la seturile metalice populare",
            ctaText: "Cumpara acum", symbolName: "tag.fill",
            gradientColors: [Color(red: 0.85, green: 0.35, blue: 0.30), Color(red: 0.95, green: 0.55, blue: 0.25)]
        ),
        Banner(
            id: 3, title: "Noutati Instrumentar",
            subtitle: "Cele mai noi clesti si instrumente de precizie",
            ctaText: "Vezi produse", symbolName: "wrench.and.screwdriver.fill",
            gradientColors: [Color(red: 0.20, green: 0.45, blue: 0.55), Color(red: 0.30, green: 0.65, blue: 0.70)]
        )
    ]

    private let categories: [ProductCategory] = [
        ProductCategory(id: 1, name: "Bracketi", productCount: 38, subcategories: [
            ProductCategory(id: 11, name: "Bracketi metalici", productCount: 10, subcategories: []),
            ProductCategory(id: 12, name: "Bracketi estetici", productCount: 6, subcategories: []),
            ProductCategory(id: 13, name: "Bracketi autoligaturanti", productCount: 20, subcategories: [])
        ]),
        ProductCategory(id: 2, name: "Tuburi si inele", productCount: 45, subcategories: []),
        ProductCategory(id: 3, name: "Arcuri", productCount: 158, subcategories: []),
        ProductCategory(id: 4, name: "Adezivi", productCount: 70, subcategories: []),
        ProductCategory(id: 5, name: "Elastomeri", productCount: 46, subcategories: []),
        ProductCategory(id: 6, name: "Instrumentar", productCount: 208, subcategories: []),
        ProductCategory(id: 7, name: "Mini Implanturi", productCount: 20, subcategories: []),
        ProductCategory(id: 8, name: "Accesorii", productCount: 40, subcategories: []),
        ProductCategory(id: 9, name: "Fotografie", productCount: 29, subcategories: []),
        ProductCategory(id: 10, name: "Ingrijire pacient", productCount: 74, subcategories: []),
        ProductCategory(id: 14, name: "Echipamente", productCount: 18, subcategories: [])
    ]

    private let products: [Product] = [
        Product(
            id: 1, name: "Set bracketi metalici Atlas Mini .022", category: "Bracketi",
            imageURL: nil, originalPriceRON: 330.0, priceRON: 148.50, orthoClubPriceRON: 139.0,
            priceTiers: [
                PriceTier(minQuantity: 1, priceRON: 264.0),
                PriceTier(minQuantity: 3, priceRON: 231.0),
                PriceTier(minQuantity: 10, priceRON: 165.01),
                PriceTier(minQuantity: 20, priceRON: 148.50)
            ],
            rating: nil, inStock: true,
            variants: [
                ProductVariant(
                    id: 101, sku: "DF201-M2-345",
                    attributes: [
                        VariantAttribute(label: "Brand", value: "Dynaflex Orthodontics"),
                        VariantAttribute(label: "Tip set", value: "All Hooks"),
                        VariantAttribute(label: "Prescriptie", value: "MBT"),
                        VariantAttribute(label: "Slot", value: ".022")
                    ],
                    priceRON: 148.50,
                    inStock: true,
                    priceTiers: [
                        PriceTier(minQuantity: 1, priceRON: 264.0),
                        PriceTier(minQuantity: 3, priceRON: 231.0),
                        PriceTier(minQuantity: 10, priceRON: 165.01),
                        PriceTier(minQuantity: 20, priceRON: 148.50)
                    ]
                ),
                ProductVariant(
                    id: 102, sku: "DF201-R2-345",
                    attributes: [
                        VariantAttribute(label: "Brand", value: "Dynaflex Orthodontics"),
                        VariantAttribute(label: "Tip set", value: "All Hooks"),
                        VariantAttribute(label: "Prescriptie", value: "Roth"),
                        VariantAttribute(label: "Slot", value: ".022")
                    ],
                    priceRON: 148.50,
                    inStock: true,
                    priceTiers: [
                        PriceTier(minQuantity: 1, priceRON: 264.0),
                        PriceTier(minQuantity: 3, priceRON: 231.0),
                        PriceTier(minQuantity: 10, priceRON: 165.01),
                        PriceTier(minQuantity: 20, priceRON: 148.50)
                    ]
                )
            ]
        ),
        Product(
            id: 2, name: "Set bracketi metalici miniPrevail", category: "Bracketi",
            imageURL: nil, originalPriceRON: 390.0, priceRON: 155.99, orthoClubPriceRON: 149.99,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 155.99)],
            rating: nil, inStock: true, variants: []
        ),
        Product(
            id: 3, name: "Arc NiTi rotund .014", category: "Arcuri",
            imageURL: nil, originalPriceRON: nil, priceRON: 8.0, orthoClubPriceRON: 7.2,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 8.0)],
            rating: 5.0, inStock: true, variants: []
        ),
        Product(
            id: 4, name: "Cleste pentru indepartare inele", category: "Instrumentar",
            imageURL: nil, originalPriceRON: nil, priceRON: 145.0, orthoClubPriceRON: 135.0,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 145.0)],
            rating: nil, inStock: true, variants: []
        ),
        Product(
            id: 5, name: "Adeziv fotopolimerizabil Transbond", category: "Adezivi",
            imageURL: nil, originalPriceRON: 300.0, priceRON: 135.0, orthoClubPriceRON: 129.0,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 135.0)],
            rating: nil, inStock: false, variants: []
        ),
        Product(
            id: 6, name: "Elastomeri lant gri fumuriu", category: "Elastomeri",
            imageURL: nil, originalPriceRON: 45.0, priceRON: 27.0, orthoClubPriceRON: 25.0,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 27.0)],
            rating: 4.5, inStock: true, variants: []
        ),
        Product(
            id: 7, name: "Mini implant ortodontic 1.6x8mm", category: "Mini Implanturi",
            imageURL: nil, originalPriceRON: nil, priceRON: 210.0, orthoClubPriceRON: 199.0,
            priceTiers: [PriceTier(minQuantity: 1, priceRON: 210.0)],
            rating: nil, inStock: true, variants: []
        )
    ]

    func fetchBanners() async throws -> [Banner] {
        banners
    }

    func fetchCategories() async throws -> [ProductCategory] {
        categories
    }

    func fetchProducts(category: String?) async throws -> [Product] {
        guard let category else { return products }
        return products.filter { $0.category == category }
    }

    func fetchAccount() async throws -> UserAccount {
        UserAccount(id: 1, name: "Cabinet Demo", email: "demo@uportho.ro", vatNumber: "RO12345678")
    }

    /// Mock trivial — nu simuleaza continut real, doar respecta protocolul.
    func fetchProductDescription(productId: Int) async throws -> String? {
        nil
    }

    func fetchInvoices() async throws -> [Invoice] {
        let calendar = Calendar.current
        func date(_ daysFromNow: Int) -> Date {
            calendar.date(byAdding: .day, value: daysFromNow, to: Date())!
        }
        return [
            Invoice(id: 1, number: "UPO/2026/04820", invoiceDate: date(-2), dueDate: date(13), amountDueRON: 571.11, status: .awaitingPayment),
            Invoice(id: 2, number: "UPO/2026/04819", invoiceDate: date(-2), dueDate: date(43), amountDueRON: 180.0, status: .awaitingPayment),
            Invoice(id: 3, number: "UPO/2026/04816", invoiceDate: date(-2), dueDate: date(28), amountDueRON: 0, status: .paid),
            Invoice(id: 4, number: "UPO/2026/04814", invoiceDate: date(-2), dueDate: date(43), amountDueRON: 0, status: .paid)
        ]
    }
}

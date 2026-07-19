import Foundation

/// Modele pentru fluxul de checkout condus prin rutele `website_sale` ale site-ului
/// (vezi `CheckoutService`). Sunt reprezentari ale starii server-side a comenzii (coș,
/// adrese, curieri, plata), NU o reimplementare a logicii — totul e citit/scris pe server,
/// iar aici doar tipizam raspunsurile ca sa le poata folosi UI-ul (task #30).

/// Starea coșului asa cum o raporteaza serverul dupa o operatie pe `/shop/cart/update_json`.
struct CartServerState: Equatable {
    /// Numarul total de bucati din coș (badge-ul din header-ul site-ului).
    let itemCount: Int
    /// Id-ul liniei `sale.order.line` create/actualizate (cand e disponibil) — necesar pt a
    /// modifica ulterior cantitatea aceleiasi linii cu `set_qty`.
    let lineId: Int?
}

/// O adresa asociata contului (livrare sau facturare), asa cum apare pe `/shop/checkout`.
/// `partnerId` e `res.partner.id` (atributul `data-partner-id` de pe cardul de adresa),
/// folosit la selectare prin `/shop/update_address`. `mode` = `data-address-type`
/// ("delivery" / "billing").
struct CheckoutAddress: Identifiable, Equatable {
    let id: Int          // == partnerId
    let partnerId: Int
    let mode: String     // "delivery" | "billing"
    let name: String     // textul cardului (nume + adresa), best-effort
}

/// O optiune de livrare (curier) de pe pagina de checkout.
/// `pret == nil` cand tariful nu e inca calculat (se afla apoi cu `/shop/get_delivery_rate`).
struct DeliveryOption: Identifiable, Equatable {
    let id: Int          // == carrierId (delivery.carrier)
    let carrierId: Int
    let name: String
    let priceRON: Decimal?
    let isFree: Bool
}

/// O metoda de plata de pe `/shop/payment` (ex. Card Stripe, Transfer bancar).
/// Atribute din DOM: `data-provider-id`, `data-payment-option-id` (id de `payment.method`),
/// `data-payment-method-code`. Tranzactia (`/payment/transaction`) cere AMBELE:
/// `provider_id` + `payment_method_id`.
struct PaymentOption: Identifiable, Equatable {
    let id: Int              // == paymentMethodId (unic per rand din DOM)
    let providerId: Int      // payment.provider.id (ex. 5 = transfer, 8 = stripe)
    let paymentMethodId: Int // payment.method.id (data-payment-option-id, ex. 217 = wire_transfer)
    /// Cod tehnic al metodei: "wire_transfer" (transfer bancar, offline) / "card" etc.
    let code: String

    /// Nume prietenos in romana derivat din `code` (fallback fiabil cand textul din DOM lipseste).
    var displayName: String {
        switch code {
        case "wire_transfer": return "Transfer bancar"
        case "card": return "Card"
        // "on_delivery" apare doar cand e ales un curier cu ramburs (ex. "Fan Courier ramburs")
        // — Odoo restrange automat metodele de plata la aceasta, singura compatibila cu ramburs
        // (verificat live 18.07.2026: `/shop/payment` filtreaza server-side dupa curierul curent).
        case "on_delivery": return "Plată ramburs"
        default: return code.isEmpty ? "Plata #\(paymentMethodId)" : code
        }
    }
}

/// Contextul formularului de plata, citit din `form.o_payment_form` de pe `/shop/payment`
/// (atribute `data-*`, verificate live 16.07.2026). Necesare pt POST-ul de tranzactie.
struct PaymentContext: Equatable {
    let amount: Decimal
    let currencyId: Int
    let partnerId: Int
    let accessToken: String
    /// Ruta de tranzactie specifica comenzii, ex. `/shop/payment/transaction/41652`.
    let transactionRoute: String
    /// Ruta de finalizare (ex. `/shop/payment/validate`).
    let landingRoute: String
}

/// Rezultatul plasarii comenzii — numarul de referinta (ex. "CMD41604") si suma confirmata,
/// citite direct din raspunsul tranzactiei (`reference`, `amount`).
struct OrderConfirmation: Equatable {
    let reference: String
    let amountRON: Decimal?
}

// MARK: - Creare adresa noua (formular `/shop/address`)

/// Un judet (`res.country.state`) pt pickerul de adresa.
struct RomanianCounty: Identifiable, Equatable {
    let id: Int      // == state_id (data din formular)
    let name: String
}

/// Constante geografice pt România, citite live din formularul `/shop/address` (16.07.2026):
/// `country_id 188` = România; cele 42 de judete cu id-urile lor de `res.country.state`.
/// Sunt statice (nu se schimba) — le tinem local ca sa nu mai facem un roundtrip la deschidere.
enum RomaniaGeo {
    static let countryId = 188

    static let counties: [RomanianCounty] = [
        .init(id: 710, name: "Alba"), .init(id: 711, name: "Argeș"), .init(id: 712, name: "Arad"),
        .init(id: 713, name: "București"), .init(id: 714, name: "Bacău"), .init(id: 715, name: "Bihor"),
        .init(id: 716, name: "Bistrița-Năsăud"), .init(id: 717, name: "Brăila"), .init(id: 718, name: "Botoșani"),
        .init(id: 719, name: "Brașov"), .init(id: 720, name: "Buzău"), .init(id: 721, name: "Cluj"),
        .init(id: 722, name: "Călărași"), .init(id: 723, name: "Caraș-Severin"), .init(id: 724, name: "Constanța"),
        .init(id: 725, name: "Covasna"), .init(id: 726, name: "Dâmbovița"), .init(id: 727, name: "Dolj"),
        .init(id: 728, name: "Gorj"), .init(id: 729, name: "Galați"), .init(id: 730, name: "Giurgiu"),
        .init(id: 731, name: "Hunedoara"), .init(id: 732, name: "Harghita"), .init(id: 733, name: "Ilfov"),
        .init(id: 734, name: "Ialomița"), .init(id: 735, name: "Iași"), .init(id: 736, name: "Mehedinți"),
        .init(id: 737, name: "Maramureș"), .init(id: 738, name: "Mureș"), .init(id: 739, name: "Neamț"),
        .init(id: 740, name: "Olt"), .init(id: 741, name: "Prahova"), .init(id: 742, name: "Sibiu"),
        .init(id: 743, name: "Sălaj"), .init(id: 744, name: "Satu Mare"), .init(id: 745, name: "Suceava"),
        .init(id: 746, name: "Tulcea"), .init(id: 747, name: "Timiș"), .init(id: 748, name: "Teleorman"),
        .init(id: 749, name: "Vâlcea"), .init(id: 750, name: "Vrancea"), .init(id: 751, name: "Vaslui")
    ]

    /// Judetele sortate alfabetic (romaneste) pt afisare in picker.
    static let countiesSorted: [RomanianCounty] =
        counties.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
}

/// O localitate din registrul Odoo (`res.city`), specifica unui judet. Instanta uportho.ro
/// impune orase din registru (`country_enforce_cities`) — un `city` text liber e RESPINS de
/// `/shop/address/submit` cu `invalid_fields: [city_id]` (verificat live 17.07.2026). Lista se
/// obtine per-judet din `POST /shop/state_infos/<stateId>` -> `{cities: [[id, nume, cod_postal], ...]}`.
struct CityOption: Identifiable, Equatable {
    let id: Int
    let name: String
    let zip: String
}

/// Datele introduse de utilizator pentru o adresa noua — mapate 1:1 pe campurile formularului
/// `/shop/address` din Odoo 18. Obligatorii server-side: `name` + `countryId`, plus `city_id`
/// (registrul de orase impus pe aceasta instanta — vezi `CityOption`).
struct CheckoutAddressDraft: Equatable {
    var name = ""
    var email = ""
    var phone = ""
    var companyName = ""
    var vat = ""          // CIF
    var street = ""
    var street2 = ""
    var city = ""
    var cityId: Int?      // res.city id (registrul de orase, obligatoriu pe aceasta instanta)
    var zip = ""
    var countyId: Int?    // state_id
    var countryId = RomaniaGeo.countryId
}

/// Ce adresa asteapta Odoo la checkout, parsat din formularul `/shop/address` (campurile ascunse
/// `address_type` si `required_fields`). Ne spune ce titlu sa aratam si ce sa retrimitem la submit.
struct AddressFormSpec: Equatable {
    let addressType: String     // "billing" | "delivery"
    let requiredFields: String  // pass-through catre submit (ex. "name,country_id")

    var title: String {
        addressType == "billing" ? "Adresă de facturare" : "Adresă de livrare"
    }
}

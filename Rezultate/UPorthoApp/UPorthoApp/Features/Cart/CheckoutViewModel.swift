import Foundation

/// Orchestreaza checkout-ul REAL din aplicatie ca flux in 3 pasi controlati de app (NU de
/// redirect-urile interne ale lui `/shop/checkout`, care decid singure ordinea si nu permit un
/// pas de facturare inaintea celui de livrare — cerinta explicita a userului, 18.07.2026):
///
///   1. Facturare — lista adreselor de facturare existente + optiunea "adauga adresa noua"
///      (mereu disponibila, chiar daca exista deja adrese) -> Next
///   2. Livrare — la fel, pt adrese de livrare -> Next
///   3. Plata — curier + metoda de plata -> Plaseaza comanda
///
/// Listele de adrese vin direct din `res.partner` (`CheckoutService.fetchAddresses`), NU din
/// cardurile parsate de pe `/shop/checkout` (care nu exista decat dupa ce Odoo insusi considera
/// ambele adrese complete). Selectia efectiva pe comanda (`/shop/update_address`) se aplica abia
/// la trecerea spre pasul de plata, pt fiecare tip.
///
/// Sesiunea web e SEPARATA de clientul JSON-RPC (catalog): se logheaza cu aceleasi credentiale
/// din Keychain, dar tine propriul cookie de sesiune (vezi `OdooWebSession`).
@MainActor
final class CheckoutViewModel: ObservableObject {

    enum Phase: Equatable {
        case idle
        case preparing          // login + sync coș + incarcare liste
        case billingStep
        case deliveryStep
        case paymentStep
        case placing
        case confirmed(OrderConfirmation)
        case failed(String)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var billingAddresses: [CheckoutAddress] = []
    @Published private(set) var deliveryAddresses: [CheckoutAddress] = []
    @Published private(set) var deliveryOptions: [DeliveryOption] = []
    @Published private(set) var paymentOptions: [PaymentOption] = []

    @Published var selectedBillingId: Int?
    @Published var selectedDeliveryAddressId: Int?
    @Published private(set) var selectedDeliveryId: Int?     // curier
    @Published var selectedPaymentId: Int?
    /// Cat timp reincarcam metodele de plata dupa schimbarea curierului (vezi
    /// `selectDeliveryMethod`) — dezactiveaza tab-urile de plata ca sa nu se selecteze o optiune
    /// care e pe cale sa dispara din lista.
    @Published private(set) var isUpdatingPaymentOptions = false

    /// Formularul de adaugare adresa (folosit de ambii pasi de adresa — tipul curent e in `spec`).
    @Published private(set) var isShowingAddressForm = false
    @Published private(set) var addressFormSpec: AddressFormSpec?
    @Published private(set) var isSavingAddress = false
    @Published var addressError: String?

    /// Contextul formularului de plata (amount, access_token, transactionRoute etc.), necesar
    /// pt POST-ul de tranzactie. Citit din `/shop/payment`.
    private var paymentContext: PaymentContext?

    private let service: CheckoutService
    private let session: OdooWebSession

    init() {
        self.session = OdooWebSession()
        self.service = CheckoutService(session: session)
    }

    /// True cand toate selectiile obligatorii sunt facute si suntem in pasul de plata.
    /// ATENTIE: plasarea comenzii creeaza o comanda REALA in Odoo (fluxul e activ, fara gate).
    var canPlaceOrder: Bool {
        guard case .paymentStep = phase, !isUpdatingPaymentOptions else { return false }
        return selectedDeliveryId != nil && selectedPaymentId != nil && paymentContext != nil
    }

    // MARK: - Pornire + sincronizare coș

    /// Porneste fluxul: login web, sincronizeaza liniile de coș pe server, apoi incarca pasul 1
    /// (facturare).
    func start(items: [CartItem]) async {
        guard case .idle = phase else { return }
        phase = .preparing

        guard let credentials = KeychainStore.loadCredentials() else {
            phase = .failed("Sesiune inactiva — autentifica-te din nou.")
            return
        }

        do {
            try await session.login(username: credentials.username, password: credentials.password)
            try await syncCart(items: items)
            try await loadBillingStep()
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    /// Reconciliaza coșul REAL de pe server cu coșul local, ca totalul din app sa fie mereu
    /// totalul care se plaseaza — nu doar il "completeaza" (asa cum facea vechiul `addToCart`
    /// pt fiecare linie, cu `add_qty`). BUG reprodus live (17-18.07.2026): coșul server-side e
    /// legat de cont, NU se goleste la reinstalarea aplicatiei — reincercari succesive de
    /// checkout adaugau aceleasi produse PESTE cele ramase dintr-o incercare anterioara,
    /// rezultand o comanda de 2.970,03 RON cand coșul local arata 264,00 RON.
    ///
    /// Algoritm: citim liniile reale (`product_id` -> `line_id`/cantitate), apoi:
    /// - linie server care nu mai exista in coșul local -> `set_qty: 0` (eliminata)
    /// - linie server cu cantitate diferita de cea locala -> `set_qty: <cantitatea locala>`
    /// - produs local fara linie server -> `add_qty: <cantitatea locala>` (creeaza linia)
    private func syncCart(items: [CartItem]) async throws {
        let serverLines = try await service.fetchCartLines()
        let localQuantities = Dictionary(
            items.compactMap { item -> (Int, Int)? in
                guard let productId = item.productProductId else { return nil }
                return (productId, item.quantity)
            },
            uniquingKeysWith: +
        )

        for (productId, server) in serverLines where localQuantities[productId] == nil {
            try await service.setCartLineQuantity(lineId: server.lineId, productId: productId, quantity: 0)
        }
        for (productId, quantity) in localQuantities {
            if let server = serverLines[productId] {
                if server.quantity != quantity {
                    try await service.setCartLineQuantity(lineId: server.lineId, productId: productId, quantity: quantity)
                }
            } else {
                try await service.addToCart(productId: productId, quantity: quantity)
            }
        }
    }

    // MARK: - Pasul 1: Facturare

    private func loadBillingStep() async throws {
        let list = try await service.fetchAddresses(type: "billing")
        billingAddresses = list
        selectedBillingId = list.first?.id
        phase = .billingStep
    }

    /// Butonul "Next" din pasul de facturare.
    func proceedFromBilling() async {
        guard selectedBillingId != nil else { return }
        phase = .preparing
        do {
            try await loadDeliveryStep()
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    // MARK: - Pasul 2: Livrare

    private func loadDeliveryStep() async throws {
        let list = try await service.fetchAddresses(type: "delivery")
        deliveryAddresses = list
        selectedDeliveryAddressId = list.first?.id
        phase = .deliveryStep
    }

    /// Butonul "Next" din pasul de livrare: aplica AMBELE adrese pe comanda curenta
    /// (`/shop/update_address`), apoi incarca curierii si metodele de plata calculate de Odoo
    /// pt aceasta combinatie.
    func proceedFromDelivery() async {
        guard let billingId = selectedBillingId, let deliveryId = selectedDeliveryAddressId else { return }
        phase = .preparing
        do {
            try await service.selectAddress(partnerId: billingId, addressType: "billing")
            try await service.selectAddress(partnerId: deliveryId, addressType: "delivery")

            switch try await service.fetchCheckout() {
            case .addressForm(let spec):
                // Nu ar trebui sa se intample (tocmai am setat ambele adrese) — semnal ca ceva
                // nu s-a asociat corect pe comanda; aratam eroarea in loc sa reintram in bucla.
                let label = spec.addressType == "billing" ? "facturare" : "livrare"
                phase = .failed("Odoo cere din nou o adresa de \(label) — reincearca pasii de adresa.")
            case .checkout(_, let deliveryOpts):
                deliveryOptions = deliveryOpts
                selectedDeliveryId = deliveryOpts.first?.id
                let payment = try await service.fetchPayment()
                paymentOptions = payment.options
                paymentContext = payment.context
                selectedPaymentId = paymentOptions.first?.id
                phase = .paymentStep
            }
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    // MARK: - Formular adresa noua (comun ambilor pasi)

    /// Deschide formularul de adaugare adresa pt tipul curent ("billing"/"delivery") — disponibil
    /// mereu, indiferent daca exista deja adrese de acel tip.
    func startAddAddress(type: String) async {
        addressError = nil
        do {
            addressFormSpec = try await service.fetchAddressForm(addressType: type)
                ?? AddressFormSpec(addressType: type, requiredFields: "name,country_id")
            isShowingAddressForm = true
        } catch {
            addressError = error.localizedDescription
        }
    }

    func cancelAddAddress() {
        isShowingAddressForm = false
        addressFormSpec = nil
        addressError = nil
    }

    /// Salveaza adresa noua prin fluxul standard al site-ului (`/shop/address/submit`), apoi
    /// reincarca lista corespunzatoare tipului si preselecteaza adresa nou creata (id-ul maxim —
    /// Odoo aloca mereu id crescator).
    func submitAddress(_ draft: CheckoutAddressDraft) async {
        guard let spec = addressFormSpec else { return }
        addressError = nil
        isSavingAddress = true
        defer { isSavingAddress = false }

        do {
            _ = try await service.submitAddress(
                draft: draft, addressType: spec.addressType, requiredFields: spec.requiredFields
            )
            let list = try await service.fetchAddresses(type: spec.addressType)
            let newestId = list.map(\.id).max()
            if spec.addressType == "billing" {
                billingAddresses = list
                selectedBillingId = newestId
            } else {
                deliveryAddresses = list
                selectedDeliveryAddressId = newestId
            }
            isShowingAddressForm = false
            addressFormSpec = nil
        } catch {
            addressError = error.localizedDescription
        }
    }

    /// Localitatile din registru pt judetul ales (`/shop/state_infos/<id>`), pt pickerul de
    /// adresa. Esec silentios (lista goala) — formularul ramane utilizabil, doar fara optiuni.
    func fetchCities(stateId: Int) async -> [CityOption] {
        (try? await service.fetchCities(stateId: stateId)) ?? []
    }

    // MARK: - Pasul 3: Plata

    /// Selecteaza curierul si RE-CITESTE metodele de plata compatibile — pe uportho.ro, fiecare
    /// curier vine cu o lista proprie de provideri de plata permisi (verificat live 18.07.2026:
    /// `data-acquirer-allowed-ids` pe randul curierului in `/shop/checkout`; ex. "Fan Courier" =
    /// `[8, 5]` -> Card + Transfer bancar, dar "Fan Courier ramburs" = `[29]` -> DOAR "Plata
    /// ramburs"). Filtrarea se aplica SERVER-SIDE, in `/shop/payment` — dupa ce setam curierul,
    /// simplu re-citim pagina de plata si Odoo insusi intoarce doar optiunile compatibile.
    ///
    /// BUG reparat: inainte, `selectedDeliveryId` era un `@Published var` simplu, fara efect —
    /// userul putea alege "Fan Courier ramburs" si tot vedea Card/Transfer bancar in lista de
    /// plata (ramase de la incarcarea initiala), desi pe site alegerea unui curier ramburs
    /// restrange automat plata doar la acel curier.
    func selectDeliveryMethod(_ dmId: Int) async {
        guard selectedDeliveryId != dmId else { return }
        selectedDeliveryId = dmId
        isUpdatingPaymentOptions = true
        defer { isUpdatingPaymentOptions = false }
        do {
            try await service.setDeliveryMethod(dmId: dmId)
            let payment = try await service.fetchPayment()
            paymentOptions = payment.options
            paymentContext = payment.context
            // Pastreaza selectia curenta daca inca e valida in noua lista; altfel prima optiune.
            if let current = selectedPaymentId, paymentOptions.contains(where: { $0.id == current }) {
                // ramane neschimbata
            } else {
                selectedPaymentId = paymentOptions.first?.id
            }
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    /// Plaseaza comanda REALA in Odoo (flux activ, fara plasa de siguranta).
    func placeOrder() async {
        guard canPlaceOrder,
              let methodId = selectedPaymentId,
              let option = paymentOptions.first(where: { $0.id == methodId }),
              let context = paymentContext else { return }
        phase = .placing
        do {
            // Curierul e deja aplicat pe server la fiecare selectie (vezi `selectDeliveryMethod`)
            // — mai reimprospatam o data contextul de plata, pt siguranta (poate a stat mult timp
            // pe ecran si access_token-ul/totalul s-au putut schimba intre timp).
            let refreshed = try await service.fetchPayment()
            let finalContext = refreshed.context ?? context
            let confirmation = try await service.placeOrder(
                providerId: option.providerId,
                paymentMethodId: option.paymentMethodId,
                context: finalContext
            )
            phase = .confirmed(confirmation)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

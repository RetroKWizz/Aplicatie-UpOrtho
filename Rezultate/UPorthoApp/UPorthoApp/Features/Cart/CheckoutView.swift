import SwiftUI

/// Checkout REAL, in 3 pasi controlati de app (facturare -> livrare -> plata — vezi
/// `CheckoutViewModel`). Adresele, curierii, metodele de plata si totalurile vin de pe server
/// (nereimplementate aici). Plasarea comenzii creeaza o comanda REALA.
struct CheckoutView: View {
    @EnvironmentObject private var cart: CartViewModel
    @StateObject private var vm = CheckoutViewModel()

    var body: some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            // Tab bar-ul plutitor (iOS 18+ "liquid glass") ramane vizibil peste ecranele
            // push-uite din NavigationStack si isi intercepteaza atingerile pe o banda mai inalta
            // decat pilula vizibila — pe formularul de adresa, ultimele randuri (Localitate/Cod
            // postal/Judet/Salveaza adresa) ajungeau in acea banda si taps-urile mergeau la tab-ul
            // Cos in loc de camp (reprodus cu automatizare UI). Checkout e oricum un flux
            // concentrat — ascundem tab bar-ul cat timp e activ, ca pe majoritatea site-urilor de
            // ecommerce.
            .toolbar(.hidden, for: .tabBar)
            .task { await vm.start(items: cart.items) }
            .onChange(of: vm.phase) { newPhase in
                // Coșul local nu se golea dupa o comanda plasata cu succes — produsele deja
                // trimise pe server ramaneau afisate ca inca netrimise (bug raportat 18.07.2026).
                if case .confirmed = newPhase {
                    cart.clear()
                }
            }
            .sheet(isPresented: Binding(
                get: { vm.isShowingAddressForm },
                set: { if !$0 { vm.cancelAddAddress() } }
            )) {
                if let spec = vm.addressFormSpec {
                    NavigationStack {
                        AddressFormView(
                            spec: spec,
                            isSaving: vm.isSavingAddress,
                            errorMessage: vm.addressError,
                            fetchCities: { stateId in await vm.fetchCities(stateId: stateId) }
                        ) { draft in
                            Task { await vm.submitAddress(draft) }
                        }
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Anulează") { vm.cancelAddAddress() }
                            }
                        }
                    }
                }
            }
    }

    private var title: String {
        switch vm.phase {
        case .billingStep: return "Adresă facturare"
        case .deliveryStep: return "Adresă livrare"
        case .paymentStep: return "Livrare și plată"
        default: return "Finalizare comandă"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.phase {
        case .idle, .preparing:
            loading("Se pregateste comanda...")
        case .billingStep:
            addressStepView(
                stepLabel: "Pasul 1 din 3",
                addresses: vm.billingAddresses,
                selection: $vm.selectedBillingId,
                emptyText: "Nicio adresă de facturare pe cont.",
                addButtonTitle: "Adaugă adresă de facturare",
                onAdd: { Task { await vm.startAddAddress(type: "billing") } },
                onNext: { Task { await vm.proceedFromBilling() } }
            )
        case .deliveryStep:
            addressStepView(
                stepLabel: "Pasul 2 din 3",
                addresses: vm.deliveryAddresses,
                selection: $vm.selectedDeliveryAddressId,
                emptyText: "Nicio adresă de livrare pe cont.",
                addButtonTitle: "Adaugă adresă de livrare",
                onAdd: { Task { await vm.startAddAddress(type: "delivery") } },
                onNext: { Task { await vm.proceedFromDelivery() } }
            )
        case .paymentStep:
            paymentStepView
        case .placing:
            loading("Se plaseaza comanda...")
        case .failed(let message):
            failure(message)
        case .confirmed(let confirmation):
            confirmed(confirmation)
        }
    }

    // MARK: - Stari

    private func loading(_ label: String) -> some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(label).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func failure(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40)).foregroundStyle(.orange)
            Text("Nu s-a putut pregati comanda").font(.headline)
            Text(message).font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func confirmed(_ confirmation: OrderConfirmation) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48)).foregroundStyle(.green)
            Text("Comanda plasata").font(.title3.bold())
            Text("Referinta: \(confirmation.reference)").font(.subheadline)
            if let amount = confirmation.amountRON {
                Text(amount, format: .currency(code: "RON"))
                    .font(.headline).foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Pasi 1 si 2: adresa (facturare / livrare)

    /// Ecran comun pt pasii de adresa: lista adreselor existente de tipul respectiv (daca exista)
    /// + buton "Adaugă adresă" MEREU vizibil (chiar daca exista deja adrese) + buton "Next",
    /// activ doar cand e selectata o adresa.
    private func addressStepView(
        stepLabel: String,
        addresses: [CheckoutAddress],
        selection: Binding<Int?>,
        emptyText: String,
        addButtonTitle: String,
        onAdd: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(stepLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                if addresses.isEmpty {
                    section(nil) {
                        Text(emptyText).font(.caption).foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 10) {
                        ForEach(addresses) { address in
                            let parts = addressCardParts(address)
                            SelectableCard(
                                title: parts.title,
                                subtitle: parts.subtitle,
                                isSelected: selection.wrappedValue == address.id
                            ) {
                                selection.wrappedValue = address.id
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: onAdd) {
                    Label(addButtonTitle, systemImage: "plus.circle")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            Button(action: onNext) {
                Text("Next")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selection.wrappedValue == nil)
            .padding()
            .background(.bar)
        }
    }

    // MARK: - Pasul 3: livrare + plata

    private var paymentStepView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pasul 3 din 3")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                deliverySection
                paymentSection
                totalSection
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) { placeOrderButton }
    }

    private static let tabColumns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    private var deliverySection: some View {
        section("Metoda de livrare") {
            if vm.deliveryOptions.isEmpty {
                Text("Nicio metoda de livrare disponibila.").font(.caption).foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: Self.tabColumns, spacing: 10) {
                    ForEach(vm.deliveryOptions) { option in
                        SquareTab(
                            title: option.name.isEmpty ? "Curier #\(option.id)" : option.name,
                            subtitle: deliveryPriceLabel(option),
                            isSelected: vm.selectedDeliveryId == option.id
                        ) {
                            Task { await vm.selectDeliveryMethod(option.id) }
                        }
                    }
                }
                // Curierii cu ramburs restrang metodele de plata (verificat live pe site 18.07.2026:
                // "Fan Courier ramburs" permite DOAR plata ramburs) — Odoo recalculeaza lista la
                // schimbarea curierului; aratam un semnal vizual cat timp se reincarca.
                if vm.isUpdatingPaymentOptions {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Se actualizează metodele de plată disponibile...")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var paymentSection: some View {
        section("Metoda de plata") {
            if vm.paymentOptions.isEmpty {
                Text("Nicio metoda de plata disponibila.").font(.caption).foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: Self.tabColumns, spacing: 10) {
                    ForEach(vm.paymentOptions) { option in
                        SquareTab(
                            title: option.displayName,
                            subtitle: nil,
                            isSelected: vm.selectedPaymentId == option.id
                        ) {
                            vm.selectedPaymentId = option.id
                        }
                    }
                }
                .disabled(vm.isUpdatingPaymentOptions)
                .opacity(vm.isUpdatingPaymentOptions ? 0.5 : 1)
            }
        }
    }

    private var totalSection: some View {
        section("Total de plata") {
            HStack {
                Text("Total").font(.headline)
                Spacer()
                Text(cart.totalRON, format: .currency(code: "RON")).font(.headline)
            }
        }
    }

    private var placeOrderButton: some View {
        Button {
            Task { await vm.placeOrder() }
        } label: {
            Text("Plaseaza comanda")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!vm.canPlaceOrder)
        .padding()
        .background(.bar)
    }

    // MARK: - Helpers

    private func deliveryPriceLabel(_ option: DeliveryOption) -> String? {
        if option.isFree { return "Gratuit" }
        if let price = option.priceRON { return price.formatted(.currency(code: "RON")) }
        return nil
    }

    /// Desparte eticheta unei adrese ("Nume — stradă, oraș", format din
    /// `CheckoutService.fetchAddresses`) in titlu + subtitlu, pt cardul din UI.
    private func addressCardParts(_ address: CheckoutAddress) -> (title: String, subtitle: String?) {
        guard address.name.isEmpty == false else { return ("Adresa #\(address.id)", nil) }
        guard let range = address.name.range(of: " — ") else { return (address.name, nil) }
        let title = String(address.name[address.name.startIndex..<range.lowerBound])
        let subtitle = String(address.name[range.upperBound...])
        return (title, subtitle.isEmpty ? nil : subtitle)
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title).font(.subheadline.weight(.semibold))
            }
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Componente selectabile (redesign 18.07.2026: inlocuiesc Picker(.inline), care randa
// randuri simple de List — cerinta explicita a userului pt un aspect mai estetic)

/// Card orizontal selectabil, pt liste cu text variabil (adrese: nume + strada/oraș pot fi
/// lungi). Bifa la stanga + evidentiere cu accent color cand e selectat.
private struct SelectableCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.systemGray3))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .multilineTextAlignment(.leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.10) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Tab patrat selectabil, pt optiuni scurte (curier, metoda de plata) — aranjate intr-o grila
/// 2 coloane. Fundal plin cu accent color cand e selectat (in loc de bifa), ca un chip de filtru.
private struct SquareTab: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(isSelected ? .white : .primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? .clear : Color(.separator).opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Formular de adresa noua

/// Formular pt crearea unei adrese (livrare sau facturare), cu aceleasi campuri ca pe site.
/// La salvare, datele sunt trimise catre `/shop/address/submit` prin VM si adaugate in contul
/// clientului in Odoo, exact ca pe uportho.ro. Titlul si secventa (facturare/livrare) sunt dictate
/// de server prin `spec`. Prezentat ca sheet din ambii pasi de adresa (facturare/livrare).
private struct AddressFormView: View {
    let spec: AddressFormSpec
    let isSaving: Bool
    let errorMessage: String?
    let fetchCities: (Int) async -> [CityOption]
    let onSave: (CheckoutAddressDraft) -> Void

    @State private var draft = CheckoutAddressDraft()
    /// Localitatile disponibile pt judetul ales, incarcate din `/shop/state_infos/<id>`.
    /// Instanta impune orase din registru (`city_id`) — vezi `CityOption`.
    @State private var cities: [CityOption] = []
    @State private var isLoadingCities = false

    /// Minimul necesar pt o adresa utilizabila de curier (peste minimul server `name,country_id`).
    /// `cityId` (nu doar textul `city`) e obligatoriu — instanta respinge orase in afara registrului.
    private var isValid: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty
            && !draft.street.trimmingCharacters(in: .whitespaces).isEmpty
            && !draft.zip.trimmingCharacters(in: .whitespaces).isEmpty
            && !draft.phone.trimmingCharacters(in: .whitespaces).isEmpty
            && draft.countyId != nil
            && draft.cityId != nil
    }

    private func countyChanged(to countyId: Int?) {
        draft.countyId = countyId
        cities = []
        draft.cityId = nil
        draft.city = ""
        guard let countyId else { return }
        isLoadingCities = true
        Task {
            let result = await fetchCities(countyId)
            cities = result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            isLoadingCities = false
        }
    }

    private func cityChanged(to cityId: Int?) {
        draft.cityId = cityId
        guard let cityId, let city = cities.first(where: { $0.id == cityId }) else { return }
        draft.city = city.name
        if draft.zip.isEmpty, !city.zip.isEmpty {
            draft.zip = city.zip
        }
    }

    var body: some View {
        Form {
            Section {
                labeledField("Nume complet", text: $draft.name, required: true)
                labeledField("Telefon", text: $draft.phone, required: true, keyboard: .phonePad)
                labeledField("Email", text: $draft.email, keyboard: .emailAddress)
            } header: {
                Text(spec.title)
            } footer: {
                Text("Adresa va fi salvată în contul tău, ca pe site.")
            }

            Section("Companie (opțional)") {
                labeledField("Numele companiei", text: $draft.companyName)
                labeledField("CIF", text: $draft.vat)
            }

            Section {
                labeledField("Stradă și număr", text: $draft.street, required: true)
                labeledField("Detalii (bloc, ap., etc.)", text: $draft.street2)

                Picker("Județ", selection: Binding(
                    get: { draft.countyId },
                    set: { countyChanged(to: $0) }
                )) {
                    Text("Alege județul").tag(Optional<Int>.none)
                    ForEach(RomaniaGeo.countiesSorted) { county in
                        Text(county.name).tag(Optional(county.id))
                    }
                }

                if draft.countyId != nil {
                    if isLoadingCities {
                        HStack {
                            Text("Localitate")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Picker("Localitate", selection: Binding(
                            get: { draft.cityId },
                            set: { cityChanged(to: $0) }
                        )) {
                            Text("Alege localitatea").tag(Optional<Int>.none)
                            ForEach(cities) { city in
                                Text(city.name).tag(Optional(city.id))
                            }
                        }
                    }
                }

                labeledField("Cod poștal", text: $draft.zip, required: true, keyboard: .numbersAndPunctuation)

                HStack {
                    Text("Țară")
                    Spacer()
                    Text("România").foregroundStyle(.secondary)
                }
            } header: {
                Text("Adresă")
            } footer: {
                Text("Alege întâi județul — localitatea se completează din lista oficială.")
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    onSave(draft)
                } label: {
                    HStack {
                        Spacer()
                        if isSaving { ProgressView().tint(.white) }
                        Text(isSaving ? "Se salvează..." : "Salvează adresa")
                            .font(.subheadline.bold())
                        Spacer()
                    }
                }
                .listRowBackground(isValid && !isSaving ? Color.accentColor : Color.gray.opacity(0.4))
                .foregroundStyle(.white)
                .disabled(!isValid || isSaving)
            }
        }
    }

    private func labeledField(
        _ title: String,
        text: Binding<String>,
        required: Bool = false,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                if required { Text("*").font(.caption).foregroundStyle(.red) }
            }
            TextField(title, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled(keyboard == .emailAddress)
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(CartViewModel())
    }
}

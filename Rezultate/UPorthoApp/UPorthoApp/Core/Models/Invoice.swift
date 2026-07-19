import Foundation

enum InvoiceStatus: String, Codable {
    case paid
    case awaitingPayment

    var label: String {
        switch self {
        case .paid: return "Platit"
        case .awaitingPayment: return "Se asteapta plata"
        }
    }
}

struct Invoice: Identifiable, Hashable {
    let id: Int
    let number: String
    let invoiceDate: Date
    let dueDate: Date
    let amountDueRON: Decimal
    let status: InvoiceStatus
}

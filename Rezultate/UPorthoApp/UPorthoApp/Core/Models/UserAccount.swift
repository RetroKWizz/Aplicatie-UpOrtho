import Foundation

struct UserAccount: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    let vatNumber: String?
}

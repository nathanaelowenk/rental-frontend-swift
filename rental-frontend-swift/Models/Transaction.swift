import Foundation

struct TransactionStatus: Codable {
    let message: String
    let orderId: String
    let status: String
}

enum PaymentStatus: String {
    case pending = "pending"
    case settlement = "settlement"
    case canceled = "canceled"
}

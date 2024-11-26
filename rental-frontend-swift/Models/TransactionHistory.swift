import Foundation

struct TransactionHistory: Codable, Identifiable {
    let transactionId: Int
    let itemId: Int
    let itemName: String
    let itemPrice: String
    let rentalStatus: String
    let transactionStatus: String
    let startDate: String
    let endDate: String
    
    var id: Int { transactionId }
    
    var formattedStartDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: startDate) ?? Date()
    }
    
    var formattedEndDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: endDate) ?? Date()
    }
    
    var formattedPrice: String {
        if let price = Double(itemPrice) {
            return "Rp \(Int(price).formattedWithSeparator)"
        }
        return itemPrice
    }
}

struct TransactionHistoryResponse: Codable {
    let message: String
    let transactionHistory: [TransactionHistory]
}

private extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
} 
import Foundation

struct Book: Codable, Identifiable {
    let id: Int
    let title: String
    let category: String
    let description: String
    let price: String
    let minimumRent: Int?
    let status: String
    let lenderId: Int
    let createdAt: String
    let updatedAt: String
    let isRented: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case category
        case description
        case price
        case minimumRent
        case status
        case lenderId
        case createdAt
        case updatedAt
        case isRented
    }
    
    var isAvailable: Bool {
        return status == "available" && !isRented
    }
    
    // These properties are not in the API but needed for the UI
    var author: String { "Lender #\(lenderId)" }
    var coverImage: String { "https://picsum.photos/seed/\(id)/400/600" }
    var previewContent: String { description }
    var fullContent: String { "Full content for \(title)" }
}

struct RentedBook: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let description: String
    let price: String
    let minimumRent: Int
    let status: String
    let lenderId: Int
    let createdAt: String
    let updatedAt: String
    let rentedAt: String
    
    var formattedRentedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: rentedAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return rentedAt
    }
}

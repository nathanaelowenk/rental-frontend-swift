import Foundation

struct Rental: Codable, Identifiable {
    let id: Int
    let bookId: Int
    let userId: Int
    let rentedDate: Date
    let expiryDate: Date
    let isActive: Bool
    
    init(id: Int, bookId: Int, userId: Int, rentedDate: Date, expiryDate: Date, isActive: Bool) {
        self.id = id
        self.bookId = bookId
        self.userId = userId
        self.rentedDate = rentedDate
        self.expiryDate = expiryDate
        self.isActive = isActive
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookId
        case userId
        case rentedDate
        case expiryDate
        case isActive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        bookId = try container.decode(Int.self, forKey: .bookId)
        userId = try container.decode(Int.self, forKey: .userId)
        
        // Decode dates using ISO8601 format
        let dateFormatter = ISO8601DateFormatter()
        
        if let rentedDateString = try container.decodeIfPresent(String.self, forKey: .rentedDate),
           let parsedRentedDate = dateFormatter.date(from: rentedDateString) {
            rentedDate = parsedRentedDate
        } else {
            rentedDate = Date()
        }
        
        if let expiryDateString = try container.decodeIfPresent(String.self, forKey: .expiryDate),
           let parsedExpiryDate = dateFormatter.date(from: expiryDateString) {
            expiryDate = parsedExpiryDate
        } else {
            expiryDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // Default 7 days from now
        }
        
        isActive = try container.decode(Bool.self, forKey: .isActive)
    }
} 
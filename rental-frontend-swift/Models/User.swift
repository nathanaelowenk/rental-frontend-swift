struct User: Codable {
    let id: Int
    let username: String
    let createdAt: String
    let updatedAt: String
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

struct RegisterResponse: Codable {
    let token: String
    let trimmedUser: User
    
    enum CodingKeys: String, CodingKey {
        case token
        case trimmedUser
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
} 
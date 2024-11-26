import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

struct RentalResponse: Codable {
    let message: String
    let orderId: String
    let snapToken: String
    let paymentUrl: String
}


struct BookAccessResponse: Codable {
    let message: String
    let content: String
}


class APIService {
    static let shared = APIService()
    private var baseURL = "http://localhost:3010"
    private var rentBaseURL = "https://35ff-20-2-202-8.ngrok-free.app"
    private var authToken: String?
    
    private init() {}
    
    func setBaseURL(_ url: String) {
        rentBaseURL = url
    }
    
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    private func createRequest(_ path: String, method: String, body: Data? = nil, useRentURL: Bool = false) -> URLRequest? {
        let urlString = useRentURL ? rentBaseURL + path : rentBaseURL + path
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(username: username, password: password)
        let jsonData = try JSONEncoder().encode(loginRequest)
        
        guard let request = createRequest("/auth/login", method: "POST", body: jsonData) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            setAuthToken(loginResponse.token)
            return loginResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func register(username: String, password: String) async throws -> RegisterResponse {
        let registerRequest = RegisterRequest(username: username, password: password)
        let jsonData = try JSONEncoder().encode(registerRequest)
        
        guard let request = createRequest("/auth/signup", method: "POST", body: jsonData) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
            setAuthToken(registerResponse.token)
            return registerResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func fetchBooks() async throws -> [Book] {
        guard let request = createRequest("/items", method: "GET") else {
            throw APIError.invalidURL
        }
        
        print("Fetching books from: \(request.url?.absoluteString ?? "nil")")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("Books response status: \(httpResponse.statusCode)")
        print("Books response data: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        if httpResponse.statusCode == 401 {
            throw APIError.invalidResponse // You might want to handle unauthorized specifically
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func rentBook(bookId: Int, rentLength: Int) async throws -> RentalResponse {
        let rentRequest = ["rentLength": rentLength]
        print("Creating rental request for book \(bookId) with data: \(rentRequest)")
        
        let rentPath = "/rent/item/\(bookId)"
        print("Rent path: \(rentPath)")
        
        guard let request = createRequest(rentPath, method: "POST",
                                        body: try JSONEncoder().encode(rentRequest),
                                        useRentURL: true) else {
            print("Failed to create request URL")
            throw APIError.invalidURL
        }
        
        print("Full rental URL: \(request.url?.absoluteString ?? "nil")")
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            throw APIError.invalidResponse
        }
        
        print("Received response with status code: \(httpResponse.statusCode)")
        print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            print("Invalid status code: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }
        
        do {
            let rentalResponse = try JSONDecoder().decode(RentalResponse.self, from: data)
            print("Successfully decoded rental response: \(rentalResponse)")
            return rentalResponse
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func checkTransactionStatus(orderId: String) async throws -> TransactionStatus {
        guard let request = createRequest("/rent/transaction-status/\(orderId)",
                                        method: "GET",
                                        useRentURL: true) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(TransactionStatus.self, from: data)
    }
    
    func fetchRentedBooks() async throws -> [RentedBook] {
        guard let request = createRequest("/items/rented", method: "GET") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([RentedBook].self, from: data)
    }
    
    func fetchTransactionHistory() async throws -> TransactionHistoryResponse {
        guard let request = createRequest("/rent/history", method: "GET", useRentURL: true) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(TransactionHistoryResponse.self, from: data)
    }
    
    func getBookAccess(bookId: Int) async throws -> BookAccessResponse {
        guard let request = createRequest("/items/\(bookId)/access", method: "GET") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(BookAccessResponse.self, from: data)
    }
}

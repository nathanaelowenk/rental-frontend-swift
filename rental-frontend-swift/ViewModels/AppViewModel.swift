import Foundation

@MainActor
class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var books: [Book] = []
    @Published var rentals: [Rental] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var paymentUrl: String?
    @Published var currentOrderId: String?
    @Published var rentedBooks: [RentedBook] = []
    @Published var transactionHistory: [TransactionHistory] = []
    @Published var isAuthenticated = false
    
    private let apiService = APIService.shared
    private let userDefaultsKey = "currentUser"
    private let tokenKey = "authToken"
    
    init() {
        loadCachedUser()
        setupNotifications()
    }
    
    private func loadCachedUser() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let token = UserDefaults.standard.string(forKey: tokenKey) {
            do {
                let user = try JSONDecoder().decode(User.self, from: userData)
                self.currentUser = user
                self.isAuthenticated = true
                apiService.setAuthToken(token)
            } catch {
                print("Failed to decode cached user: \(error)")
                self.isAuthenticated = false
                clearCache()
            }
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
            clearCache()
        }
    }
    
    private func cacheUser(_ user: User, token: String) {
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
            UserDefaults.standard.set(token, forKey: tokenKey)
        } catch {
            print("Failed to encode user for caching: \(error)")
        }
    }
    
    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    private func setupNotifications() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.scheduleTestNotification()
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loginResponse = try await apiService.login(username: username, password: password)
            currentUser = loginResponse.user
            isAuthenticated = true
            cacheUser(loginResponse.user, token: loginResponse.token)
            try await fetchBooks()
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func register(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let registerResponse = try await apiService.register(username: username, password: password)
            currentUser = registerResponse.trimmedUser
            isAuthenticated = true
            cacheUser(registerResponse.trimmedUser, token: registerResponse.token)
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        clearCache()
        apiService.setAuthToken(nil)
        books = []
        rentals = []
        rentedBooks = []
        transactionHistory = []
        NotificationManager.shared.cancelTestNotifications()
        
        UserDefaults.standard.synchronize()
    }
    
    func fetchBooks() async throws {
        books = try await apiService.fetchBooks()
    }
    
    func rentBook(bookId: Int, rentLength: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("Starting rental process for book \(bookId) with length \(rentLength)")
            let response = try await apiService.rentBook(bookId: bookId, rentLength: rentLength)
            print("Received rental response: \(response)")
            paymentUrl = response.paymentUrl
            currentOrderId = response.orderId
            print("Payment URL set to: \(response.paymentUrl)")
            try await fetchBooks()
        } catch {
            print("Rental error: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchRentedBooks() async {
        isLoading = true
        do {
            rentedBooks = try await apiService.fetchRentedBooks()
            rentals = rentedBooks.map { rentedBook in
                // Convert the date strings to Date objects
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                let rentedDate = formatter.date(from: rentedBook.rentedAt) ?? Date()
                let expiryDate = rentedDate.addingTimeInterval(Double(rentedBook.minimumRent) * 24 * 60 * 60)
                
                return Rental(
                    id: rentedBook.id,
                    bookId: rentedBook.id,
                    userId: currentUser?.id ?? 0,
                    rentedDate: rentedDate,
                    expiryDate: expiryDate,
                    isActive: true
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchTransactionHistory() async {
        isLoading = true
        do {
            let response = try await apiService.fetchTransactionHistory()
            transactionHistory = response.transactionHistory
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func getBookAccess(bookId: Int) async throws -> BookAccessResponse {
        do {
            let response = try await apiService.getBookAccess(bookId: bookId)
            if let url = URL(string: response.content) {
                return response
            } else {
                throw APIError.invalidResponse
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}

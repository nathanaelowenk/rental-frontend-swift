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
    
    private let apiService = APIService.shared
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await apiService.login(username: username, password: password)
            try await fetchBooks()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await apiService.register(username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
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
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
} 

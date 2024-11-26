import Foundation

@MainActor
class BookContentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var bookAccessUrl: URL?
    
    private let apiService = APIService.shared
    
    func getBookAccess(bookId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("\n=== Requesting Book Access ===")
            print("Book ID: \(bookId)")
            let response = try await apiService.getBookAccess(bookId: bookId)
            print("Access response received: \(response)")
            
            if let url = URL(string: response.content) {
                print("Valid URL created: \(url)")
                bookAccessUrl = url
            } else {
                throw APIError.invalidResponse
            }
        } catch {
            print("Error accessing book: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 
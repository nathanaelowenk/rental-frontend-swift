import SwiftUI

struct RentalsView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var searchText = ""
    
    var filteredBooks: [RentedBook] {
        if searchText.isEmpty {
            return viewModel.rentedBooks
        }
        return viewModel.rentedBooks.filter { book in
            book.name.localizedCaseInsensitiveContains(searchText) ||
            book.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.rentedBooks.isEmpty {
                ContentUnavailableView(
                    "No Rentals",
                    systemImage: "book.closed",
                    description: Text("You haven't rented any books yet.")
                )
            } else {
                List(filteredBooks) { rentedBook in
                    let book = Book(
                        id: rentedBook.id,
                        title: rentedBook.name,
                        category: rentedBook.category,
                        description: rentedBook.description,
                        price: rentedBook.price,
                        minimumRent: rentedBook.minimumRent,
                        status: rentedBook.status,
                        lenderId: rentedBook.lenderId,
                        createdAt: rentedBook.createdAt,
                        updatedAt: rentedBook.updatedAt,
                        isRented: true
                    )
                    
                    NavigationLink(destination: BookDetailView(book: book)) {
                        RentalRowView(
                            book: book,
                            rental: Rental(
                                id: rentedBook.id,
                                bookId: rentedBook.id,
                                userId: viewModel.currentUser?.id ?? 0,
                                rentedDate: rentedBook.formattedDate,
                                expiryDate: rentedBook.formattedDate.addingTimeInterval(Double(rentedBook.minimumRent) * 24 * 60 * 60),
                                isActive: true
                            )
                        )
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.fetchRentedBooks()
                }
            }
        }
        .navigationTitle("My Rentals")
        .searchable(text: $searchText, prompt: "Search books...")
        .onAppear {
            Task {
                await viewModel.fetchRentedBooks()
            }
        }
    }
}

private extension RentedBook {
    var formattedDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: rentedAt) ?? Date()
    }
}

#Preview {
    NavigationStack {
        RentalsView()
            .environmentObject({
                let viewModel = AppViewModel()
                viewModel.rentedBooks = [
                    RentedBook(
                        id: 1,
                        name: "Sample Book",
                        category: "Entertainment",
                        description: "Sample description",
                        price: "50000.00",
                        minimumRent: 7,
                        status: "available",
                        lenderId: 1,
                        createdAt: "2024-03-14T05:16:11.000Z",
                        updatedAt: "2024-03-14T05:16:11.000Z",
                        rentedAt: "2024-03-14T05:16:11.000Z"
                    )
                ]
                return viewModel
            }())
    }
}

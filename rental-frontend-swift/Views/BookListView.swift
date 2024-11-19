import SwiftUI

struct BookListView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var searchText = ""
    
    // Updated grid layout with fixed size
    let columns = [
        GridItem(.fixed(UIScreen.main.bounds.width / 2 - 24), spacing: 16),
        GridItem(.fixed(UIScreen.main.bounds.width / 2 - 24), spacing: 16)
    ]
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return viewModel.books
        }
        return viewModel.books.filter { book in
            book.title.localizedCaseInsensitiveContains(searchText) ||
            book.category.localizedCaseInsensitiveContains(searchText) ||
            book.author.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            // Search bar
            if !viewModel.books.isEmpty {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookCardView(book: book)
                            .frame(width: UIScreen.main.bounds.width / 2 - 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            try? await viewModel.fetchBooks()
        }
        .overlay {
            if viewModel.books.isEmpty {
                ContentUnavailableView {
                    Label("No Books Available", systemImage: "books.vertical")
                } description: {
                    Text("Pull to refresh and check again later")
                }
            }
        }
        .navigationTitle("Library")
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search books...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        BookListView()
            .environmentObject({
                let viewModel = AppViewModel()
                viewModel.books = [
                    Book(
                        id: 1,
                        title: "The Design of Everyday Things",
                        category: "Education",
                        description: "A fascinating exploration of the design",
                        price: "50000.00",
                        minimumRent: 7,
                        status: "available",
                        lenderId: 1,
                        createdAt: "2024-03-11T15:30:00Z",
                        updatedAt: "2024-03-11T15:30:00Z",
                        isRented: false
                    ),
                    Book(
                        id: 2,
                        title: "Clean Code",
                        category: "Technology",
                        description: "A handbook of agile software craftsmanship",
                        price: "75000.00",
                        minimumRent: 14,
                        status: "available",
                        lenderId: 2,
                        createdAt: "2024-03-11T15:30:00Z",
                        updatedAt: "2024-03-11T15:30:00Z",
                        isRented: true
                    )
                ]
                return viewModel
            }())
    }
} 

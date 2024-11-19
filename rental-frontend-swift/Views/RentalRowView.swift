import SwiftUI

struct RentalRowView: View {
    let book: Book
    let rental: Rental
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: book.coverImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
            }
            .frame(width: 60, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                
                Text("Due: \(formatDate(rental.expiryDate))")
                    .font(.subheadline)
                    .foregroundColor(rental.isActive ? .primary : .secondary)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    RentalRowView(
        book: Book(
            id: 1,
            title: "Sample Book",
            category: "Education",
            description: "A sample book description",
            price: "50000.00",
            minimumRent: 7,
            status: "available",
            lenderId: 1,
            createdAt: "2024-03-11T15:30:00Z",
            updatedAt: "2024-03-11T15:30:00Z",
            isRented: false
        ),
        rental: Rental(
            id: 1,
            bookId: 1,
            userId: 1,
            rentedDate: Date(),
            expiryDate: Date().addingTimeInterval(7*24*60*60),
            isActive: true
        )
    )
    .padding()
} 

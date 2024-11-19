import SwiftUI

struct BookCardView: View {
    let book: Book
    
    var formattedPrice: String {
        let priceValue = Double(book.price) ?? 0
        return String(format: "%.2f", priceValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Book cover image
            AsyncImage(url: URL(string: book.coverImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.1))
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Book info container
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 44, alignment: .top)
                
                // Author
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Price and availability
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("Rp")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(formattedPrice)
                        .font(.callout)
                        .bold()
                        .foregroundColor(.blue)
                }
                
                // Availability badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(book.isAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(book.isAvailable ? "Available" : "Rented")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

#Preview {
    BookCardView(book: Book(
        id: 1,
        title: "The Design of Everyday Things",
        category: "Education",
        description: "A sample book description that is quite long and detailed",
        price: "50000.00",
        minimumRent: 7,
        status: "available",
        lenderId: 1,
        createdAt: "2024-03-11T15:30:00Z",
        updatedAt: "2024-03-11T15:30:00Z",
        isRented: false
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
} 

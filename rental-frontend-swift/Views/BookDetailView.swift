import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let book: Book
    
    @State private var showingFullContent = false
    @State private var showingRentalConfirmation = false
    @State private var rentLength = 5 // Default rental length
    @State private var showingPaymentSheet = false
    @State private var rentDuration: Int = 0 // Add this state variable
    
    var isRented: Bool {
        viewModel.rentals.contains { rental in
            rental.bookId == book.id && rental.isActive
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book cover
                AsyncImage(url: URL(string: book.coverImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(maxHeight: 300)
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Title and Author
                    Text(book.title)
                        .font(.title)
                        .bold()
                    
                    Text("by \(book.author)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(book.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Preview/Full Content
                    Group {
                        if isRented {
                            Text("Full Content")
                                .font(.headline)
                                .padding(.top)
                            
                            Text(book.fullContent)
                                .font(.body)
                        } else {
                            Text("Preview")
                                .font(.headline)
                                .padding(.top)
                            
                            Text(book.previewContent)
                                .font(.body)
                                .lineLimit(5)
                            
                            if book.previewContent.count > 100 {
                                Button("Read More...") {
                                    showingFullContent = true
                                }
                                .disabled(!book.isAvailable)
                            }
                        }
                    }
                }
                .padding()
                
                // Add this before the rent button
                if book.isAvailable {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rent Duration")
                            .font(.headline)
                        
                        HStack {
                            Button(action: {
                                if rentDuration > book.minimumRent ?? 1 {
                                    rentDuration -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(rentDuration > book.minimumRent ?? 1 ? .blue : .gray)
                            }
                            .disabled(rentDuration <= book.minimumRent ?? 1)
                            
                            Text("\(rentDuration) days")
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                rentDuration += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .font(.title2)
                        
                        if let minRent = book.minimumRent {
                            Text("Minimum rental period: \(minRent) days")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
                
                // Rent button
                if !isRented && book.isAvailable {
                    Button(action: {
                        showingRentalConfirmation = true  // Show confirmation first
                    }) {
                        Text("Rent Book")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(rentDuration < (book.minimumRent ?? 1))
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rent this book?", isPresented: $showingRentalConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Rent") {
                Task {
                    print("\n=== Starting Rental Process ===")
                    print("Book ID: \(book.id)")
                    print("Book Title: \(book.title)")
                    print("Rent Length: \(rentDuration)")  // Use rentDuration instead of rentLength
                    
                    await viewModel.rentBook(bookId: book.id, rentLength: rentDuration)
                    
                    print("\n=== After rentBook call ===")
                    print("Payment URL: \(viewModel.paymentUrl ?? "nil")")
                    print("Error Message: \(viewModel.errorMessage ?? "nil")")
                    
                    if let paymentUrl = viewModel.paymentUrl {
                        if let url = URL(string: paymentUrl) {
                            print("Valid URL created: \(url)")
                            showingPaymentSheet = true
                        } else {
                            print("Failed to create URL from: \(paymentUrl)")
                        }
                    } else {
                        print("No payment URL received")
                    }
                }
            }
        } message: {
            Text("Would you like to rent '\(book.title)' for \(rentDuration) days?")  // Use rentDuration here too
        }
        .sheet(isPresented: $showingPaymentSheet) {
            if let paymentUrl = viewModel.paymentUrl,
               let url = URL(string: paymentUrl) {
                PaymentWebView(url: url, orderId: viewModel.currentOrderId ?? "")
            }
        }
        .sheet(isPresented: $showingFullContent) {
            PreviewContentView(content: book.previewContent)
        }
        // Add this to initialize rentDuration when the view appears
        .onAppear {
            rentDuration = book.minimumRent ?? 1
        }
    }
}

struct PreviewContentView: View {
    @Environment(\.dismiss) private var dismiss
    let content: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .padding()
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 

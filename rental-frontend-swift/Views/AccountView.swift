import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    
    var body: some View {
        List {
            Section("PROFILE") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let user = viewModel.currentUser {
                            Text(user.username)
                                .font(.title2)
                                .bold()
                        }
                        Text("Active Member")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Member since \(formatDate(viewModel.currentUser?.createdAt ?? ""))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            Section("STATISTICS") {
                HStack {
                    Label("Total Rentals", systemImage: "book.closed")
                    Spacer()
                    Text("\(viewModel.rentals.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Active Rentals", systemImage: "book")
                    Spacer()
                    Text("\(viewModel.rentals.filter { $0.isActive }.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("SETTINGS") {
                Button(action: {
                    viewModel.currentUser = nil
                }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Account")
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateString) else { return "Unknown" }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environmentObject({
                let viewModel = AppViewModel()
                viewModel.currentUser = User(
                    id: 1,
                    username: "example@mail.com",
                    createdAt: "2024-03-11T15:30:00Z",
                    updatedAt: "2024-03-11T15:30:00Z"
                )
                viewModel.rentals = [
                    Rental(
                        id: 1,
                        bookId: 1,
                        userId: 1,
                        rentedDate: Date(),
                        expiryDate: Date().addingTimeInterval(7*24*60*60),
                        isActive: true
                    ),
                    Rental(
                        id: 2,
                        bookId: 2,
                        userId: 1,
                        rentedDate: Date().addingTimeInterval(-14*24*60*60),
                        expiryDate: Date().addingTimeInterval(-7*24*60*60),
                        isActive: false
                    )
                ]
                return viewModel
            }())
    }
} 

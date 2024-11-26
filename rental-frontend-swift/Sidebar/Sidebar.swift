import SwiftUI

enum Panel: String {
    case library = "Library"
    case rentals = "My Rentals"
    case history = "History"
    case account = "Account"
    
    var icon: String {
        switch self {
        case .library:
            return "books.vertical"
        case .rentals:
            return "book.closed"
        case .history:
            return "clock.arrow.circlepath"
        case .account:
            return "person.circle"
        }
    }
}

struct Sidebar: View {
    @Binding var selection: Panel?
    @EnvironmentObject private var viewModel: AppViewModel
    
    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: Panel.library) {
                Label("Library", systemImage: "books.vertical")
            }
            
            NavigationLink(value: Panel.rentals) {
                Label("My Rentals", systemImage: "book.closed")
            }
            
            NavigationLink(value: Panel.history) {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            
            NavigationLink(value: Panel.account) {
                Label("Account", systemImage: "person.circle")
            }
            
            Section("Settings") {
                Button(action: {
                    viewModel.signOut()
                }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Book Rental")
    }
}

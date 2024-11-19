import SwiftUI

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
            
            NavigationLink(value: Panel.account) {
                Label("Account", systemImage: "person.circle")
            }
            
            Section("Settings") {
                Button(action: {
                    viewModel.currentUser = nil
                }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Book Rental")
    }
}

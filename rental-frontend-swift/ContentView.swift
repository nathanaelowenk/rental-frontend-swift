//
//  ContentView.swift
//  rental-frontend-swift
//
//  Created by closer on 03/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var selection: Panel? = Panel.library
    @State private var path = NavigationPath()
    
    var body: some View {
        if viewModel.currentUser == nil {
            LoginView()
        } else {
            NavigationSplitView {
                Sidebar(selection: $selection)
            } detail: {
                NavigationStack(path: $path) {
                    DetailColumn(selection: selection)
                }
            }
            .onChange(of: selection) { _ in
                path.removeLast(path.count)
            }
        }
    }
}

struct DetailColumn: View {
    let selection: Panel?
    
    var body: some View {
        if let selection {
            switch selection {
            case .library:
                BookListView()
            case .rentals:
                RentalsView()
            case .account:
                AccountView()
            }
        } else {
            BookListView()
        }
    }
}


#Preview {
    ContentView()
        .environmentObject({
            let viewModel = AppViewModel()
            // Start with no user to show login screen
            viewModel.currentUser = nil
            return viewModel
        }())
}

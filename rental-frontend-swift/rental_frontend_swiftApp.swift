//
//  rental_frontend_swiftApp.swift
//  rental-frontend-swift
//
//  Created by closer on 03/11/24.
//

import SwiftUI
import WebKit

@main
struct rental_frontend_swiftApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    init() {
        _ = WKWebView()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

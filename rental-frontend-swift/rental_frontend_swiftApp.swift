//
//  rental_frontend_swiftApp.swift
//  rental-frontend-swift
//
//  Created by closer on 03/11/24.
//

import SwiftUI
import WebKit
import UserNotifications

@main
struct rental_frontend_swiftApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    init() {
        _ = WKWebView()
        
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

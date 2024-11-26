import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleTestNotification() {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Library Rental System"
        content.body = "Hello, User!"
        content.sound = .default
        
        // Create trigger for every minute
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 180, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully")
            }
        }
    }
    
    func cancelTestNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testNotification"])
    }
} 

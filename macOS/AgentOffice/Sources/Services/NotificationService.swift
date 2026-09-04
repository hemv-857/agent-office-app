// NotificationService.swift
import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {
        requestPermission()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func sendWorkflowComplete(agentCount: Int, resultCount: Int, duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Workflow Complete"
        content.subtitle = "\(agentCount) agents, \(resultCount) results"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func sendAgentResponse(agentName: String, tokenCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Agent Response Ready"
        content.subtitle = "\(agentName) responded with \(tokenCount) tokens"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func sendBudgetAlert(remaining: Double, dailyBudget: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Warning"
        content.subtitle = String(format: "$%.2f remaining of $%.2f daily budget", remaining, dailyBudget)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func sendError(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Error"
        content.subtitle = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

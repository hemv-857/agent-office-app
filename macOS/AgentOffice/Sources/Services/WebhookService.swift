// WebhookService.swift
import Foundation

class WebhookService: ObservableObject {
    static let shared = WebhookService()

    @Published var webhooks: [Webhook] = []
    @Published var webhookLogs: [WebhookLog] = []

    struct Webhook: Identifiable, Codable {
        let id: String
        let name: String
        let url: String
        let events: [WebhookEvent]
        var isActive: Bool
        var secret: String?
        var lastTriggered: Date?
        var failureCount: Int = 0
    }

    enum WebhookEvent: String, Codable, CaseIterable {
        case workflowCompleted = "workflow.completed"
        case workflowFailed = "workflow.failed"
        case agentResponse = "agent.response"
        case budgetAlert = "budget.alert"
        case error = "error"
    }

    struct WebhookLog: Identifiable, Codable {
        let id = UUID()
        let webhookId: String
        let event: WebhookEvent
        let timestamp: Date
        let success: Bool
        let statusCode: Int?
        let errorMessage: String?
    }

    private init() {
        loadWebhooks()
        loadLogs()
    }

    func registerWebhook(_ webhook: Webhook) {
        if !webhooks.contains(where: { $0.id == webhook.id }) {
            webhooks.append(webhook)
            saveWebhooks()
        }
    }

    func unregisterWebhook(id: String) {
        webhooks.removeAll { $0.id == id }
        saveWebhooks()
    }

    func triggerWebhooks(event: WebhookEvent, payload: [String: Any]) {
        let activeWebhooks = webhooks.filter { webhook in
            webhook.isActive && webhook.events.contains(event)
        }

        for webhook in activeWebhooks {
            sendWebhook(webhook: webhook, event: event, payload: payload)
        }
    }

    private func sendWebhook(webhook: Webhook, event: WebhookEvent, payload: [String: Any]) {
        guard let url = URL(string: webhook.url) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "event": event.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "data": payload
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = jsonData
        }

        if let secret = webhook.secret {
            request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                let httpResponse = response as? HTTPURLResponse
                let success = error == nil && (httpResponse?.statusCode ?? 0) >= 200 && (httpResponse?.statusCode ?? 0) < 300

                let log = WebhookLog(
                    webhookId: webhook.id,
                    event: event,
                    timestamp: Date(),
                    success: success,
                    statusCode: httpResponse?.statusCode,
                    errorMessage: error?.localizedDescription
                )

                self?.webhookLogs.append(log)

                // Update webhook failure count
                if !success {
                    if let index = self?.webhooks.firstIndex(where: { $0.id == webhook.id }) {
                        self?.webhooks[index].failureCount += 1
                    }
                }

                self?.saveWebhooks()
                self?.saveLogs()
            }
        }

        task.resume()
    }

    func getWebhookStats(id: String) -> (success: Int, failure: Int, lastTriggered: Date?) {
        let logs = webhookLogs.filter { $0.webhookId == id }
        let success = logs.filter { $0.success }.count
        let failure = logs.filter { !$0.success }.count
        let lastTriggered = logs.max(by: { $0.timestamp < $1.timestamp })?.timestamp
        return (success, failure, lastTriggered)
    }

    func clearLogs() {
        webhookLogs.removeAll()
        saveLogs()
    }

    private func saveWebhooks() {
        if let data = try? JSONEncoder().encode(webhooks) {
            UserDefaults.standard.set(data, forKey: "webhooks")
        }
    }

    private func loadWebhooks() {
        if let data = UserDefaults.standard.data(forKey: "webhooks"),
           let loaded = try? JSONDecoder().decode([Webhook].self, from: data) {
            webhooks = loaded
        }
    }

    private func saveLogs() {
        // Keep only last 100 logs
        if webhookLogs.count > 100 {
            webhookLogs = Array(webhookLogs.suffix(100))
        }
        if let data = try? JSONEncoder().encode(webhookLogs) {
            UserDefaults.standard.set(data, forKey: "webhookLogs")
        }
    }

    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: "webhookLogs"),
           let loaded = try? JSONDecoder().decode([WebhookLog].self, from: data) {
            webhookLogs = loaded
        }
    }
}

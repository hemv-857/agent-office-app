// NotificationBadgeManager.swift
import Foundation
import Combine

class NotificationBadgeManager: ObservableObject {
    static let shared = NotificationBadgeManager()

    @Published var badges: [String: Int] = [:]

    private init() {
        loadBadges()
    }

    func increment(_ key: String) {
        badges[key, default: 0] += 1
        saveBadges()
    }

    func decrement(_ key: String) {
        guard let count = badges[key], count > 0 else { return }
        badges[key] = count - 1
        if badges[key] == 0 {
            badges.removeValue(forKey: key)
        }
        saveBadges()
    }

    func clear(_ key: String) {
        badges.removeValue(forKey: key)
        saveBadges()
    }

    func clearAll() {
        badges.removeAll()
        saveBadges()
    }

    func count(for key: String) -> Int {
        return badges[key] ?? 0
    }

    func hasBadge(for key: String) -> Bool {
        return (badges[key] ?? 0) > 0
    }

    func totalBadges() -> Int {
        return badges.values.reduce(0, +)
    }

    private func saveBadges() {
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: "notificationBadges")
        }
    }

    private func loadBadges() {
        if let data = UserDefaults.standard.data(forKey: "notificationBadges"),
           let loaded = try? JSONDecoder().decode([String: Int].self, from: data) {
            badges = loaded
        }
    }
}

// AgentIdleManager.swift
import Foundation
import Combine

class AgentIdleManager: ObservableObject {
    static let shared = AgentIdleManager()

    @Published var idleTimeout: TimeInterval = 300 // 5 minutes
    @Published var enabled = false

    private var timers: [String: Timer] = [:]
    private var lastActivity: [String: Date] = [:]

    static let agentBecameIdle = Notification.Name("agentBecameIdle")

    private init() {
        loadSettings()
    }

    func startTracking(deskId: String) {
        lastActivity[deskId] = Date()
        guard enabled else { return }

        timers[deskId]?.invalidate()
        timers[deskId] = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkIdle(deskId: deskId)
        }
    }

    func updateActivity(deskId: String) {
        lastActivity[deskId] = Date()
    }

    func stopTracking(deskId: String) {
        timers[deskId]?.invalidate()
        timers.removeValue(forKey: deskId)
        lastActivity.removeValue(forKey: deskId)
    }

    func stopAll() {
        for (deskId, timer) in timers {
            timer.invalidate()
        }
        timers.removeAll()
        lastActivity.removeAll()
    }

    private func checkIdle(deskId: String) {
        guard let lastActive = lastActivity[deskId] else { return }
        let elapsed = Date().timeIntervalSince(lastActive)
        if elapsed >= idleTimeout {
            NotificationCenter.default.post(
                name: Self.agentBecameIdle,
                object: nil,
                userInfo: ["deskId": deskId, "idleTime": elapsed]
            )
        }
    }

    func getIdleTime(for deskId: String) -> TimeInterval {
        guard let lastActive = lastActivity[deskId] else { return 0 }
        return Date().timeIntervalSince(lastActive)
    }

    func saveSettings() {
        UserDefaults.standard.set(idleTimeout, forKey: "agentIdleTimeout")
        UserDefaults.standard.set(enabled, forKey: "agentIdleEnabled")
    }

    private func loadSettings() {
        let savedTimeout = UserDefaults.standard.double(forKey: "agentIdleTimeout")
        if savedTimeout > 0 { idleTimeout = savedTimeout }
        enabled = UserDefaults.standard.bool(forKey: "agentIdleEnabled")
    }
}

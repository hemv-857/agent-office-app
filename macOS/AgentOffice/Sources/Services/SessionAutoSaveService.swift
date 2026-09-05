// SessionAutoSaveService.swift
import Foundation
import Combine

class SessionAutoSaveService: ObservableObject {
    static let shared = SessionAutoSaveService()

    @Published var isEnabled = true
    @Published var interval: TimeInterval = 60 // 1 minute
    @Published var lastSaveTime: Date?

    private var timer: Timer?

    private init() {
        loadSettings()
    }

    func start() {
        guard isEnabled else { return }
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performAutoSave()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func triggerSave() {
        performAutoSave()
    }

    private func performAutoSave() {
        NotificationCenter.default.post(name: .autoSave, object: nil)
        lastSaveTime = Date()
    }

    func saveSettings() {
        UserDefaults.standard.set(isEnabled, forKey: "autoSaveEnabled")
        UserDefaults.standard.set(interval, forKey: "autoSaveInterval")
    }

    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "autoSaveEnabled")
        let savedInterval = UserDefaults.standard.double(forKey: "autoSaveInterval")
        if savedInterval > 0 { interval = savedInterval }
    }
}

extension Notification.Name {
    static let autoSave = Notification.Name("autoSave")
}

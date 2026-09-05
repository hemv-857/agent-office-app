// ClipboardHistoryManager.swift
import AppKit
import Combine

class ClipboardHistoryManager: ObservableObject {
    static let shared = ClipboardHistoryManager()

    @Published var history: [ClipboardEntry] = []
    @Published var isMonitoring = false

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxEntries = 50

    struct ClipboardEntry: Identifiable, Codable {
        let id = UUID()
        let content: String
        let timestamp: Date
        let source: String
    }

    private init() {
        loadHistory()
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        isMonitoring = true
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let content = pasteboard.string(forType: .string),
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let entry = ClipboardEntry(content: content, timestamp: Date(), source: "Clipboard")
        DispatchQueue.main.async {
            self.history.insert(entry, at: 0)
            if self.history.count > self.maxEntries {
                self.history = Array(self.history.prefix(self.maxEntries))
            }
            self.saveHistory()
        }
    }

    func copyToClipboard(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)

        let entry = ClipboardEntry(content: content, timestamp: Date(), source: "App")
        history.insert(entry, at: 0)
        if history.count > maxEntries {
            history = Array(history.prefix(maxEntries))
        }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    func removeEntry(_ entry: ClipboardEntry) {
        history.removeAll { $0.id == entry.id }
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: "clipboardHistory")
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let loaded = try? JSONDecoder().decode([ClipboardEntry].self, from: data) {
            history = loaded
        }
    }
}

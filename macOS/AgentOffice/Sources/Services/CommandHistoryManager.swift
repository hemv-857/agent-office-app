// CommandHistoryManager.swift
import Foundation
import Combine

class CommandHistoryManager: ObservableObject {
    static let shared = CommandHistoryManager()

    @Published var history: [CommandEntry] = []
    @Published var macros: [Macro] = []

    private let maxHistory = 100

    struct CommandEntry: Identifiable, Codable {
        let id = UUID()
        let command: String
        let arguments: [String]
        let timestamp: Date
        let duration: TimeInterval?
        let success: Bool
    }

    struct Macro: Identifiable, Codable {
        let id: UUID
        var name: String
        var commands: [String]
        var createdAt: Date
        var runCount: Int
    }

    private init() {
        loadHistory()
        loadMacros()
    }

    func recordCommand(_ command: String, arguments: [String] = [], duration: TimeInterval? = nil, success: Bool = true) {
        let entry = CommandEntry(command: command, arguments: arguments, timestamp: Date(), duration: duration, success: success)
        history.insert(entry, at: 0)
        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    func getRecentCommands(_ count: Int = 10) -> [String] {
        return Array(history.prefix(count)).map(\.command)
    }

    func getCommandCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for entry in history {
            counts[entry.command, default: 0] += 1
        }
        return counts
    }

    // MARK: - Macros
    func createMacro(name: String, commands: [String]) {
        let macro = Macro(id: UUID(), name: name, commands: commands, createdAt: Date(), runCount: 0)
        macros.append(macro)
        saveMacros()
    }

    func runMacro(_ macro: Macro) {
        if let index = macros.firstIndex(where: { $0.id == macro.id }) {
            macros[index].runCount += 1
            saveMacros()
        }
    }

    func deleteMacro(_ macro: Macro) {
        macros.removeAll { $0.id == macro.id }
        saveMacros()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: "commandHistory")
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "commandHistory"),
           let loaded = try? JSONDecoder().decode([CommandEntry].self, from: data) {
            history = loaded
        }
    }

    private func saveMacros() {
        if let data = try? JSONEncoder().encode(macros) {
            UserDefaults.standard.set(data, forKey: "commandMacros")
        }
    }

    private func loadMacros() {
        if let data = UserDefaults.standard.data(forKey: "commandMacros"),
           let loaded = try? JSONDecoder().decode([Macro].self, from: data) {
            macros = loaded
        }
    }
}

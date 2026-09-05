// DataExportService.swift
import Foundation
import SwiftUI

class DataExportService: ObservableObject {
    static let shared = DataExportService()

    @Published var isExporting = false
    @Published var exportProgress: Double = 0
    @Published var lastExportDate: Date?

    struct ExportData: Codable {
        let version: String
        let exportDate: Date
        let groups: [AgentGroup]
        let presets: [OfficePreset]
        let sessionNotes: [SessionNote]
        let costHistory: [CostEntry]
        let promptHistory: [String]
        let favoriteAgentIds: [String]
        let agentMemory: [String: [AgentMemoryEntry]]
        let chatHistory: [String: [PersistedChatMessage]]
        let workflowHistory: [WorkflowHistoryEntry]
        let analytics: WorkflowAnalyticsService.WorkflowAnalytics
    }

    private init() {
        lastExportDate = UserDefaults.standard.object(forKey: "lastExportDate") as? Date
    }

    func exportAllData() -> Data? {
        isExporting = true
        exportProgress = 0

        let groups: [AgentGroup] = loadArray("agentGroups") ?? []
        let presets: [OfficePreset] = loadArray("workflowPresets") ?? []
        let sessionNotes: [SessionNote] = loadArray("sessionNotes") ?? []
        let costHistory: [CostEntry] = loadArray("costHistory") ?? []
        let promptHistory = UserDefaults.standard.stringArray(forKey: "promptHistory") ?? []
        let favorites = UserDefaults.standard.stringArray(forKey: "favoriteAgents") ?? []
        let agentMemory = loadAgentMemory()
        let chatHistory = loadChatHistory()
        let workflowHistory: [WorkflowHistoryEntry] = loadArray("workflowHistory") ?? []

        exportProgress = 0.5

        let exportData = ExportData(
            version: "1.0.0",
            exportDate: Date(),
            groups: groups,
            presets: presets,
            sessionNotes: sessionNotes,
            costHistory: costHistory,
            promptHistory: promptHistory,
            favoriteAgentIds: favorites,
            agentMemory: agentMemory,
            chatHistory: chatHistory,
            workflowHistory: workflowHistory,
            analytics: WorkflowAnalyticsService.shared.analytics
        )

        exportProgress = 0.8

        guard let data = try? JSONEncoder().encode(exportData) else {
            isExporting = false
            return nil
        }

        exportProgress = 1.0
        lastExportDate = Date()
        UserDefaults.standard.set(lastExportDate, forKey: "lastExportDate")

        isExporting = false
        return data
    }

    func exportToFile() -> URL? {
        guard let data = exportAllData() else { return nil }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "agent-office-export-\(formatDate(Date())).json"

        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            try data.write(to: url)
            return url
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }

    func exportAsJSON() -> String? {
        guard let data = exportAllData() else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func exportGroups() -> Data? {
        let groups: [AgentGroup] = loadArray("agentGroups") ?? []
        return try? JSONEncoder().encode(groups)
    }

    func exportPresets() -> Data? {
        let presets: [OfficePreset] = loadArray("workflowPresets") ?? []
        return try? JSONEncoder().encode(presets)
    }

    func exportPromptHistory() -> Data? {
        let history = UserDefaults.standard.stringArray(forKey: "promptHistory") ?? []
        return try? JSONEncoder().encode(history)
    }

    private func loadArray<T: Decodable>(_ key: String) -> [T]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)
    }

    private func loadAgentMemory() -> [String: [AgentMemoryEntry]] {
        guard let data = UserDefaults.standard.data(forKey: "agentMemory"),
              let memory = try? JSONDecoder().decode([String: [AgentMemoryEntry]].self, from: data) else {
            return [:]
        }
        return memory
    }

    private func loadChatHistory() -> [String: [PersistedChatMessage]] {
        guard let data = UserDefaults.standard.data(forKey: "chatHistory"),
              let history = try? JSONDecoder().decode([String: [PersistedChatMessage]].self, from: data) else {
            return [:]
        }
        return history
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: date)
    }
}

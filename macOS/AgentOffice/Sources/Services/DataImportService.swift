// DataImportService.swift
import Foundation
import SwiftUI

class DataImportService: ObservableObject {
    static let shared = DataImportService()

    @Published var isImporting = false
    @Published var importProgress: Double = 0
    @Published var lastImportDate: Date?

    struct ImportResult {
        let success: Bool
        let message: String
        let importedItems: Int
    }

    private init() {
        lastImportDate = UserDefaults.standard.object(forKey: "lastImportDate") as? Date
    }

    func importData(from data: Data) -> ImportResult {
        isImporting = true
        importProgress = 0

        guard let exportData = try? JSONDecoder().decode(DataExportService.ExportData.self, from: data) else {
            isImporting = false
            return ImportResult(success: false, message: "Invalid export format", importedItems: 0)
        }

        var importedItems = 0

        // Import groups
        if let data = try? JSONEncoder().encode(exportData.groups) {
            UserDefaults.standard.set(data, forKey: "agentGroups")
            importedItems += exportData.groups.count
        }

        importProgress = 0.2

        // Import presets
        if let data = try? JSONEncoder().encode(exportData.presets) {
            UserDefaults.standard.set(data, forKey: "workflowPresets")
            importedItems += exportData.presets.count
        }

        importProgress = 0.4

        // Import session notes
        if let data = try? JSONEncoder().encode(exportData.sessionNotes) {
            UserDefaults.standard.set(data, forKey: "sessionNotes")
            importedItems += exportData.sessionNotes.count
        }

        importProgress = 0.6

        // Import cost history
        if let data = try? JSONEncoder().encode(exportData.costHistory) {
            UserDefaults.standard.set(data, forKey: "costHistory")
            importedItems += exportData.costHistory.count
        }

        // Import prompt history
        UserDefaults.standard.set(exportData.promptHistory, forKey: "promptHistory")
        importedItems += exportData.promptHistory.count

        // Import favorites
        UserDefaults.standard.set(Array(exportData.favoriteAgentIds), forKey: "favoriteAgents")
        importedItems += exportData.favoriteAgentIds.count

        importProgress = 0.8

        // Import agent memory
        if let data = try? JSONEncoder().encode(exportData.agentMemory) {
            UserDefaults.standard.set(data, forKey: "agentMemory")
            importedItems += exportData.agentMemory.values.flatMap { $0 }.count
        }

        // Import chat history
        if let data = try? JSONEncoder().encode(exportData.chatHistory) {
            UserDefaults.standard.set(data, forKey: "chatHistory")
            importedItems += exportData.chatHistory.values.flatMap { $0 }.count
        }

        // Import workflow history
        if let data = try? JSONEncoder().encode(exportData.workflowHistory) {
            UserDefaults.standard.set(data, forKey: "workflowHistory")
            importedItems += exportData.workflowHistory.count
        }

        // Import analytics
        WorkflowAnalyticsService.shared.importAnalytics(
            try! JSONEncoder().encode(exportData.analytics)
        )

        importProgress = 1.0
        lastImportDate = Date()
        UserDefaults.standard.set(lastImportDate, forKey: "lastImportDate")

        isImporting = false
        return ImportResult(
            success: true,
            message: "Imported \(importedItems) items from \(exportData.exportDate.formatted())",
            importedItems: importedItems
        )
    }

    func importFromFile() -> ImportResult {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else {
            return ImportResult(success: false, message: "No file selected", importedItems: 0)
        }

        do {
            let data = try Data(contentsOf: url)
            return importData(from: data)
        } catch {
            return ImportResult(success: false, message: "Failed to read file: \(error.localizedDescription)", importedItems: 0)
        }
    }

    func importFromJSON(_ jsonString: String) -> ImportResult {
        guard let data = jsonString.data(using: .utf8) else {
            return ImportResult(success: false, message: "Invalid JSON string", importedItems: 0)
        }
        return importData(from: data)
    }

    func previewImport(from data: Data) -> (items: Int, date: String)? {
        guard let exportData = try? JSONDecoder().decode(DataExportService.ExportData.self, from: data) else {
            return nil
        }

        let totalItems = exportData.groups.count +
                         exportData.presets.count +
                         exportData.sessionNotes.count +
                         exportData.costHistory.count +
                         exportData.promptHistory.count +
                         exportData.favoriteAgentIds.count

        return (totalItems, exportData.exportDate.formatted())
    }
}

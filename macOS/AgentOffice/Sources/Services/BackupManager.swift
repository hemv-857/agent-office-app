// BackupManager.swift
import Foundation
import SwiftUI

class BackupManager: ObservableObject {
    static let shared = BackupManager()

    @Published var backups: [Backup] = []
    @Published var autoBackupEnabled = false
    @Published var maxBackups = 10

    struct Backup: Identifiable, Codable {
        let id = UUID()
        let name: String
        let date: Date
        let size: Int64
        let items: Int
        let path: String?
    }

    private init() {
        loadBackups()
        autoBackupEnabled = UserDefaults.standard.bool(forKey: "autoBackupEnabled")
        maxBackups = UserDefaults.standard.integer(forKey: "maxBackups") > 0 ? UserDefaults.standard.integer(forKey: "maxBackups") : 10
    }

    func createBackup(name: String? = nil) -> Backup? {
        guard let data = DataExportService.shared.exportAllData() else { return nil }

        let backupName = name ?? "Backup \(formatDate(Date()))"
        let backup = Backup(
            name: backupName,
            date: Date(),
            size: Int64(data.count),
            items: countItems(in: data),
            path: nil
        )

        backups.append(backup)
        saveBackupData(data, backup: backup)
        maintainBackupLimit()
        saveBackups()

        return backup
    }

    func restoreBackup(_ backup: Backup) -> Bool {
        guard let data = loadBackupData(backup: backup) else { return false }
        let result = DataImportService.shared.importData(from: data)
        return result.success
    }

    func deleteBackup(_ backup: Backup) {
        backups.removeAll { $0.id == backup.id }
        deleteBackupData(backup: backup)
        saveBackups()
    }

    func exportBackup(_ backup: Backup) -> URL? {
        guard let data = loadBackupData(backup: backup) else { return nil }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(backup.name).json"

        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            try data.write(to: url)
            return url
        } catch {
            print("Export backup error: \(error)")
            return nil
        }
    }

    func enableAutoBackup(_ enabled: Bool) {
        autoBackupEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "autoBackupEnabled")
    }

    func setMaxBackups(_ limit: Int) {
        maxBackups = limit
        UserDefaults.standard.set(limit, forKey: "maxBackups")
        maintainBackupLimit()
        saveBackups()
    }

    func getBackupSize() -> Int64 {
        return backups.reduce(0) { $0 + $1.size }
    }

    func getBackupStats() -> (count: Int, totalSize: Int64, oldest: Date?, newest: Date?) {
        let oldest = backups.min(by: { $0.date < $1.date })?.date
        let newest = backups.max(by: { $0.date < $1.date })?.date
        return (backups.count, getBackupSize(), oldest, newest)
    }

    private func maintainBackupLimit() {
        if backups.count > maxBackups {
            let sortedBackups = backups.sorted { $0.date < $1.date }
            let toRemove = Array(sortedBackups.prefix(backups.count - maxBackups))
            for backup in toRemove {
                deleteBackupData(backup: backup)
            }
            backups = Array(backups.dropFirst(toRemove.count))
        }
    }

    private func saveBackupData(_ data: Data, backup: Backup) {
        let filename = "\(backup.id.uuidString).json"
        let url = getBackupDirectory().appendingPathComponent(filename)

        do {
            try data.write(to: url)
        } catch {
            print("Save backup error: \(error)")
        }
    }

    private func loadBackupData(backup: Backup) -> Data? {
        let filename = "\(backup.id.uuidString).json"
        let url = getBackupDirectory().appendingPathComponent(filename)

        return try? Data(contentsOf: url)
    }

    private func deleteBackupData(backup: Backup) {
        let filename = "\(backup.id.uuidString).json"
        let url = getBackupDirectory().appendingPathComponent(filename)

        try? FileManager.default.removeItem(at: url)
    }

    private func getBackupDirectory() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let backupDir = appSupport.appendingPathComponent("AgentOffice/Backups")

        if !FileManager.default.fileExists(atPath: backupDir.path) {
            try? FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
        }

        return backupDir
    }

    private func countItems(in data: Data) -> Int {
        guard let exportData = try? JSONDecoder().decode(DataExportService.ExportData.self, from: data) else {
            return 0
        }

        return exportData.groups.count +
               exportData.presets.count +
               exportData.sessionNotes.count +
               exportData.costHistory.count +
               exportData.promptHistory.count +
               exportData.favoriteAgentIds.count
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: date)
    }

    private func saveBackups() {
        if let data = try? JSONEncoder().encode(backups) {
            UserDefaults.standard.set(data, forKey: "backups")
        }
    }

    private func loadBackups() {
        if let data = UserDefaults.standard.data(forKey: "backups"),
           let loadedBackups = try? JSONDecoder().decode([Backup].self, from: data) {
            backups = loadedBackups
        }
    }
}

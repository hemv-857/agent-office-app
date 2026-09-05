// StorageView.swift
import SwiftUI

struct StorageView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var storageInfo: StorageInfo = StorageInfo()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Storage").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Storage overview
                    VStack(spacing: 8) {
                        HStack {
                            Text("Used Space").font(.system(size: 11, weight: .semibold))
                            Spacer()
                            Text(formatBytes(storageInfo.totalBytes))
                                .font(.system(size: 11, design: .monospaced))
                        }
                        ProgressView(value: storageInfo.usagePercent)
                            .tint(usageColor)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Category breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Breakdown").font(.system(size: 11, weight: .semibold))
                        StorageRow(label: "Chat History", bytes: storageInfo.chatHistoryBytes, icon: "bubble.left")
                        StorageRow(label: "Session Notes", bytes: storageInfo.notesBytes, icon: "note.text")
                        StorageRow(label: "Agent Memory", bytes: storageInfo.memoryBytes, icon: "brain")
                        StorageRow(label: "Cost History", bytes: storageInfo.costBytes, icon: "dollarsign.circle")
                        StorageRow(label: "Groups & Presets", bytes: storageInfo.groupsBytes, icon: "folder")
                        StorageRow(label: "Workflow History", bytes: storageInfo.workflowBytes, icon: "arrow.triangle.2.circlepath")
                        StorageRow(label: "Other", bytes: storageInfo.otherBytes, icon: "square.grid.2x2")
                    }

                    // Actions
                    VStack(spacing: 8) {
                        Button("Clear Chat History") {
                            clearCategory("chatHistory")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button("Clear All Data") {
                            clearAll()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .foregroundStyle(.red)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 450)
        .onAppear {
            calculateStorage()
        }
    }

    var usageColor: Color {
        if storageInfo.usagePercent < 0.5 { return .green }
        if storageInfo.usagePercent < 0.8 { return .yellow }
        return .red
    }

    func formatBytes(_ bytes: Int) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
        return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
    }

    func calculateStorage() {
        let defaults = UserDefaults.standard
        storageInfo.chatHistoryBytes = dataSize(forKey: "chatHistory")
        storageInfo.notesBytes = dataSize(forKey: "sessionNotes")
        storageInfo.memoryBytes = dataSize(forKey: "agentMemory")
        storageInfo.costBytes = dataSize(forKey: "costHistory")
        storageInfo.groupsBytes = dataSize(forKey: "agentGroups") + dataSize(forKey: "officePresets")
        storageInfo.workflowBytes = dataSize(forKey: "workflowHistory")
        storageInfo.totalBytes = defaults.dictionaryRepresentation().values.compactMap { $0 as? Data }.reduce(0) { $0 + $1.count }
        storageInfo.usagePercent = min(1.0, Double(storageInfo.totalBytes) / (10 * 1024 * 1024))
    }

    func dataSize(forKey key: String) -> Int {
        guard let data = UserDefaults.standard.data(forKey: key) else { return 0 }
        return data.count
    }

    func clearCategory(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        calculateStorage()
    }

    func clearAll() {
        let keys = ["chatHistory", "sessionNotes", "agentMemory", "costHistory", "agentGroups", "officePresets", "workflowHistory", "tipsDismissed"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        calculateStorage()
    }
}

// MARK: - Storage Row
struct StorageRow: View {
    let label: String
    let bytes: Int
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 11))
            Spacer()
            Text(formatBytes(bytes))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    func formatBytes(_ bytes: Int) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
        return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
    }
}

// MARK: - Storage Info
struct StorageInfo {
    var totalBytes: Int = 0
    var chatHistoryBytes: Int = 0
    var notesBytes: Int = 0
    var memoryBytes: Int = 0
    var costBytes: Int = 0
    var groupsBytes: Int = 0
    var workflowBytes: Int = 0
    var otherBytes: Int = 0
    var usagePercent: Double = 0
}

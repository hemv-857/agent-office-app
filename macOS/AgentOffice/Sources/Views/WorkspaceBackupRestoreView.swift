// WorkspaceBackupRestoreView.swift
import SwiftUI

struct WorkspaceBackupRestoreView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = "backups"
    @State private var backups: [(String, String, String)] = [
        ("backup-2026-09-06-1430.json", "Sept 6, 2:30 PM", "12.4 KB"),
        ("backup-2026-09-05-0900.json", "Sept 5, 9:00 AM", "11.8 KB"),
        ("backup-2026-09-04-1800.json", "Sept 4, 6:00 PM", "10.2 KB"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Backup & Restore").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            Picker("", selection: $selectedTab) {
                Text("Backups").tag("backups")
                Text("Restore").tag("restore")
                Text("Settings").tag("settings")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if selectedTab == "backups" {
                backupsTab
            } else if selectedTab == "restore" {
                restoreTab
            } else {
                settingsTab
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 480)
    }

    private var backupsTab: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Create backup
                Button(action: {
                    createBackup()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Create Backup Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                // Existing backups
                ForEach(backups.indices, id: \.self) { index in
                    WorkspaceBackupRow(
                        filename: backups[index].0,
                        date: backups[index].1,
                        size: backups[index].2,
                        onRestore: { restoreBackup(backups[index].0) },
                        onDelete: { deleteBackup(at: index) }
                    )
                }
            }
            .padding()
        }
    }

    private var restoreTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text("Restore from Backup")
                .font(.headline)

            Text("Select a backup from the Backups tab to restore your workspace state.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Choose Backup File...") {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.json]
                panel.begin { result in
                    if result == .OK, let url = panel.url {
                        restoreFromFile(url)
                    }
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var settingsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox("Auto-Backup") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Enable auto-backup", isOn: .constant(true))
                    Picker("Frequency", selection: .constant("daily")) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                    }
                    .pickerStyle(.segmented)
                    Text("Backups are saved to ~/Documents/AgentOffice/Backups/")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(8)
            }

            GroupBox("Data Included") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Agent groups", isOn: .constant(true))
                    Toggle("Office presets", isOn: .constant(true))
                    Toggle("Cost history", isOn: .constant(true))
                    Toggle("Session notes", isOn: .constant(true))
                    Toggle("Chat history", isOn: .constant(true))
                    Toggle("Agent memory", isOn: .constant(true))
                }
                .padding(8)
            }
        }
        .padding()
    }

    private func createBackup() {
        let data: [String: Any] = [
            "groups": store.groups,
            "presets": store.presets,
            "sessionNotes": store.sessionNotes,
            "costHistory": store.costHistory,
            "agentMemory": store.agentMemory,
            "chatMessages": store.chatMessages.mapValues { $0.map { ["role": "\($0.role)", "content": $0.content] } },
            "timestamp": Date().timeIntervalSince1970,
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HHmm"
            let filename = "backup-\(formatter.string(from: Date())).json"
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = filename
            panel.begin { result in
                if result == .OK, let url = panel.url {
                    try? jsonData.write(to: url)
                    backups.insert((filename, Date().formatted(date: .abbreviated, time: .shortened), "\(jsonData.count / 1024) KB"), at: 0)
                    store.showToast("Backup created: \(filename)", type: .success)
                }
            }
        }
    }

    private func restoreBackup(_ filename: String) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.begin { result in
            if result == .OK, let url = panel.url {
                restoreFromFile(url)
            }
        }
    }

    private func restoreFromFile(_ url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let groups = json["groups"] as? [AgentGroup] { store.groups = groups }
            if let presets = json["presets"] as? [OfficePreset] { store.presets = presets }
            store.persist()
            store.showToast("Workspace restored from backup", type: .success)
            dismiss()
        }
    }

    private func deleteBackup(at index: Int) {
        let name = backups[index].0
        backups.remove(at: index)
        store.showToast("Deleted \(name)", type: .info)
    }
}

// MARK: - Workspace Backup Row
struct WorkspaceBackupRow: View {
    let filename: String
    let date: String
    let size: String
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.fill")
                .foregroundStyle(.blue)
                .font(.system(size: 16))
            VStack(alignment: .leading, spacing: 2) {
                Text(filename)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(date)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text(size)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(action: onRestore) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("Restore")
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .help("Delete")
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

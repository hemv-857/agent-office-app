// BackupListView.swift
import SwiftUI

struct BackupListView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var backups: [BackupManager.Backup] = []
    @State private var showingCreateBackup = false
    @State private var backupName = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Backups").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Backup stats
            let stats = BackupManager.shared.getBackupStats()
            HStack(spacing: 20) {
                BackupStatCard(title: "Backups", value: "\(stats.count)", icon: "archivebox")
                BackupStatCard(title: "Total Size", value: ByteCountFormatter.string(fromByteCount: stats.totalSize, countStyle: .file), icon: "internaldrive")
                if let oldest = stats.oldest {
                    BackupStatCard(title: "Oldest", value: oldest.formatted(.relative(presentation: .named)), icon: "calendar")
                }
            }
            .padding()

            Divider()

            // Backup list
            if backups.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "archivebox").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No backups yet").foregroundStyle(.secondary)
                    Text("Create a backup to protect your data")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(backups) { backup in
                        BackupRow(backup: backup) {
                            restoreBackup(backup)
                        } onDelete: {
                            deleteBackup(backup)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Create Backup") { showingCreateBackup = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 400)
        .alert("Create Backup", isPresented: $showingCreateBackup) {
            TextField("Backup name", text: $backupName)
            Button("Create") {
                createBackup()
                backupName = ""
            }
            Button("Cancel", role: .cancel) { backupName = "" }
        }
        .onAppear {
            backups = BackupManager.shared.backups
        }
    }

    func createBackup() {
        let name = backupName.isEmpty ? nil : backupName
        if let _ = BackupManager.shared.createBackup(name: name) {
            backups = BackupManager.shared.backups
            store.showToast("Backup created", type: .success)
        }
    }

    func restoreBackup(_ backup: BackupManager.Backup) {
        if BackupManager.shared.restoreBackup(backup) {
            store.showToast("Backup restored", type: .success)
        }
    }

    func deleteBackup(_ backup: BackupManager.Backup) {
        BackupManager.shared.deleteBackup(backup)
        backups = BackupManager.shared.backups
    }
}

// MARK: - Backup Row
struct BackupRow: View {
    let backup: BackupManager.Backup
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(backup.name).font(.system(size: 12, weight: .medium))
                HStack(spacing: 8) {
                    Text(backup.date.formatted())
                    Text(ByteCountFormatter.string(fromByteCount: backup.size, countStyle: .file))
                    Text("\(backup.items) items")
                }
                .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onRestore) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Restore")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Delete")
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Backup Stat Card
struct BackupStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.blue)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

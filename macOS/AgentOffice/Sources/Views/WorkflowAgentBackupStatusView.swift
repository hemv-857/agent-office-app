// WorkflowAgentBackupStatusView.swift
import SwiftUI

struct WorkflowAgentBackupStatusView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let backups: [(String, String, String, Bool)] = [
        ("Full Backup", "Sep 6, 09:00 AM", "2.4 MB", true),
        ("Incremental", "Sep 5, 11:30 PM", "180 KB", true),
        ("Incremental", "Sep 5, 11:00 AM", "142 KB", true),
        ("Full Backup", "Sep 4, 09:00 AM", "2.3 MB", true),
        ("Incremental", "Sep 3, 11:30 PM", "96 KB", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Backup Status").font(.headline)
                Spacer()
                Text("\(backups.count) backups")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Status
            HStack(spacing: 16) {
                BackupStatusStat(label: "Last Backup", value: "Today", color: .green)
                BackupStatusStat(label: "Total Size", value: "5.1 MB", color: .blue)
                BackupStatusStat(label: "Auto-backup", value: "On", color: .purple)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            List {
                ForEach(backups.indices, id: \.self) { i in
                    BackupStatusRow(
                        type: backups[i].0,
                        date: backups[i].1,
                        size: backups[i].2,
                        success: backups[i].3
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Backup Now") {
                    store.showToast("Backup started", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

// MARK: - Backup Status Stat
struct BackupStatusStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Backup Status Row
struct BackupStatusRow: View {
    let type: String
    let date: String
    let size: String
    let success: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(success ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.system(size: 11, weight: .semibold))
                Text(date)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(size)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

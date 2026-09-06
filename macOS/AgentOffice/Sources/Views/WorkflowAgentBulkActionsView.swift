// WorkflowAgentBulkActionsView.swift
import SwiftUI

struct WorkflowAgentBulkActionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let actions: [(String, String, String, Color, Bool)] = [
        ("Restart All Agents", "Restart all active agents", "restart", .blue, true),
        ("Clear All Caches", "Clear all cached responses and data", "trash", .orange, true),
        ("Export All Data", "Export complete workspace data", "square.and.arrow.up", .green, true),
        ("Backup Workspace", "Create full workspace backup", "externaldrive", .purple, true),
        ("Sync with Cloud", "Synchronize with cloud storage", "icloud.and.arrow.up", .cyan, false),
        ("Run Health Check", "Perform system health check", "heart.text.square", .red, true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bulk Actions").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(actions.indices, id: \.self) { i in
                        BulkActionRow(
                            title: actions[i].0,
                            description: actions[i].1,
                            icon: actions[i].2,
                            color: actions[i].3,
                            available: actions[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 460, height: 440)
    }
}

// MARK: - Bulk Action Row
struct BulkActionRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let available: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(available ? color : .secondary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(available ? .primary : .secondary)
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if available {
                Button("Run") { }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            } else {
                Text("Coming Soon")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(available ? Color(nsColor: .controlBackgroundColor) : Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
        .opacity(available ? 1.0 : 0.6)
    }
}
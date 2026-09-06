// WorkflowAuditLogView.swift
import SwiftUI

struct WorkflowAuditLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var filterAction = "all"
    @State private var searchText = ""

    private let actions: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-30), "Agent Seated", "Architect → System Design", "person.fill", Color.blue),
        (Date().addingTimeInterval(-120), "Prompt Sent", "Analyze codebase architecture", "paperplane.fill", Color.green),
        (Date().addingTimeInterval(-180), "API Call", "Anthropic Claude — 1,204 tokens", "bolt.fill", Color.orange),
        (Date().addingTimeInterval(-300), "Cost Logged", "$0.018 added", "dollarsign.circle", Color.purple),
        (Date().addingTimeInterval(-420), "Agent Removed", "Builder removed from desk", "person.fill.xmark", Color.red),
        (Date().addingTimeInterval(-600), "Settings Changed", "Theme → Dark", "gearshape", Color.secondary),
        (Date().addingTimeInterval(-780), "Export Started", "JSON export initiated", "square.and.arrow.up", Color.blue),
        (Date().addingTimeInterval(-900), "Backup Created", "Auto-backup completed", "arrow.clockwise", Color.green),
        (Date().addingTimeInterval(-1200), "Session Started", "Parallel workflow mode", "play.circle.fill", Color.green),
        (Date().addingTimeInterval(-1500), "Group Saved", "Engineering team group", "folder.fill", Color.orange),
    ]

    private let actionTypes = ["all", "agent", "api", "cost", "settings", "export"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Audit Log").font(.headline)
                Spacer()
                Text("\(filteredActions.count) entries")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filters
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search log...", text: $searchText).textFieldStyle(.plain)
                }
                .padding(7)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

                Menu {
                    Button("All") { filterAction = "all" }
                    Divider()
                    Button("Agent") { filterAction = "agent" }
                    Button("API") { filterAction = "api" }
                    Button("Cost") { filterAction = "cost" }
                    Button("Settings") { filterAction = "settings" }
                    Button("Export") { filterAction = "export" }
                } label: {
                    Text(filterAction.capitalized)
                        .font(.system(size: 10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Log entries
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(filteredActions.indices, id: \.self) { index in
                        AuditLogRow(
                            date: actions[index].0,
                            action: actions[index].1,
                            detail: actions[index].2,
                            icon: actions[index].3,
                            color: actions[index].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Clear Log") {
                    store.showToast("Audit log cleared", type: .info)
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.red)
                Spacer()
                Button("Export...") {
                    exportLog()
                }
                .buttonStyle(.bordered)
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }

    private var filteredActions: [(Date, String, String, String, Color)] {
        var result = actions

        if filterAction != "all" {
            result = result.filter { $0.1.lowercased().contains(filterAction) }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.1.localizedCaseInsensitiveContains(searchText) ||
                $0.2.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    private func exportLog() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "audit-log.csv"
        panel.begin { result in
            if result == .OK, let url = panel.url {
                var csv = "Timestamp,Action,Detail\n"
                for entry in actions {
                    csv += "\(entry.0.ISO8601Format()),\(entry.1),\(entry.2)\n"
                }
                try? csv.write(to: url, atomically: true, encoding: .utf8)
                store.showToast("Audit log exported", type: .success)
            }
        }
    }
}

// MARK: - Audit Log Row
struct AuditLogRow: View {
    let date: Date
    let action: String
    let detail: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(action)
                    .font(.system(size: 11, weight: .medium))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(date, style: .time)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

// QuickActionsView.swift
import SwiftUI

struct QuickActionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filteredActions: [QuickAction] {
        if searchText.isEmpty { return QuickAction.allActions }
        return QuickAction.allActions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Actions").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").font(.system(size: 10)).foregroundStyle(.secondary)
                TextField("Search actions...", text: $searchText).textFieldStyle(.plain)
            }
            .padding(6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            Divider()

            // Actions list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredActions) { action in
                        QuickActionRow(action: action) {
                            executeAction(action)
                            dismiss()
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 400, height: 450)
    }

    func executeAction(_ action: QuickAction) {
        switch action.id {
        case "new-workflow":
            store.promptText = ""
            store.workflowMode = .parallel
        case "clear-office":
            store.clearOffice()
        case "export-results":
            store.showExport = true
        case "view-metrics":
            store.showAgentMetrics = true
        case "view-history":
            store.showWorkflowHistory = true
        case "create-agent":
            store.showCustomAgent = true
        case "save-group":
            store.showGroupSave = true
        case "save-preset":
            store.showPresetSave = true
        case "settings":
            store.showSettings = true
        case "help":
            store.showHelp = true
        default:
            break
        }
    }
}

// MARK: - Quick Action
struct QuickAction: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color

    static let allActions: [QuickAction] = [
        QuickAction(id: "new-workflow", name: "New Workflow", description: "Start a fresh workflow", icon: "plus.circle", color: .blue),
        QuickAction(id: "clear-office", name: "Clear Office", description: "Remove all agents from desks", icon: "trash", color: .red),
        QuickAction(id: "export-results", name: "Export Results", description: "Export current results", icon: "square.and.arrow.up", color: .green),
        QuickAction(id: "view-metrics", name: "View Metrics", description: "Agent performance metrics", icon: "chart.bar", color: .purple),
        QuickAction(id: "view-history", name: "View History", description: "Workflow execution history", icon: "clock", color: .orange),
        QuickAction(id: "create-agent", name: "Create Agent", description: "Create a custom agent", icon: "person.badge.plus", color: .cyan),
        QuickAction(id: "save-group", name: "Save Group", description: "Save current desk layout", icon: "folder.badge.plus", color: .yellow),
        QuickAction(id: "save-preset", name: "Save Preset", description: "Save workflow preset", icon: "bookmark.badge.plus", color: .pink),
        QuickAction(id: "settings", name: "Settings", description: "App settings", icon: "gearshape", color: .gray),
        QuickAction(id: "help", name: "Help", description: "Keyboard shortcuts & about", icon: "questionmark.circle", color: .teal),
    ]
}

// MARK: - Quick Action Row
struct QuickActionRow: View {
    let action: QuickAction
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: action.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(action.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(action.name)
                        .font(.system(size: 12, weight: .medium))
                    Text(action.description)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

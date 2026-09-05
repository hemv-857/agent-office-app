// WorkspaceQuickSwitchView.swift
import SwiftUI

struct WorkspaceQuickSwitchView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""

    private var workspaces: [(String, String, Int, String)] {
        [
            ("Default Office", "Standard workspace", store.desks.filter { $0.isOccupied }.count, "square.grid.2x2"),
            ("Dev Mode", "Development focused", 4, "chevron.left.forwardslash.chevron.right"),
            ("Review Mode", "Code review workspace", 3, "checkmark.magnifyingglass"),
            ("Planning", "Project planning layout", 2, "list.bullet"),
            ("Analytics", "Data analysis workspace", 5, "chart.bar.fill"),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Switch").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search workspaces...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

            // Workspace list
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredWorkspaces, id: \.0) { ws in
                        WorkspaceRow(
                            name: ws.0,
                            description: ws.1,
                            agentCount: ws.2,
                            icon: ws.3
                        )
                        .onTapGesture {
                            store.showToast("Switched to '\(ws.0)'", type: .success)
                            dismiss()
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("+ New Workspace") {
                    store.showToast("New workspace created", type: .success)
                    dismiss()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 420)
    }

    private var filteredWorkspaces: [(String, String, Int, String)] {
        guard !searchText.isEmpty else { return workspaces }
        return workspaces.filter {
            $0.0.localizedCaseInsensitiveContains(searchText) ||
            $0.1.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Workspace Row
struct WorkspaceRow: View {
    let name: String
    let description: String
    let agentCount: Int
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(agentCount) agents")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

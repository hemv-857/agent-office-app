// WorkflowHistoryView.swift
import SwiftUI

struct WorkflowHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedFilter = "all"

    var filteredHistory: [WorkflowHistoryEntry] {
        var entries = store.workflowHistory

        if !searchText.isEmpty {
            entries = entries.filter {
                $0.prompt.localizedCaseInsensitiveContains(searchText) ||
                $0.mode.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        if selectedFilter != "all" {
            entries = entries.filter { $0.mode.rawValue == selectedFilter }
        }

        return entries.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow History").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search and filter
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search history...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(6)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

                Picker("", selection: $selectedFilter) {
                    Text("All").tag("all")
                    ForEach(WorkflowMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue.capitalized).tag(mode.rawValue)
                    }
                }
                .frame(width: 140)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // History list
            if filteredHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No workflow history").foregroundStyle(.secondary)
                    Text("Run a workflow to see it here")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredHistory) { entry in
                        WorkflowHistoryRow(entry: entry)
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Text("\(filteredHistory.count) entries")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Clear History") {
                    store.workflowHistory = []
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
    }
}

// MARK: - Workflow History Entry
struct WorkflowHistoryEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let prompt: String
    let mode: WorkflowMode
    let agents: [String]
    let resultCount: Int
    let totalTokens: Int
    let totalCost: Double
    let duration: TimeInterval
}

// MARK: - Workflow History Row
struct WorkflowHistoryRow: View {
    let entry: WorkflowHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.mode.rawValue.capitalized)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15), in: Capsule())

                Spacer()

                Text(entry.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(entry.prompt)
                .font(.system(size: 12))
                .lineLimit(2)

            HStack(spacing: 12) {
                Label("\(entry.agents.count) agents", systemImage: "person.3")
                Label("\(entry.resultCount) results", systemImage: "list.bullet")
                Label("\(entry.totalTokens) tokens", systemImage: "text.alignleft")
                Label(String(format: "$%.4f", entry.totalCost), systemImage: "dollarsign.circle")
            }
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

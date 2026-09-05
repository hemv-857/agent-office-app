// WorkflowAgentDirectoryView.swift
import SwiftUI

struct WorkflowAgentDirectoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var filteredAgents: [Agent] {
        searchText.isEmpty ? store.allAgents : store.allAgents.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.division.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Directory").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search agents...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal)

            Divider()

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(filteredAgents) { agent in
                        AgentDirectoryRow(agent: agent)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(filteredAgents.count) agents")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 500)
    }
}

// MARK: - Agent Directory Row
struct AgentDirectoryRow: View {
    let agent: Agent

    var body: some View {
        HStack(spacing: 10) {
            Text(agent.emoji).font(.system(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name)
                    .font(.system(size: 12, weight: .medium))
                Text(agent.division)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(agent.officeRole)
                    .font(.system(size: 9))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
            }
            Spacer()
            if !agent.domain.isEmpty {
                Text(agent.domain)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

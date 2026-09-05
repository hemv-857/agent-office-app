// WorkflowAgentDetailView.swift
import SwiftUI

struct WorkflowAgentDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Details").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Agent list
                    ForEach(store.allAgents.prefix(8)) { agent in
                        AgentDetailRow(agent: agent)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(store.allAgents.count) agents total")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 500)
    }
}

// MARK: - Agent Detail Row
struct AgentDetailRow: View {
    let agent: Agent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text(agent.emoji).font(.system(size: 20))
                VStack(alignment: .leading) {
                    Text(agent.name)
                        .font(.system(size: 12, weight: .semibold))
                    Text(agent.division)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(agent.officeRole)
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
            }
            Text(agent.description)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

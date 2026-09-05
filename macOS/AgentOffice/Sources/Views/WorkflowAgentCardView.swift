// WorkflowAgentCardView.swift
import SwiftUI

struct WorkflowAgentCardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Cards").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(store.allAgents.prefix(10)) { agent in
                        AgentCard(agent: agent)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Showing \(min(10, store.allAgents.count)) of \(store.allAgents.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }
}

// MARK: - Agent Card
struct AgentCard: View {
    let agent: Agent

    var body: some View {
        VStack(spacing: 8) {
            Text(agent.emoji).font(.system(size: 28))
            Text(agent.name)
                .font(.system(size: 12, weight: .semibold))
            Text(agent.division)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text(agent.officeRole)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.1), in: Capsule())
                .foregroundStyle(.blue)
            if !agent.domain.isEmpty {
                Text(agent.domain)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

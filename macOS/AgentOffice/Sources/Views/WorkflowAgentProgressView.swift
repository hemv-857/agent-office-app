// WorkflowAgentProgressView.swift
import SwiftUI

struct WorkflowAgentProgressView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Progress").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(store.allAgents.prefix(8)) { agent in
                        AgentProgressRow(
                            agent: agent,
                            progress: Double.random(in: 0.2...1.0)
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 450)
    }
}

// MARK: - Agent Progress Row
struct AgentProgressRow: View {
    let agent: Agent
    let progress: Double

    var body: some View {
        HStack(spacing: 10) {
            Text(agent.emoji).font(.system(size: 16))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(agent.name)
                        .font(.system(size: 11, weight: .medium))
                    Spacer()
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.system(size: 10, design: .monospaced))
                }
                ProgressView(value: progress)
                    .tint(progress > 0.8 ? .green : progress > 0.5 ? .blue : .orange)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

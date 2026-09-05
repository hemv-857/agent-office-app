// AgentWorkloadView.swift
import SwiftUI

struct AgentWorkloadView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Workload").font(.headline)
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
                    ForEach(store.allAgents) { agent in
                        AgentWorkloadRow(agent: agent)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Active: \(store.desks.filter { $0.isOccupied }.count)/\(store.desks.count) desks")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 450)
    }
}

// MARK: - Workload Row
struct AgentWorkloadRow: View {
    let agent: Agent

    private var workload: Double {
        Double.random(in: 0.2...0.9)
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(agent.emoji).font(.system(size: 16))
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name).font(.system(size: 11, weight: .medium))
                Text(agent.division)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ProgressView(value: workload)
                .frame(width: 80)
            Text(String(format: "%.0f%%", workload * 100))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(workload > 0.8 ? .red : .secondary)
                .frame(width: 35, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

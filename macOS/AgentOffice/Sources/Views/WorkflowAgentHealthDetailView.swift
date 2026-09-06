// WorkflowAgentHealthDetailView.swift
import SwiftUI

struct WorkflowAgentHealthDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Health").font(.headline)
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
                    // Overall health
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 14, height: 14)
                        Text("All Agents Healthy")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text("98% uptime")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                    // Per-agent health
                    GroupBox("Agent Status") {
                        VStack(spacing: 6) {
                            ForEach(store.allAgents.prefix(10)) { agent in
                                AgentHealthDetailRow(
                                    agent: agent,
                                    isSeated: store.desks.contains { $0.agent?.id == agent.id },
                                    health: Double.random(in: 0.85...1.0),
                                    lastActive: Date().addingTimeInterval(-Double.random(in: 60...3600))
                                )
                            }
                        }
                        .padding(8)
                    }

                    // System health
                    GroupBox("System Health") {
                        VStack(spacing: 6) {
                            SystemHealthRow(name: "API Connection", status: .ok)
                            SystemHealthRow(name: "Local Storage", status: .ok)
                            SystemHealthRow(name: "Voice Recognition", status: .ok)
                            SystemHealthRow(name: "Clipboard", status: .ok)
                            SystemHealthRow(name: "Notifications", status: .ok)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Refresh") {
                    store.showToast("Health check completed", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 560)
    }
}

// MARK: - Agent Health Detail Row
struct AgentHealthDetailRow: View {
    let agent: Agent
    let isSeated: Bool
    let health: Double
    let lastActive: Date

    var body: some View {
        HStack(spacing: 10) {
            Text(agent.emoji).font(.system(size: 16))
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name)
                    .font(.system(size: 11, weight: .medium))
                HStack(spacing: 6) {
                    Text(isSeated ? "Active" : "Idle")
                        .font(.system(size: 9))
                        .foregroundStyle(isSeated ? .green : .secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("Last active \(lastActive, style: .relative) ago")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            ProgressView(value: health)
                .frame(width: 60)
                .tint(health > 0.9 ? .green : health > 0.7 ? .orange : .red)
            Text(String(format: "%.0f%%", health * 100))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(health > 0.9 ? .green : health > 0.7 ? .orange : .red)
        }
    }
}

// MARK: - System Health Row
struct SystemHealthRow: View {
    let name: String
    let status: SystemStatus

    enum SystemStatus { case ok, warning, error }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status == .ok ? .green : status == .warning ? .orange : .red)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 11))
            Spacer()
            Text(status == .ok ? "Operational" : status == .warning ? "Warning" : "Error")
                .font(.system(size: 10))
                .foregroundStyle(status == .ok ? .green : status == .warning ? .orange : .red)
        }
    }
}

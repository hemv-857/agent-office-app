// WorkflowAgentAgentStatusDashboardView.swift
import SwiftUI

struct WorkflowAgentAgentStatusDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, String, Double, Bool)] = [
        ("Architect", "Design review", 96.2, true),
        ("Builder", "API implementation", 94.8, true),
        ("Reviewer", "Code review", 97.1, true),
        ("Tester", "Running tests", 93.5, true),
        ("Planner", "Sprint planning", 95.0, false),
        ("Security", "Available", 98.0, true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Status Dashboard").font(.headline)
                Spacer()
                Text("\(agents.filter { $0.3 }.count)/\(agents.count) active")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                AgentStatusStat(label: "Active", value: "\(agents.filter { $0.3 }.count)", color: .green)
                AgentStatusStat(label: "Idle", value: "\(agents.filter { !$0.3 }.count)", color: .secondary)
                AgentStatusStat(label: "Avg Accuracy", value: "95.8%", color: .blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(agents.indices, id: \.self) { i in
                        AgentStatusDashboardRow(
                            name: agents[i].0,
                            activity: agents[i].1,
                            accuracy: agents[i].2,
                            active: agents[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

// MARK: - Agent Status Stat
struct AgentStatusStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Agent Status Row
struct AgentStatusDashboardRow: View {
    let name: String
    let activity: String
    let accuracy: Double
    let active: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(active ? .green : .secondary)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(activity)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "%.1f%%", accuracy))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(accuracy > 95 ? .green : .blue)
        }
        .padding(.vertical, 4)
    }
}

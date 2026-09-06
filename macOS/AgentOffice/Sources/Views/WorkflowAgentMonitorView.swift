// WorkflowAgentMonitorView.swift
import SwiftUI

struct WorkflowAgentMonitorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, String, Bool, String, Double)] = [
        ("Architect", "Design review", true, "Running", 0.45),
        ("Builder", "API implementation", true, "Running", 0.72),
        ("Reviewer", "Code review", false, "Idle", 0.0),
        ("Tester", "Test execution", true, "Running", 0.38),
        ("Planner", "Sprint planning", false, "Idle", 0.0),
        ("Security", "Security scan", false, "Idle", 0.0),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Monitor").font(.headline)
                Spacer()
                Text("\(agents.filter { $0.2 }.count) active")
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
                MonitorStat(label: "Active", value: "\(agents.filter { $0.2 }.count)", color: .green)
                MonitorStat(label: "Idle", value: "\(agents.filter { !$0.2 }.count)", color: .secondary)
                MonitorStat(label: "Total", value: "\(agents.count)", color: .blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Agent list
            List {
                ForEach(agents.indices, id: \.self) { i in
                    MonitorAgentRow(
                        name: agents[i].0,
                        task: agents[i].1,
                        active: agents[i].2,
                        status: agents[i].3,
                        progress: agents[i].4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Refresh") {
                    store.showToast("Monitor refreshed", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Monitor Stat
struct MonitorStat: View {
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

// MARK: - Monitor Agent Row
struct MonitorAgentRow: View {
    let name: String
    let task: String
    let active: Bool
    let status: String
    let progress: Double

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(active ? .green : .secondary)
                .frame(width: 10, height: 10)
                .overlay(
                    active ? Circle().stroke(.green.opacity(0.3), lineWidth: 3).frame(width: 16, height: 16) : nil
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Text(task)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(status)
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(active ? .green.opacity(0.15) : .secondary.opacity(0.15), in: Capsule())
                    .foregroundStyle(active ? .green : .secondary)
                if active {
                    ProgressView(value: progress)
                        .frame(width: 60)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// WorkflowAgentActivityMonitorView.swift
import SwiftUI

struct WorkflowAgentActivityMonitorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, String, Bool, String)] = [
        ("Architect", "Design review meeting", false, "30 min"),
        ("Builder", "API implementation", true, "Active"),
        ("Reviewer", "Code review sprint", true, "Active"),
        ("Tester", "Running test suite", true, "Active"),
        ("Planner", "Sprint planning", false, "1 hour"),
        ("Security", "Available", true, "Active"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Activity Monitor").font(.headline)
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
                ActivityMonitorStat(label: "Active", value: "\(agents.filter { $0.2 }.count)", color: .green)
                ActivityMonitorStat(label: "Idle", value: "\(agents.filter { !$0.2 }.count)", color: .secondary)
                ActivityMonitorStat(label: "Total", value: "\(agents.count)", color: .blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Agent list
            List {
                ForEach(agents.indices, id: \.self) { i in
                    ActivityMonitorRow(
                        name: agents[i].0,
                        activity: agents[i].1,
                        active: agents[i].2,
                        status: agents[i].3
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
        .frame(width: 480, height: 480)
    }
}

// MARK: - Activity Monitor Stat
struct ActivityMonitorStat: View {
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

// MARK: - Activity Monitor Row
struct ActivityMonitorRow: View {
    let name: String
    let activity: String
    let active: Bool
    let status: String

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
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(active ? .green.opacity(0.15) : .secondary.opacity(0.15), in: Capsule())
                .foregroundStyle(active ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }
}

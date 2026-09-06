// WorkflowAgentTaskQueueView.swift
import SwiftUI

struct WorkflowAgentTaskQueueView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedStatus = "all"

    private let tasks: [(String, String, String, String, Color)] = [
        ("Implement auth endpoints", "Builder", "high", "queued", .blue),
        ("Review PR #42", "Reviewer", "high", "in_progress", .orange),
        ("Run regression tests", "Tester", "medium", "queued", .blue),
        ("Update architecture docs", "Architect", "low", "queued", .secondary),
        ("Security scan PR #41", "Security", "high", "in_progress", .orange),
        ("Sprint retrospective", "Planner", "low", "pending", .secondary),
        ("Database migration", "Builder", "medium", "queued", .blue),
        ("API documentation", "Builder", "low", "pending", .secondary),
    ]

    private let priorityColors: [String: Color] = [
        "high": .red,
        "medium": .orange,
        "low": .secondary,
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task Queue").font(.headline)
                Spacer()
                Text("\(tasks.count) tasks")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Stats
            HStack(spacing: 12) {
                TaskQueueStat(label: "Queued", value: "\(tasks.filter { $0.3 == "queued" }.count)", color: .blue)
                TaskQueueStat(label: "In Progress", value: "\(tasks.filter { $0.3 == "in_progress" }.count)", color: .orange)
                TaskQueueStat(label: "Pending", value: "\(tasks.filter { $0.3 == "pending" }.count)", color: .secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Filter
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(["all", "queued", "in_progress", "pending"], id: \.self) { filter in
                        Text(filter.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedStatus == filter ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedStatus == filter ? .white : .primary)
                            .onTapGesture { selectedStatus = filter }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)

            // Task list
            List {
                ForEach(tasks.filter { selectedStatus == "all" || $0.3 == selectedStatus }, id: \.0) { task in
                    TaskQueueRow(
                        title: task.0,
                        agent: task.1,
                        priority: task.2,
                        status: task.3,
                        priorityColor: priorityColors[task.2] ?? .secondary,
                        statusColor: task.4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Add Task") {
                    store.showToast("Task added to queue", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Task Queue Stat
struct TaskQueueStat: View {
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

// MARK: - Task Queue Row
struct TaskQueueRow: View {
    let title: String
    let agent: String
    let priority: String
    let status: String
    let priorityColor: Color
    let statusColor: Color

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                HStack(spacing: 6) {
                    Text(agent)
                        .font(.system(size: 9))
                    Text(priority.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(priorityColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(priorityColor)
                }
            }
            Spacer()
            Text(status.replacingOccurrences(of: "_", with: " "))
                .font(.system(size: 9, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusColor.opacity(0.15), in: Capsule())
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 4)
    }
}

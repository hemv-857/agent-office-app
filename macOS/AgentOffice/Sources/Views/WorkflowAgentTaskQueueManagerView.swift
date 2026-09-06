// WorkflowAgentTaskQueueManagerView.swift
import SwiftUI

struct WorkflowAgentTaskQueueManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedFilter = "all"

    private let tasks: [(String, String, String, String, Int)] = [
        ("Auth endpoint implementation", "Builder", "high", "queued", 1),
        ("Code review PR #42", "Reviewer", "high", "in_progress", 2),
        ("Regression test suite", "Tester", "medium", "queued", 3),
        ("Sprint backlog update", "Planner", "low", "pending", 4),
        ("Security vulnerability scan", "Security", "high", "in_progress", 5),
        ("API documentation", "Builder", "low", "pending", 6),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task Queue Manager").font(.headline)
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
                TaskQueueManagerStat(label: "Queued", value: "\(tasks.filter { $0.3 == "queued" }.count)", color: .blue)
                TaskQueueManagerStat(label: "In Progress", value: "\(tasks.filter { $0.3 == "in_progress" }.count)", color: .orange)
                TaskQueueManagerStat(label: "Pending", value: "\(tasks.filter { $0.3 == "pending" }.count)", color: .secondary)
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
                            .background(selectedFilter == filter ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .onTapGesture { selectedFilter = filter }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)

            // Task list
            List {
                ForEach(tasks.filter { selectedFilter == "all" || $0.3 == selectedFilter }, id: \.4) { task in
                    TaskQueueManagerRow(
                        title: task.0,
                        agent: task.1,
                        priority: task.2,
                        status: task.3,
                        order: task.4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Reorder") {
                    store.showToast("Tasks reordered", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Task Queue Manager Stat
struct TaskQueueManagerStat: View {
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

// MARK: - Task Queue Manager Row
struct TaskQueueManagerRow: View {
    let title: String
    let agent: String
    let priority: String
    let status: String
    let order: Int

    var body: some View {
        HStack(spacing: 10) {
            Text("\(order)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .frame(width: 20)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                HStack(spacing: 4) {
                    Text(agent)
                        .font(.system(size: 9))
                    Text(priority)
                        .font(.system(size: 8))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.quaternary, in: Capsule())
                }
            }
            Spacer()
            Text(status.replacingOccurrences(of: "_", with: " "))
                .font(.system(size: 9, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    (status == "in_progress" ? Color.orange : status == "queued" ? Color.blue : Color.secondary)
                        .opacity(0.15), in: Capsule()
                )
        }
        .padding(.vertical, 4)
    }
}

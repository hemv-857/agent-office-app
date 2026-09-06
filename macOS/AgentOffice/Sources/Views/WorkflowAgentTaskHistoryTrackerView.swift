// WorkflowAgentTaskHistoryTrackerView.swift
import SwiftUI

struct WorkflowAgentTaskHistoryTrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedAgent = "all"

    private let agents = ["all", "Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    private let history: [(Date, String, String, String, String)] = [
        (Date().addingTimeInterval(-300), "Architect", "System design review", "completed", "2 min"),
        (Date().addingTimeInterval(-600), "Builder", "API endpoint implementation", "completed", "15 min"),
        (Date().addingTimeInterval(-900), "Reviewer", "Code review PR #42", "completed", "8 min"),
        (Date().addingTimeInterval(-1200), "Tester", "Regression test suite", "in_progress", "12 min"),
        (Date().addingTimeInterval(-1500), "Planner", "Sprint backlog grooming", "completed", "20 min"),
        (Date().addingTimeInterval(-1800), "Security", "Vulnerability scan", "completed", "5 min"),
        (Date().addingTimeInterval(-2100), "Builder", "Database migration", "completed", "10 min"),
        (Date().addingTimeInterval(-2400), "Architect", "API documentation update", "completed", "8 min"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task History").font(.headline)
                Spacer()
                Text("\(history.count) tasks")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Agent filter
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(agents, id: \.self) { agent in
                        Text(agent.capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedAgent == agent ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedAgent == agent ? .white : .primary)
                            .onTapGesture { selectedAgent = agent }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // History list
            List {
                ForEach(history.filter { selectedAgent == "all" || $0.1 == selectedAgent }, id: \.2) { entry in
                    TaskHistoryTrackerRow(
                        time: entry.0,
                        agent: entry.1,
                        task: entry.2,
                        status: entry.3,
                        duration: entry.4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Task History Tracker Row
struct TaskHistoryTrackerRow: View {
    let time: Date
    let agent: String
    let task: String
    let status: String
    let duration: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status == "completed" ? .green : .orange)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(task)
                        .font(.system(size: 11, weight: .medium))
                    Spacer()
                    Text(duration)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Text(agent)
                        .font(.system(size: 9))
                    Text(time, style: .relative)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text(status)
                        .font(.system(size: 8))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            (status == "completed" ? Color.green : Color.orange)
                                .opacity(0.15), in: Capsule()
                        )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

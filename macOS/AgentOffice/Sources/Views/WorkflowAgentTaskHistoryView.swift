// WorkflowAgentTaskHistoryView.swift
import SwiftUI

struct WorkflowAgentTaskHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedFilter = "all"

    private let history: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-300), "Architect", "System design review", "completed", .green),
        (Date().addingTimeInterval(-600), "Builder", "API endpoint implementation", "completed", .green),
        (Date().addingTimeInterval(-900), "Reviewer", "PR #42 code review", "completed", .green),
        (Date().addingTimeInterval(-1200), "Tester", "Auth module regression test", "failed", .red),
        (Date().addingTimeInterval(-1500), "Planner", "Sprint backlog grooming", "completed", .green),
        (Date().addingTimeInterval(-1800), "Security", "Dependency vulnerability scan", "in_progress", .orange),
        (Date().addingTimeInterval(-2100), "Builder", "Database migration script", "completed", .green),
        (Date().addingTimeInterval(-2400), "Architect", "Microservice boundary definition", "completed", .green),
        (Date().addingTimeInterval(-2700), "Reviewer", "Security audit findings review", "completed", .green),
        (Date().addingTimeInterval(-3000), "Tester", "Load test execution", "queued", .secondary),
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

            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(["all", "completed", "failed", "in_progress", "queued"], id: \.self) { filter in
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
            .padding(.vertical, 8)

            List {
                ForEach(history.indices, id: \.self) { i in
                    TaskHistoryRow(
                        date: history[i].0,
                        agent: history[i].1,
                        task: history[i].2,
                        status: history[i].3,
                        statusColor: history[i].4
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

// MARK: - Task History Row
struct TaskHistoryRow: View {
    let date: Date
    let agent: String
    let task: String
    let status: String
    let statusColor: Color

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(agent)
                        .font(.system(size: 11, weight: .semibold))
                    Text(task)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Text(date, style: .relative)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
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

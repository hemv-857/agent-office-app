// WorkflowAgentTaskView.swift
import SwiftUI

struct WorkflowAgentTaskView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let tasks: [(String, String, String)] = [
        ("Architect", "Design system architecture", "Completed"),
        ("Builder", "Implement API endpoints", "In Progress"),
        ("Reviewer", "Review code changes", "Pending"),
        ("Tester", "Run test suite", "Pending"),
        ("Planner", "Update project plan", "Completed"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Tasks").font(.headline)
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
                    ForEach(tasks, id: \.0) { task in
                        AgentTaskRow(
                            agent: task.0,
                            task: task.1,
                            status: task.2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(tasks.filter { $0.2 == "Completed" }.count)/\(tasks.count) completed")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 420)
    }
}

// MARK: - Agent Task Row
struct AgentTaskRow: View {
    let agent: String
    let task: String
    let status: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: status == "Completed" ? "checkmark.circle.fill" : status == "In Progress" ? "arrow.triangle.2.circlepath" : "circle")
                .foregroundStyle(status == "Completed" ? .green : status == "In Progress" ? .blue : .gray)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(agent)
                    .font(.system(size: 11, weight: .medium))
                Text(task)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(status == "Completed" ? Color.green.opacity(0.2) : status == "In Progress" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2), in: Capsule())
                .foregroundStyle(status == "Completed" ? .green : status == "In Progress" ? .blue : .gray)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

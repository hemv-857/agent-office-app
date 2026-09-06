// WorkflowAgentAgentTaskHistoryView.swift
import SwiftUI

struct WorkflowAgentAgentTaskHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let tasks: [(String, String, String, String, Color)] = [
        ("2026-01-15", "Architect", "System Design Review", "Completed", .green),
        ("2026-01-15", "Builder", "API Endpoint /users", "Completed", .green),
        ("2026-01-14", "Reviewer", "PR #42 Code Review", "Completed", .green),
        ("2026-01-14", "Tester", "Integration Tests", "Failed", .red),
        ("2026-01-13", "Planner", "Sprint Planning Q1", "Completed", .green),
        ("2026-01-13", "Security", "Vulnerability Scan", "Completed", .green),
        ("2026-01-12", "Architect", "Database Migration Plan", "In Progress", .orange),
        ("2026-01-12", "Builder", "Frontend Components", "Completed", .green),
        ("2026-01-11", "Reviewer", "Security Audit", "Completed", .green),
        ("2026-01-11", "Tester", "Performance Tests", "Completed", .green),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task History").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filter
            HStack(spacing: 6) {
                ForEach(["All", "Completed", "Failed", "In Progress"], id: \.self) { filter in
                    Text(filter)
                        .font(.system(size: 9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 6)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(tasks.indices, id: \.self) { i in
                        AgentTaskHistoryRow(
                            date: tasks[i].0,
                            agent: tasks[i].1,
                            task: tasks[i].2,
                            status: tasks[i].3,
                            color: tasks[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("History exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Clear") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Task History Row
struct AgentTaskHistoryRow: View {
    let date: String
    let agent: String
    let task: String
    let status: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(date)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 75, alignment: .leading)
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(task)
                    .font(.system(size: 11, weight: .medium))
                Text(agent)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 9, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(color.opacity(0.15), in: Capsule())
                .foregroundStyle(color)
        }
        .padding(.vertical, 4)
    }
}
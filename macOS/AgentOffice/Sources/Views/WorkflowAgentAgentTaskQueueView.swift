// WorkflowAgentAgentTaskQueueView.swift
import SwiftUI

struct WorkflowAgentAgentTaskQueueView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let tasks: [(String, String, String, String, Color)] = [
        ("Implement user auth", "Planner", "Pending", "High", .red),
        ("Design database schema", "Architect", "In Progress", "High", .orange),
        ("Write unit tests", "Tester", "Pending", "Medium", .yellow),
        ("Code review PR #42", "Reviewer", "Ready", "Medium", .blue),
        ("Security audit", "Security", "Blocked", "Critical", .red),
        ("Deploy to staging", "Builder", "Pending", "Low", .green),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Task Queue").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Stats
            HStack(spacing: 16) {
                StatPill(label: "Total", value: "6", color: .blue)
                StatPill(label: "In Progress", value: "1", color: .orange)
                StatPill(label: "Pending", value: "3", color: .yellow)
                StatPill(label: "Blocked", value: "1", color: .red)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Queue
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(tasks.indices, id: \.self) { i in
                        AgentTaskQueueRow(
                            title: tasks[i].0,
                            agent: tasks[i].1,
                            status: tasks[i].2,
                            priority: tasks[i].3,
                            priorityColor: tasks[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Add Task") { }
                    .buttonStyle(.bordered)
                Button("Clear Completed") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 460)
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Task Queue Row
struct AgentTaskQueueRow: View {
    let title: String
    let agent: String
    let status: String
    let priority: String
    let priorityColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                Text(agent)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 9, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.15), in: Capsule())
                .foregroundStyle(statusColor)
            Text(priority)
                .font(.system(size: 8, weight: .semibold))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(priorityColor.opacity(0.15), in: Capsule())
                .foregroundStyle(priorityColor)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch status {
        case "In Progress": return .orange
        case "Ready": return .blue
        case "Blocked": return .red
        default: return .gray
        }
    }
}
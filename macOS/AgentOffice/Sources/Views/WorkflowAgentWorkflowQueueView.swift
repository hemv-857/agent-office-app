// WorkflowAgentWorkflowQueueView.swift
import SwiftUI

struct WorkflowAgentWorkflowQueueView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var queue: [(String, String, String, Bool)] = [
        ("Parallel Research", "3 agents, 5 topics", "Queued", false),
        ("Code Review", "2 reviewers, 1 PR", "Running", true),
        ("Pipeline Build", "4 stages", "Queued", false),
        ("Debate Analysis", "3 agents", "Queued", false),
        ("Quality Gate", "2 reviewers", "Completed", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Queue").font(.headline)
                Spacer()
                Text("\(queue.count) items")
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
                QueueStat(label: "Queued", value: "\(queue.filter { $0.2 == "Queued" }.count)", color: .blue)
                QueueStat(label: "Running", value: "\(queue.filter { $0.3 }.count)", color: .green)
                QueueStat(label: "Done", value: "\(queue.filter { $0.2 == "Completed" }.count)", color: .purple)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            List {
                ForEach(queue.indices, id: \.self) { i in
                    WorkflowQueueRow(
                        name: queue[i].0,
                        details: queue[i].1,
                        status: queue[i].2,
                        running: queue[i].3
                    )
                }
                .onMove { from, to in
                    queue.move(fromOffsets: from, toOffset: to)
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Add Workflow") {
                    store.showToast("Workflow added to queue", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Clear Completed") {
                    queue.removeAll { $0.2 == "Completed" }
                    store.showToast("Completed workflows cleared", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}

// MARK: - Queue Stat
struct QueueStat: View {
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

// MARK: - Workflow Queue Row
struct WorkflowQueueRow: View {
    let name: String
    let details: String
    let status: String
    let running: Bool

    var body: some View {
        HStack(spacing: 10) {
            if running {
                ProgressView()
                    .controlSize(.small)
            } else {
                Circle()
                    .fill(.secondary)
                    .frame(width: 8, height: 8)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(details)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(running ? .green.opacity(0.15) : status == "Completed" ? .purple.opacity(0.15) : .blue.opacity(0.15), in: Capsule())
                .foregroundStyle(running ? .green : status == "Completed" ? .purple : .blue)
        }
        .padding(.vertical, 4)
    }
}

// WorkflowExecutionTimelineView.swift
import SwiftUI

struct WorkflowExecutionTimelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let events: [(String, String, String, Bool)] = [
        ("09:15", "Workflow Started", "Parallel Research mode selected", true),
        ("09:16", "Agents Assigned", "Architect + Builder + Reviewer", true),
        ("09:17", "Research Phase", "Gathering information from 3 sources", true),
        ("09:19", "Build Phase", "Implementing 12 tasks", true),
        ("09:24", "Review Phase", "Code review and quality checks", true),
        ("09:26", "Quality Gate", "All checks passed", true),
        ("09:27", "Synthesis", "Merging outputs into final result", true),
        ("09:28", "Workflow Complete", "Total time: 13 min, Cost: $0.48", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Execution Timeline").font(.headline)
                Spacer()
                Text("\(events.count) events")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(events.indices, id: \.self) { i in
                        ExecutionTimelineEventRow(
                            time: events[i].0,
                            title: events[i].1,
                            detail: events[i].2,
                            success: events[i].3
                        )
                        if i < events.count - 1 {
                            Rectangle()
                                .fill(.quaternary)
                                .frame(width: 2, height: 20)
                                .padding(.leading, 30)
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Timeline exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}

// MARK: - Timeline Event Row
struct ExecutionTimelineEventRow: View {
    let time: String
    let title: String
    let detail: String
    let success: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Time + dot
            VStack(spacing: 4) {
                Circle()
                    .fill(success ? .green : .red)
                    .frame(width: 10, height: 10)
                Text(time)
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

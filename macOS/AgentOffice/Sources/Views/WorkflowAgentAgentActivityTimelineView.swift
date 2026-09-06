// WorkflowAgentAgentActivityTimelineView.swift
import SwiftUI

struct WorkflowAgentAgentActivityTimelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let events: [(String, String, String, Color)] = [
        ("10:00 AM", "Planner", "Sprint planning completed", .green),
        ("10:15 AM", "Architect", "System design review started", .blue),
        ("10:30 AM", "Builder", "API implementation in progress", .orange),
        ("10:45 AM", "Reviewer", "Code review #42 started", .purple),
        ("11:00 AM", "Tester", "Unit tests 8/12 passed", .green),
        ("11:15 AM", "Security", "Security scan completed", .green),
        ("11:30 AM", "Builder", "PR #43 opened for review", .blue),
        ("11:45 AM", "Architect", "Design doc updated", .orange),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Activity Timeline").font(.headline)
                Spacer()
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
                        ActivityTimelineEventRow(
                            time: events[i].0,
                            agent: events[i].1,
                            description: events[i].2,
                            color: events[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 460)
    }
}

// MARK: - Timeline Event Row
struct ActivityTimelineEventRow: View {
    let time: String
    let agent: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .trailing, spacing: 4) {
                Text(time)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60)

            VStack(spacing: 0) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                if #available(macOS 12.0, *) {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 2)
                        .frame(minHeight: 30)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(agent)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

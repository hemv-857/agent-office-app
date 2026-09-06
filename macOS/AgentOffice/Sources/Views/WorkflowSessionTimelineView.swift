// WorkflowSessionTimelineView.swift
import SwiftUI

struct WorkflowSessionTimelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let events: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-10), "Session Started", "Parallel workflow initiated", "play.circle.fill", .green),
        (Date().addingTimeInterval(-60), "Agent Seated", "Architect assigned to system design", "person.fill", .blue),
        (Date().addingTimeInterval(-120), "Task Assigned", "Design microservices architecture", "text.badge.checkmark", .purple),
        (Date().addingTimeInterval(-180), "Agent Seated", "Builder assigned to implementation", "person.fill", .blue),
        (Date().addingTimeInterval(-240), "API Call", "Claude Sonnet — 1,204 tokens", "bolt.fill", .orange),
        (Date().addingTimeInterval(-300), "Task Complete", "Architecture design finished", "checkmark.circle.fill", .green),
        (Date().addingTimeInterval(-360), "Cost Update", "$0.018 added to session cost", "dollarsign.circle", .secondary),
        (Date().addingTimeInterval(-420), "Pipeline Stage", "Stage 2/5: Implementation", "arrow.triangle.branch", .blue),
        (Date().addingTimeInterval(-480), "Agent Removed", "Tester removed from desk", "person.fill.xmark", .red),
        (Date().addingTimeInterval(-540), "Session Ended", "Pipeline completed successfully", "stop.circle.fill", .secondary),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Timeline").font(.headline)
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
                    ForEach(events.indices, id: \.self) { index in
                        TimelineEventRow(
                            time: events[index].0,
                            title: events[index].1,
                            description: events[index].2,
                            icon: events[index].3,
                            color: events[index].4,
                            isLast: index == events.count - 1
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            Divider()

            HStack {
                Text("Timeline total: \(events.count) events")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 520)
    }
}

// MARK: - Timeline Event Row
struct TimelineEventRow: View {
    let time: Date
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline connector
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 24, height: 24)
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2, height: 30)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(time, style: .time)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 8)
        }
    }
}

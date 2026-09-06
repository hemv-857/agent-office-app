// WorkflowAgentCollaborationTimelineView.swift
import SwiftUI

struct WorkflowAgentCollaborationTimelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let events: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-60), "Architect", "Design review started", "meeting", .blue),
        (Date().addingTimeInterval(-180), "Builder", "Code committed to PR #42", "code", .green),
        (Date().addingTimeInterval(-300), "Reviewer", "Review comments added", "comment", .purple),
        (Date().addingTimeInterval(-420), "Tester", "Test suite started", "test", .orange),
        (Date().addingTimeInterval(-600), "Planner", "Sprint updated", "plan", .teal),
        (Date().addingTimeInterval(-720), "Security", "Security scan completed", "scan", .red),
        (Date().addingTimeInterval(-900), "Architect", "Architecture docs updated", "doc", .blue),
        (Date().addingTimeInterval(-1080), "Builder", "API endpoints deployed", "deploy", .green),
        (Date().addingTimeInterval(-1200), "Reviewer", "PR #41 approved", "approve", .purple),
        (Date().addingTimeInterval(-1380), "Tester", "E2E tests passed", "pass", .green),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Collaboration Timeline").font(.headline)
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
                        HStack(spacing: 12) {
                            // Timeline line
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(events[i].4)
                                    .frame(width: 10, height: 10)
                                if i < events.count - 1 {
                                    Rectangle()
                                        .fill(Color(nsColor: .separatorColor))
                                        .frame(width: 2, height: 40)
                                }
                            }
                            .frame(width: 20)

                            // Event content
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(events[i].1)
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(events[i].3)
                                        .font(.system(size: 8))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(events[i].4.opacity(0.15), in: Capsule())
                                        .foregroundStyle(events[i].4)
                                }
                                Text(events[i].2)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                Text(events[i].0, style: .relative)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

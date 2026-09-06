// WorkflowAgentActivityFeedView.swift
import SwiftUI

struct WorkflowAgentActivityFeedView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedFilter = "all"

    private let activities: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-30), "Architect", "Completed design review", "design", .blue),
        (Date().addingTimeInterval(-120), "Builder", "Committed 3 files to PR #42", "code", .green),
        (Date().addingTimeInterval(-240), "Reviewer", "Approved PR #42 with comments", "approve", .purple),
        (Date().addingTimeInterval(-360), "Tester", "Started regression test suite", "test", .orange),
        (Date().addingTimeInterval(-480), "Planner", "Updated sprint backlog", "plan", .teal),
        (Date().addingTimeInterval(-600), "Security", "Completed vulnerability scan", "scan", .red),
        (Date().addingTimeInterval(-720), "Builder", "Deployed to staging environment", "deploy", .green),
        (Date().addingTimeInterval(-840), "Architect", "Updated API documentation", "doc", .blue),
        (Date().addingTimeInterval(-960), "Reviewer", "Found 2 issues in PR #41", "comment", .orange),
        (Date().addingTimeInterval(-1080), "Tester", "All E2E tests passed", "pass", .green),
    ]

    private let categories = ["all", "code", "review", "test", "plan"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Activity Feed").font(.headline)
                Spacer()
                Text("\(activities.count) activities")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Filter
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat.capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedFilter == cat ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedFilter == cat ? .white : .primary)
                            .onTapGesture { selectedFilter = cat }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Activity list
            List {
                ForEach(activities.indices, id: \.self) { i in
                    ActivityFeedRow(
                        time: activities[i].0,
                        agent: activities[i].1,
                        action: activities[i].2,
                        type: activities[i].3,
                        color: activities[i].4
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
        .frame(width: 520, height: 560)
    }
}

// MARK: - Activity Feed Row
struct ActivityFeedRow: View {
    let time: Date
    let agent: String
    let action: String
    let type: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(agent)
                        .font(.system(size: 11, weight: .semibold))
                    Text(type)
                        .font(.system(size: 8))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(color.opacity(0.15), in: Capsule())
                        .foregroundStyle(color)
                }
                Text(action)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(time, style: .relative)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

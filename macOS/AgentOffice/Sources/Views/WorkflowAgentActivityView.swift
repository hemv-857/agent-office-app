// WorkflowAgentActivityView.swift
import SwiftUI

struct WorkflowAgentActivityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let activities: [(Date, String, String)] = [
        (Date().addingTimeInterval(-60), "Architect", "Completed system design"),
        (Date().addingTimeInterval(-120), "Builder", "Finished API implementation"),
        (Date().addingTimeInterval(-180), "Reviewer", "Started code review"),
        (Date().addingTimeInterval(-240), "Tester", "Running test suite"),
        (Date().addingTimeInterval(-300), "Planner", "Updated project roadmap"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Activity").font(.headline)
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
                    ForEach(activities.indices, id: \.self) { index in
                        ActivityRow(
                            date: activities[index].0,
                            agent: activities[index].1,
                            action: activities[index].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(activities.count) recent activities")
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

// MARK: - Activity Row
struct ActivityRow: View {
    let date: Date
    let agent: String
    let action: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(agent)
                        .font(.system(size: 11, weight: .medium))
                    Spacer()
                    Text(date, style: .relative)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Text(action)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

// WorkflowAgentCommunicationLogView.swift
import SwiftUI

struct WorkflowAgentCommunicationLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedFilter = "all"

    private let logs: [(Date, String, String, String, Color)] = [
        (Date().addingTimeInterval(-10), "Architect → Builder", "Design specs approved, proceed to implementation", "arrow.right.circle.fill", .blue),
        (Date().addingTimeInterval(-60), "Builder → Reviewer", "PR #42 ready for review — API endpoints implemented", "arrow.right.circle.fill", .green),
        (Date().addingTimeInterval(-120), "Reviewer → Tester", "Code review passed, ready for QA testing", "arrow.right.circle.fill", .purple),
        (Date().addingTimeInterval(-180), "Tester → Planner", "2 test failures found in auth module", "exclamationmark.circle.fill", .orange),
        (Date().addingTimeInterval(-240), "Planner → Architect", "Requirements updated — add rate limiting", "arrow.right.circle.fill", .secondary),
        (Date().addingTimeInterval(-300), "System → All", "Budget alert: 80% of daily limit reached", "bell.fill", .red),
        (Date().addingTimeInterval(-360), "Architect → Builder", "Updated architecture docs with rate limiting", "arrow.right.circle.fill", .blue),
        (Date().addingTimeInterval(-420), "Builder → Architect", "Clarification needed on rate limit thresholds", "questionmark.circle.fill", .orange),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Communication Log").font(.headline)
                Spacer()
                Text("\(logs.count) messages")
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
                    ForEach(["all", "agent", "system"], id: \.self) { filter in
                        Text(filter.capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedFilter == filter ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .onTapGesture { selectedFilter = filter }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Logs
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(logs.indices, id: \.self) { index in
                        CommLogRow(
                            time: logs[index].0,
                            from: logs[index].1,
                            message: logs[index].2,
                            icon: logs[index].3,
                            color: logs[index].4
                        )
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
        .frame(width: 520, height: 520)
    }
}

// MARK: - Comm Log Row
struct CommLogRow: View {
    let time: Date
    let from: String
    let message: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(from)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(time, style: .time)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

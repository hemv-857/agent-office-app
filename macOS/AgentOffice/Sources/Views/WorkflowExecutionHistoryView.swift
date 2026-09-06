// WorkflowExecutionHistoryView.swift
import SwiftUI

struct WorkflowExecutionHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let history: [(String, String, String, Bool, String)] = [
        ("Parallel Research", "2 agents, 3 topics", "2.4 min", true, "$0.18"),
        ("Pipeline Build", "4 stages, 12 tasks", "8.1 min", true, "$0.32"),
        ("Debate Analysis", "3 agents, 1 topic", "5.6 min", true, "$0.24"),
        ("Quality Gate", "2 reviewers", "1.2 min", true, "$0.08"),
        ("Review Cycle", "3 agents, feedback loop", "6.3 min", true, "$0.28"),
        ("Conditional Flow", "5 steps, 2 branches", "4.8 min", false, "$0.16"),
        ("Collaboration", "4 agents, shared context", "7.2 min", true, "$0.36"),
        ("Synthesis Merge", "3 outputs, 1 merged", "3.1 min", true, "$0.12"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Execution History").font(.headline)
                Spacer()
                Text("\(history.count) workflows")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            List {
                ForEach(history.indices, id: \.self) { i in
                    ExecutionHistoryRow(
                        name: history[i].0,
                        details: history[i].1,
                        duration: history[i].2,
                        success: history[i].3,
                        cost: history[i].4
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("History exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Execution History Row
struct ExecutionHistoryRow: View {
    let name: String
    let details: String
    let duration: String
    let success: Bool
    let cost: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(success ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(details)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(duration)
                    .font(.system(size: 10, design: .monospaced))
                Text(cost)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

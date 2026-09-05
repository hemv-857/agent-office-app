// WorkflowExecutionHistoryView.swift
import SwiftUI

struct WorkflowExecutionHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let history: [(Date, String, WorkflowMode, Bool)] = [
        (Date().addingTimeInterval(-3600), "Analyze codebase", .parallel, true),
        (Date().addingTimeInterval(-7200), "Review PR #42", .review, true),
        (Date().addingTimeInterval(-10800), "Build feature X", .pipeline, false),
        (Date().addingTimeInterval(-14400), "Debug issue", .synthesis, true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Execution History").font(.headline)
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
                    ForEach(history.indices, id: \.self) { index in
                        ExecutionHistoryRow(
                            date: history[index].0,
                            prompt: history[index].1,
                            mode: history[index].2,
                            success: history[index].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Total: \(history.count) executions")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 450)
    }
}

// MARK: - History Row
struct ExecutionHistoryRow: View {
    let date: Date
    let prompt: String
    let mode: WorkflowMode
    let success: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(success ? .green : .red)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(prompt)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(mode.rawValue.capitalized)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1), in: Capsule())
                        .foregroundStyle(.blue)
                    Text(date, style: .relative)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

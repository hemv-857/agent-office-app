// WorkflowExecutionQueueView.swift
import SwiftUI

struct WorkflowExecutionQueueView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let queue: [(String, String, String, Bool)] = [
        ("Analyze codebase", "Parallel", "Architect, Builder", true),
        ("Review PR #42", "Review", "Reviewer", false),
        ("Build feature X", "Pipeline", "Builder, Tester", false),
        ("Debug issue", "Synthesis", "All agents", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Execution Queue").font(.headline)
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
                    ForEach(queue.indices, id: \.self) { index in
                        QueueRow(
                            prompt: queue[index].0,
                            mode: queue[index].1,
                            agents: queue[index].2,
                            running: queue[index].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(queue.count) items in queue")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 400)
    }
}

// MARK: - Queue Row
struct QueueRow: View {
    let prompt: String
    let mode: String
    let agents: String
    let running: Bool

    var body: some View {
        HStack(spacing: 10) {
            if running {
                ProgressView()
                    .controlSize(.mini)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(prompt)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(mode)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1), in: Capsule())
                        .foregroundStyle(.blue)
                    Text(agents)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(running ? Color.blue.opacity(0.05) : .clear, in: RoundedRectangle(cornerRadius: 6))
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

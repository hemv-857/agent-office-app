// WorkflowAgentWorkflowExecutionView.swift
import SwiftUI

struct WorkflowAgentWorkflowExecutionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var isRunning = false

    private let steps: [(String, String, String, Bool)] = [
        ("1", "Input Processing", "Parse and validate user prompt", true),
        ("2", "Agent Selection", "Route to appropriate agent", true),
        ("3", "Context Building", "Load memory and context", true),
        ("4", "LLM Execution", "Send prompt to model", false),
        ("5", "Response Validation", "Check quality and format", false),
        ("6", "Result Storage", "Save to session history", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Execution").font(.headline)
                Spacer()
                if isRunning {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            // Step number
                            Text(steps[i].0)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .frame(width: 28, height: 28)
                                .background(
                                    steps[i].3 ? Color.green : isRunning ? Color.orange : Color.secondary,
                                    in: Circle()
                                )
                                .foregroundStyle(.white)

                            // Step info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(steps[i].1)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(steps[i].2)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // Status
                            if steps[i].3 {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.green)
                            } else if isRunning && i == steps.firstIndex(where: { !$0.3 })! {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "clock.circle")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(
                            steps[i].3 ? Color.green.opacity(0.05) : Color(nsColor: .controlBackgroundColor),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button(isRunning ? "Running..." : "Start Execution") {
                    isRunning = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isRunning = false
                        store.showToast("Workflow completed", type: .success)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunning)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

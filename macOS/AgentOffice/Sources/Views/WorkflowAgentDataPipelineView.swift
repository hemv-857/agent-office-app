// WorkflowAgentDataPipelineView.swift
import SwiftUI

struct WorkflowAgentDataPipelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let stages: [(String, String, String, Color, Bool)] = [
        ("Input", "Receive user prompt", "Parse and validate input", .blue, true),
        ("Context", "Load agent memory and context", "Build prompt with context", .purple, true),
        ("Process", "Route to appropriate agent", "Select model and parameters", .green, true),
        ("Execute", "Send to LLM provider", "Stream response from API", .orange, true),
        ("Validate", "Validate response quality", "Check format and safety", .teal, false),
        ("Output", "Format and return result", "Store in session history", .red, false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Data Pipeline").font(.headline)
                Spacer()
                Text("\(stages.filter { $0.4 }.count)/\(stages.count) active")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(stages.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            // Stage number
                            Text("\(i + 1)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .frame(width: 28, height: 28)
                                .background(stages[i].4 ? stages[i].3 : .secondary, in: Circle())
                                .foregroundStyle(.white)

                            // Stage info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stages[i].0)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(stages[i].1)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                Text(stages[i].2)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            // Status
                            Image(systemName: stages[i].4 ? "checkmark.circle.fill" : "clock.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(stages[i].4 ? .green : .secondary)
                        }
                        .padding(10)
                        .background(stages[i].4 ? stages[i].3.opacity(0.05) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))

                        if i < stages.count - 1 {
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color(nsColor: .separatorColor))
                                    .frame(width: 2, height: 16)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Run Pipeline") {
                    store.showToast("Pipeline executed", type: .success)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 560)
    }
}

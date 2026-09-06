// WorkflowAgentModelPerformanceView.swift
import SwiftUI

struct WorkflowAgentModelPerformanceView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let models: [(String, String, Double, Double, Int)] = [
        ("Claude 3.5 Sonnet", "Anthropic", 3200, 92.5, 847),
        ("GPT-4o", "OpenAI", 3500, 90.1, 623),
        ("GPT-4 Turbo", "OpenAI", 2800, 88.4, 312),
        ("Claude 3 Opus", "Anthropic", 4100, 94.2, 198),
        ("GPT-3.5 Turbo", "OpenAI", 900, 82.3, 1542),
        ("Llama 3 70B", "Ollama", 0, 78.5, 2301),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Model Performance").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("6")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Models")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("92.5%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Top Accuracy")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("5,823")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Total Calls")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(models.indices, id: \.self) { i in
                        ModelPerformanceRow(
                            name: models[i].0,
                            provider: models[i].1,
                            costPer1k: models[i].2,
                            accuracy: models[i].3,
                            calls: models[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 560, height: 460)
    }
}

// MARK: - Model Performance Row
struct ModelPerformanceRow: View {
    let name: String
    let provider: String
    let costPer1k: Double
    let accuracy: Double
    let calls: Int

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(provider)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140, alignment: .leading)

            ProgressView(value: accuracy / 100.0)
                .frame(width: 80)
                .tint(accuracy > 90 ? .green : accuracy > 80 ? .orange : .red)

            Text(String(format: "%.1f%%", accuracy))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 40, alignment: .trailing)

            Text(costPer1k == 0 ? "Free" : "$\(String(format: "%.0f", costPer1k))")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(costPer1k == 0 ? .green : .primary)
                .frame(width: 50, alignment: .trailing)

            Text("\(calls) calls")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 55, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

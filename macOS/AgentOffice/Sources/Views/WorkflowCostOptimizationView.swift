// WorkflowCostOptimizationView.swift
import SwiftUI

struct WorkflowCostOptimizationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Optimization").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Current spending
                    GroupBox("Current Spending") {
                        HStack(spacing: 20) {
                            VStack {
                                Text(String(format: "$%.2f", store.todayCost))
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                Text("Today")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                Text(String(format: "$%.2f", store.dailyBudget))
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.green)
                                Text("Budget")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                let remaining = store.dailyBudget - store.todayCost
                                Text(String(format: "$%.2f", max(0, remaining)))
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundStyle(remaining < 0 ? .red : .blue)
                                Text("Remaining")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(8)
                    }

                    // Optimization tips
                    GroupBox("Optimization Tips") {
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(
                                icon: "arrow.triangle.2.circlepath",
                                title: "Use Local Models",
                                description: "Switch to Ollama for non-critical tasks to save API costs",
                                savings: "Up to 100%"
                            )
                            TipRow(
                                icon: "minus.circle",
                                title: "Reduce Agent Count",
                                description: "Use 2-3 agents instead of all 8 for simple tasks",
                                savings: "50-75%"
                            )
                            TipRow(
                                icon: "text.badge.checkmark",
                                title: "Use Shorter Prompts",
                                description: "Keep prompts concise to reduce token usage",
                                savings: "20-40%"
                            )
                            TipRow(
                                icon: "arrow.down.circle",
                                title: "Batch Operations",
                                description: "Group similar tasks to reduce API calls",
                                savings: "30-50%"
                            )
                            TipRow(
                                icon: "clock",
                                title: "Schedule Off-Peak",
                                description: "Run batch jobs during off-peak hours for lower rates",
                                savings: "10-20%"
                            )
                        }
                        .padding(8)
                    }

                    // Model comparison
                    GroupBox("Model Cost Comparison") {
                        VStack(spacing: 6) {
                            ModelCostRow(model: "Claude 3.5 Sonnet", input: "$3.00/M", output: "$15.00/M", best: "Best quality")
                            ModelCostRow(model: "Claude 3 Haiku", input: "$0.25/M", output: "$1.25/M", best: "Budget option")
                            ModelCostRow(model: "GPT-4o", input: "$2.50/M", output: "$10.00/M", best: "Good balance")
                            ModelCostRow(model: "Ollama Local", input: "Free", output: "Free", best: "No API cost")
                        }
                        .padding(8)
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
        .frame(width: 500, height: 560)
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    let savings: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.green)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 11, weight: .medium))
                    Spacer()
                    Text(savings)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.1), in: Capsule())
                        .foregroundStyle(.green)
                }
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(6)
    }
}

// MARK: - Model Cost Row
struct ModelCostRow: View {
    let model: String
    let input: String
    let output: String
    let best: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(model)
                    .font(.system(size: 11, weight: .medium))
                Text(best)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140, alignment: .leading)
            Text(input)
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 60)
            Text(output)
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 60)
        }
    }
}

// WorkflowAgentCostOptimizationDetailView.swift
import SwiftUI

struct WorkflowAgentCostOptimizationDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let optimizations: [(String, String, String, Double)] = [
        ("Use Ollama for simple tasks", "Route low-complexity tasks to local Ollama", "Saves ~$0.15/day", 0.15),
        ("Batch similar requests", "Group related API calls to reduce overhead", "Saves ~$0.08/day", 0.08),
        ("Cache repeated prompts", "Cache common prompt results for reuse", "Saves ~$0.12/day", 0.12),
        ("Switch to smaller model for review", "Use Haiku for simple code reviews", "Saves ~$0.10/day", 0.10),
        ("Reduce context window", "Trim conversation history to last 10 messages", "Saves ~$0.05/day", 0.05),
    ]

    private let modelCosts: [(String, Double, Double, Double)] = [
        ("Claude 3.5 Sonnet", 0.003, 0.015, 92.0),
        ("Claude 3 Haiku", 0.00025, 0.00125, 85.0),
        ("GPT-4o", 0.005, 0.015, 90.0),
        ("GPT-4o Mini", 0.00015, 0.0006, 82.0),
        ("Ollama (Local)", 0.0, 0.0, 75.0),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Optimization Detail").font(.headline)
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
                    // Potential savings
                    GroupBox("Potential Savings") {
                        VStack(spacing: 6) {
                            ForEach(optimizations.indices, id: \.self) { i in
                                OptimizationDetailRow(
                                    title: optimizations[i].0,
                                    description: optimizations[i].1,
                                    savings: optimizations[i].2,
                                    amount: optimizations[i].3
                                )
                            }
                        }
                        .padding(8)
                    }

                    // Model cost comparison
                    GroupBox("Model Cost Comparison") {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Model").font(.system(size: 9, weight: .semibold)).frame(width: 100)
                                Text("Input").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                                Text("Output").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                                Text("Quality").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)

                            ForEach(modelCosts.indices, id: \.self) { i in
                                HStack {
                                    Text(modelCosts[i].0)
                                        .font(.system(size: 10))
                                        .frame(width: 100, alignment: .leading)
                                    Text(String(format: "$%.4f", modelCosts[i].1))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
                                    Text(String(format: "$%.4f", modelCosts[i].2))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
                                    Text(String(format: "%.0f%%", modelCosts[i].3))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(4)
                    }

                    // Total savings
                    GroupBox("Monthly Savings Estimate") {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text(String(format: "$%.2f", optimizations.map { $0.3 }.reduce(0, +) * 30))
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.green)
                                Text("Per Month")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            VStack(spacing: 4) {
                                Text(String(format: "$%.2f", optimizations.map { $0.3 }.reduce(0, +)))
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.blue)
                                Text("Per Day")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
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
        .frame(width: 520, height: 560)
    }
}

// MARK: - Optimization Detail Row
struct OptimizationDetailRow: View {
    let title: String
    let description: String
    let savings: String
    let amount: Double

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 12))
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(savings)
                .font(.system(size: 9, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.green.opacity(0.1), in: Capsule())
                .foregroundStyle(.green)
        }
    }
}

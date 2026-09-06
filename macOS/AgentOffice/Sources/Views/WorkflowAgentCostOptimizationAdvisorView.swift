// WorkflowAgentCostOptimizationAdvisorView.swift
import SwiftUI

struct WorkflowAgentCostOptimizationAdvisorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let tips: [(String, String, String, Color)] = [
        ("Use Smaller Models", "Switch simple tasks to Haiku to save 60%", "Saves ~$0.40/day", .green),
        ("Enable Caching", "Cache repeated prompts to reduce API calls", "Saves ~$0.25/day", .blue),
        ("Batch Requests", "Group related prompts into single requests", "Saves ~$0.15/day", .purple),
        ("Set Token Limits", "Cap max_tokens per request to prevent runaway costs", "Saves ~$0.10/day", .orange),
        ("Monitor Usage", "Check metrics daily to catch anomalies early", "Prevents surprises", .red),
    ]

    private let modelCosts: [(String, String, String)] = [
        ("Claude 3.5 Sonnet", "$3.00/M input", "$15.00/M output"),
        ("Claude 3 Haiku", "$0.25/M input", "$1.25/M output"),
        ("Claude 3 Opus", "$15.00/M input", "$75.00/M output"),
        ("GPT-4o", "$2.50/M input", "$10.00/M output"),
        ("GPT-4o Mini", "$0.15/M input", "$0.60/M output"),
        ("Ollama (Local)", "Free", "Free"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Optimization Advisor").font(.headline)
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
                    // Tips
                    GroupBox("Optimization Tips") {
                        VStack(spacing: 6) {
                            ForEach(tips.indices, id: \.self) { i in
                                CostOptTipRow(
                                    title: tips[i].0,
                                    detail: tips[i].1,
                                    savings: tips[i].2,
                                    color: tips[i].3
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
                                Text("Input").font(.system(size: 9, weight: .semibold)).frame(maxWidth: .infinity)
                                Text("Output").font(.system(size: 9, weight: .semibold)).frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)

                            ForEach(modelCosts.indices, id: \.self) { i in
                                HStack {
                                    Text(modelCosts[i].0)
                                        .font(.system(size: 10, weight: .medium))
                                        .frame(width: 100, alignment: .leading)
                                    Text(modelCosts[i].1)
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(maxWidth: .infinity)
                                    Text(modelCosts[i].2)
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(4)
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
        .frame(width: 520, height: 520)
    }
}

// MARK: - Cost Optimization Tip Row
struct CostOptTipRow: View {
    let title: String
    let detail: String
    let savings: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(savings)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.green)
        }
        .padding(.vertical, 4)
    }
}

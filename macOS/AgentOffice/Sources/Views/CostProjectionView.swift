// CostProjectionView.swift
import SwiftUI

struct CostProjectionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var dailyPrompts: Double = 10
    @State private var avgTokensPerPrompt: Double = 500
    @State private var daysToProject: Double = 30

    private var costPerToken: Double {
        switch store.selectedProvider {
        case .anthropic: return 0.000003
        case .openai: return 0.000003
        case .ollama: return 0.0
        }
    }

    private var dailyCost: Double {
        dailyPrompts * avgTokensPerPrompt * costPerToken
    }

    private var monthlyCost: Double {
        dailyCost * 30
    }

    private var projectionCost: Double {
        dailyCost * daysToProject
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Projection").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // Inputs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parameters").font(.system(size: 12, weight: .semibold))

                        HStack {
                            Text("Daily Prompts")
                                .font(.system(size: 11))
                            Spacer()
                            Text("\(Int(dailyPrompts))")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        Slider(value: $dailyPrompts, in: 1...100, step: 1)

                        HStack {
                            Text("Avg Tokens/Prompt")
                                .font(.system(size: 11))
                            Spacer()
                            Text("\(Int(avgTokensPerPrompt))")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        Slider(value: $avgTokensPerPrompt, in: 100...4000, step: 100)

                        HStack {
                            Text("Projection Days")
                                .font(.system(size: 11))
                            Spacer()
                            Text("\(Int(daysToProject))")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        Slider(value: $daysToProject, in: 1...365, step: 1)
                    }

                    // Results
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimates").font(.system(size: 12, weight: .semibold))

                        CostRow(label: "Cost per Prompt", value: String(format: "$%.6f", dailyPrompts > 0 ? dailyCost / dailyPrompts : 0))
                        CostRow(label: "Daily Cost", value: String(format: "$%.4f", dailyCost))
                        CostRow(label: "Monthly Cost", value: String(format: "$%.2f", monthlyCost))
                        CostRow(label: "Projection (\(Int(daysToProject)) days)", value: String(format: "$%.2f", projectionCost))

                        Divider()

                        HStack {
                            Text("Daily Budget")
                                .font(.system(size: 11))
                            Spacer()
                            Text(String(format: "$%.2f", store.dailyBudget))
                                .font(.system(size: 11, design: .monospaced))
                        }

                        if monthlyCost > store.dailyBudget * 30 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text("Exceeds monthly budget!")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Token breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Token Usage").font(.system(size: 12, weight: .semibold))
                        CostRow(label: "Daily Tokens", value: formatTokens(dailyPrompts * avgTokensPerPrompt))
                        CostRow(label: "Monthly Tokens", value: formatTokens(dailyPrompts * avgTokensPerPrompt * 30))
                        CostRow(label: "Projection Tokens", value: formatTokens(dailyPrompts * avgTokensPerPrompt * daysToProject))
                    }
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 420, height: 520)
    }

    func formatTokens(_ tokens: Double) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", tokens / 1_000_000)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", tokens / 1_000)
        }
        return "\(Int(tokens))"
    }
}

// MARK: - Cost Row
struct CostRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
            Spacer()
            Text(value)
                .font(.system(size: 11, design: .monospaced))
        }
    }
}

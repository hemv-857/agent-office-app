// CostForecastView.swift
import SwiftUI

struct CostForecastView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var dailyPrompts = 10.0
    @State private var avgTokensPerPrompt = 500.0
    @State private var projectionDays = 30.0

    private var dailyCost: Double {
        let tokens = dailyPrompts * avgTokensPerPrompt
        return tokens * 0.00001
    }

    private var projectedCost: Double {
        dailyCost * projectionDays
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Forecast").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Sliders
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Prompts").font(.system(size: 12, weight: .semibold))
                        Slider(value: $dailyPrompts, in: 1...50, step: 1)
                        Text("\(Int(dailyPrompts)) prompts/day")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Avg Tokens/Prompt").font(.system(size: 12, weight: .semibold))
                        Slider(value: $avgTokensPerPrompt, in: 100...2000, step: 50)
                        Text("\(Int(avgTokensPerPrompt)) tokens")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Projection (days)").font(.system(size: 12, weight: .semibold))
                        Slider(value: $projectionDays, in: 7...90, step: 1)
                        Text("\(Int(projectionDays)) days")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    // Results
                    VStack(spacing: 12) {
                        ForecastRow(label: "Daily Cost", value: String(format: "$%.4f", dailyCost))
                        ForecastRow(label: "Projected Total", value: String(format: "$%.2f", projectedCost))
                        ForecastRow(label: "Monthly Est.", value: String(format: "$%.2f", dailyCost * 30))
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Budget comparison
                    if store.dailyBudget > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget Comparison").font(.system(size: 12, weight: .semibold))
                            HStack {
                                Text("Your daily budget:")
                                Spacer()
                                Text(String(format: "$%.2f", store.dailyBudget))
                                    .font(.system(size: 11, design: .monospaced))
                            }
                            HStack {
                                Text("Estimated daily cost:")
                                Spacer()
                                Text(String(format: "$%.4f", dailyCost))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(dailyCost > store.dailyBudget ? .red : .green)
                            }
                        }
                        .font(.system(size: 11))
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
        .frame(width: 420, height: 500)
    }
}

// MARK: - Forecast Row
struct ForecastRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.system(size: 13, weight: .semibold, design: .monospaced))
        }
    }
}

// WorkflowBudgetForecastView.swift
import SwiftUI

struct WorkflowBudgetForecastView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let forecastDays = ["Today", "Tomorrow", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"]
    private let projectedCosts = [0.08, 0.12, 0.10, 0.15, 0.09, 0.07, 0.11]
    private let dailyAvg = 0.10

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Budget Forecast").font(.headline)
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
                    // Summary
                    HStack(spacing: 16) {
                        ForecastStatCard(title: "Daily Budget", value: String(format: "$%.2f", store.dailyBudget), color: .blue)
                        ForecastStatCard(title: "Today's Cost", value: String(format: "$%.2f", store.todayCost), color: .orange)
                        ForecastStatCard(title: "7-Day Projection", value: String(format: "$%.2f", projectedCosts.reduce(0, +)), color: .purple)
                    }

                    // Forecast chart
                    GroupBox("7-Day Cost Forecast") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(forecastDays.indices, id: \.self) { idx in
                                    VStack(spacing: 4) {
                                        Text(String(format: "$%.2f", projectedCosts[idx]))
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(projectedCosts[idx] > store.dailyBudget ? Color.red : Color.accentColor)
                                            .frame(width: 36, height: CGFloat(projectedCosts[idx] * 300))
                                        Text(forecastDays[idx])
                                            .font(.system(size: 8))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)

                            // Budget line
                            HStack {
                                Rectangle()
                                    .fill(Color.red.opacity(0.5))
                                    .frame(height: 1)
                                Text("Budget: \(String(format: "$%.2f", store.dailyBudget))")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(8)
                    }

                    // Recommendations
                    GroupBox("Recommendations") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForecastRecommendationRow(icon: "checkmark.circle.fill", text: "On track — budget utilization at \(Int(store.todayCost / max(store.dailyBudget, 0.01) * 100))%", color: .green)
                            ForecastRecommendationRow(icon: "lightbulb.fill", text: "Consider using Ollama for simple tasks to reduce costs", color: .yellow)
                            ForecastRecommendationRow(icon: "arrow.down.circle.fill", text: "Reduce agent count for non-complex workflows", color: .blue)
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

// MARK: - Forecast Stat Card
struct ForecastStatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Forecast Recommendation Row
struct ForecastRecommendationRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

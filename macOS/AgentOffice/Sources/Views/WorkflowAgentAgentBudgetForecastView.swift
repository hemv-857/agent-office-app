// WorkflowAgentAgentBudgetForecastView.swift
import SwiftUI

struct WorkflowAgentAgentBudgetForecastView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let months: [(String, Double, Double, Double)] = [
        ("Jan 2026", 45.20, 48.50, 52.00),
        ("Feb 2026", 48.50, 52.10, 56.00),
        ("Mar 2026", 52.10, 56.80, 61.50),
        ("Apr 2026", 56.80, 62.30, 68.00),
        ("May 2026", 62.30, 68.90, 75.50),
        ("Jun 2026", 68.90, 76.20, 83.50),
    ]

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

            // Current budget
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("$200.00")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Monthly Budget")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("$68.90")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Current Spend")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("34%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Used")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(months.indices, id: \.self) { i in
                        ForecastMonthRow(
                            month: months[i].0,
                            actual: i < 2 ? months[i].1 : nil,
                            forecast: months[i].2,
                            budget: 200.0
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
        .frame(width: 480, height: 460)
    }
}

// MARK: - Forecast Month Row
struct ForecastMonthRow: View {
    let month: String
    let actual: Double?
    let forecast: Double
    let budget: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(month)
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 80, alignment: .leading)
                if let actual = actual {
                    Text(String(format: "$%.2f", actual))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.primary)
                        .frame(width: 70, alignment: .trailing)
                } else {
                    Text("—")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 70, alignment: .trailing)
                }
                Text("→")
                    .foregroundStyle(.secondary)
                    .frame(width: 15)
                Text(String(format: "$%.2f", forecast))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.orange)
                    .frame(width: 70, alignment: .trailing)

                ProgressView(value: forecast / budget)
                    .frame(maxWidth: .infinity)
                    .tint(forecast > budget ? .red : forecast > budget * 0.8 ? .orange : .green)
            }

            HStack {
                if let actual = actual {
                    Text("Actual: $\(String(format: "%.2f", actual))")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                } else {
                    Text("Projected: $\(String(format: "%.2f", forecast))")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange)
                }
                Spacer()
                Text("Budget: $\(String(format: "%.0f", budget))")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
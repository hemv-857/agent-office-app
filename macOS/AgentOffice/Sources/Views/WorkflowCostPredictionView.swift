// WorkflowCostPredictionView.swift
import SwiftUI

struct WorkflowCostPredictionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let predictions: [(String, Double, Double, String)] = [
        ("Today", 1.24, 2.00, "On track"),
        ("Tomorrow", 1.18, 2.00, "Under budget"),
        ("This Week", 8.42, 14.00, "On track"),
        ("This Month", 36.80, 60.00, "Under budget"),
        ("Next Month", 42.50, 60.00, "Projected"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Prediction").font(.headline)
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
                CostPredictionStat(label: "Today's Cost", value: "$1.24", color: .green)
                CostPredictionStat(label: "Weekly Projection", value: "$8.42", color: .blue)
                CostPredictionStat(label: "Monthly Est.", value: "$36.80", color: .purple)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(predictions.indices, id: \.self) { i in
                        CostPredictionRow(
                            period: predictions[i].0,
                            predicted: predictions[i].1,
                            budget: predictions[i].2,
                            status: predictions[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Refresh") {
                    store.showToast("Predictions updated", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}

// MARK: - Cost Prediction Stat
struct CostPredictionStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Cost Prediction Row
struct CostPredictionRow: View {
    let period: String
    let predicted: Double
    let budget: Double
    let status: String

    private var ratio: Double { budget > 0 ? predicted / budget : 0 }

    var body: some View {
        HStack(spacing: 10) {
            Text(period)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 80, alignment: .leading)
            ProgressView(value: min(ratio, 1.0))
                .frame(maxWidth: .infinity)
                .tint(ratio > 0.9 ? .red : ratio > 0.7 ? .orange : .green)
            Text(String(format: "$%.2f", predicted))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 50, alignment: .trailing)
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(ratio > 0.9 ? .red.opacity(0.15) : .green.opacity(0.15), in: Capsule())
                .foregroundStyle(ratio > 0.9 ? .red : .green)
                .frame(width: 80)
        }
        .padding(.vertical, 4)
    }
}

// WorkflowAgentCostTrendView.swift
import SwiftUI

struct WorkflowAgentCostTrendView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let dailyData: [(String, Double)] = [
        ("Mon", 1.24), ("Tue", 0.98), ("Wed", 1.42),
        ("Thu", 1.18), ("Fri", 0.85), ("Sat", 0.42), ("Sun", 0.32),
    ]

    private let maxValue = 1.42

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Trend").font(.headline)
                Spacer()
                Text("This week")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                CostTrendStat(label: "This Week", value: "$6.41", color: .blue)
                CostTrendStat(label: "Daily Avg", value: "$0.92", color: .green)
                CostTrendStat(label: "vs Last Week", value: "-12%", color: .green)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Bar chart
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(dailyData.indices, id: \.self) { i in
                        VStack(spacing: 4) {
                            Text(String(format: "$%.2f", dailyData[i].1))
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.secondary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(dailyData[i].1 > 1.0 ? .orange : .blue)
                                .frame(height: CGFloat(dailyData[i].1 / maxValue) * 160)
                            Text(dailyData[i].0)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
                .padding(.top, 16)
            }

            Spacer()

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Trend exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

// MARK: - Trend Stat
struct CostTrendStat: View {
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

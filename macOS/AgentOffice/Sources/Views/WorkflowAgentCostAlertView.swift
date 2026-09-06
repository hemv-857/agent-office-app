// WorkflowAgentCostAlertView.swift
import SwiftUI

struct WorkflowAgentCostAlertView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var dailyBudget = 2.00
    @State private var alertThreshold = 80.0
    @State private var enableAlerts = true

    private let recentAlerts: [(Date, String, Double, Double)] = [
        (Date().addingTimeInterval(-3600), "Daily budget 80% reached", 1.60, 2.00),
        (Date().addingTimeInterval(-7200), "API cost spike detected", 0.45, 0.20),
        (Date().addingTimeInterval(-14400), "Weekly budget 70% reached", 9.80, 14.00),
    ]

    private let currentCost: Double = 0.84
    private let todayBudget: Double = 2.00

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Alerts").font(.headline)
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
                    // Current status
                    GroupBox("Current Status") {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Today's Cost:")
                                    .font(.system(size: 11))
                                Spacer()
                                Text(String(format: "$%.2f / $%.2f", currentCost, todayBudget))
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                            }
                            ProgressView(value: currentCost / todayBudget)
                                .tint(currentCost / todayBudget > 0.8 ? .red : .green)
                            Text(String(format: "%.0f%% of daily budget used", currentCost / todayBudget * 100))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                    }

                    // Settings
                    GroupBox("Alert Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Enable cost alerts", isOn: $enableAlerts)
                            HStack {
                                Text("Daily budget:")
                                Slider(value: $dailyBudget, in: 0.5...10.0, step: 0.5)
                                Text(String(format: "$%.2f", dailyBudget))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                            HStack {
                                Text("Alert threshold:")
                                Slider(value: $alertThreshold, in: 50...95, step: 5)
                                Text(String(format: "%.0f%%", alertThreshold))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                        }
                        .padding(8)
                    }

                    // Recent alerts
                    GroupBox("Recent Alerts") {
                        VStack(spacing: 6) {
                            ForEach(recentAlerts.indices, id: \.self) { i in
                                CostAlertRow(
                                    time: recentAlerts[i].0,
                                    message: recentAlerts[i].1,
                                    cost: recentAlerts[i].2,
                                    limit: recentAlerts[i].3
                                )
                            }
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") {
                    store.showToast("Alert settings saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Cost Alert Row
struct CostAlertRow: View {
    let time: Date
    let message: String
    let cost: Double
    let limit: Double

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(cost > limit * 0.9 ? .red : .orange)
                .frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.system(size: 11, weight: .medium))
                Text(time, style: .relative)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "$%.2f/$%.2f", cost, limit))
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

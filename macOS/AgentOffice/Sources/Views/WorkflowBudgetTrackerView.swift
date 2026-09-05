// WorkflowBudgetTrackerView.swift
import SwiftUI

struct WorkflowBudgetTrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Budget Tracker").font(.headline)
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
                    // Budget overview
                    VStack(spacing: 12) {
                        Text("Daily Budget")
                            .font(.system(size: 12, weight: .semibold))

                        // Circular progress
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            Circle()
                                .trim(from: 0, to: min(store.todayCost / max(store.dailyBudget, 0.01), 1.0))
                                .stroke(store.todayCost > store.dailyBudget ? Color.red : Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            VStack(spacing: 2) {
                                Text(String(format: "$%.4f", store.todayCost))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                Text("of $\(Int(store.dailyBudget))")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }

                    // Stats
                    HStack(spacing: 12) {
                        BudgetStat(title: "Remaining", value: String(format: "$%.4f", max(0, store.dailyBudget - store.todayCost)))
                        BudgetStat(title: "Used", value: String(format: "%.1f%%", min(store.todayCost / max(store.dailyBudget, 0.01) * 100, 100)))
                        BudgetStat(title: "Alerts", value: store.todayCost > store.dailyBudget ? "Over" : "OK")
                    }

                    // Recent costs
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Costs").font(.system(size: 12, weight: .semibold))
                        ForEach(0..<5) { i in
                            HStack {
                                Text("Run #\(100 - i)")
                                    .font(.system(size: 10))
                                Spacer()
                                Text(String(format: "$%.4f", Double.random(in: 0.001...0.01)))
                                    .font(.system(size: 10, design: .monospaced))
                            }
                        }
                    }
                    .padding()
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
        .frame(width: 400, height: 480)
    }
}

// MARK: - Budget Stat
struct BudgetStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

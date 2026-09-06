// WorkflowAgentAgentCostBreakdownView.swift
import SwiftUI

struct WorkflowAgentAgentCostBreakdownView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let breakdown: [(String, Double, Double, Color)] = [
        ("LLM API Calls", 45.20, 68.5, .blue),
        ("Agent Memory", 8.50, 12.9, .green),
        ("Storage", 3.20, 4.8, .orange),
        ("Compute", 6.80, 10.3, .purple),
        ("Network", 2.30, 3.5, .cyan),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Breakdown").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Total
            HStack {
                Text("This Month")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$66.00")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(breakdown.indices, id: \.self) { i in
                        AgentCostBreakdownRow(
                            category: breakdown[i].0,
                            amount: breakdown[i].1,
                            percentage: breakdown[i].2,
                            color: breakdown[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export CSV") {
                    store.showToast("CSV exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 420)
    }
}

// MARK: - Cost Breakdown Row
struct AgentCostBreakdownRow: View {
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(category)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text(String(format: "$%.2f", amount))
                    .font(.system(size: 11, design: .monospaced))
                Text(String(format: "%.1f%%", percentage))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: percentage / 100.0)
                .tint(color)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
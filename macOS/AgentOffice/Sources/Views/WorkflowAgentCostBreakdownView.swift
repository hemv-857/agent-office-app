// WorkflowAgentCostBreakdownView.swift
import SwiftUI

struct WorkflowAgentCostBreakdownView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let categories: [(String, Double, Double, Color)] = [
        ("API Calls", 8.42, 45.7, .blue),
        ("Token Usage", 6.18, 33.6, .purple),
        ("Caching Savings", -2.14, 0.0, .green),
        ("Overhead", 1.20, 6.5, .orange),
        ("Other", 0.54, 2.9, .gray),
    ]

    private let total = 14.20

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Breakdown").font(.headline)
                Spacer()
                Text("This month")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Total
            HStack {
                Text("Total Cost")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text(String(format: "$%.2f", total))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(categories.indices, id: \.self) { i in
                        CostBreakdownRow(
                            name: categories[i].0,
                            amount: categories[i].1,
                            percentage: categories[i].2,
                            color: categories[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Breakdown exported", type: .success)
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

// MARK: - Cost Breakdown Row
struct CostBreakdownRow: View {
    let name: String
    let amount: Double
    let percentage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 24)
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 100, alignment: .leading)
            ProgressView(value: percentage / 100.0)
                .frame(maxWidth: .infinity)
                .tint(color)
            Text(String(format: "$%.2f", amount))
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 50, alignment: .trailing)
            Text(String(format: "%.1f%%", percentage))
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 35, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// WorkflowAgentCostBreakdownDetailView.swift
import SwiftUI

struct WorkflowAgentCostBreakdownDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let categories: [(String, Double, Double, Color)] = [
        ("API Calls", 0.52, 62.0, .blue),
        ("Token Usage", 0.18, 21.0, .purple),
        ("Caching", 0.08, 10.0, .green),
        ("Overhead", 0.06, 7.0, .orange),
    ]

    private let providers: [(String, Double, Double)] = [
        ("Anthropic", 0.42, 50.0),
        ("OpenAI", 0.28, 33.0),
        ("Ollama", 0.0, 0.0),
        ("Other", 0.14, 17.0),
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

            ScrollView {
                VStack(spacing: 12) {
                    // Total
                    GroupBox("Total Cost Today") {
                        HStack {
                            Text(String(format: "$%.2f", categories.map { $0.1 }.reduce(0, +)))
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("of $2.00 budget")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                    }

                    // Categories
                    GroupBox("Cost Categories") {
                        VStack(spacing: 6) {
                            ForEach(categories.indices, id: \.self) { i in
                                CostBreakdownCategoryRow(
                                    name: categories[i].0,
                                    cost: categories[i].1,
                                    percentage: categories[i].2,
                                    color: categories[i].3
                                )
                            }
                        }
                        .padding(8)
                    }

                    // By provider
                    GroupBox("By Provider") {
                        VStack(spacing: 4) {
                            ForEach(providers.indices, id: \.self) { i in
                                HStack {
                                    Text(providers[i].0)
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    Text(String(format: "$%.2f", providers[i].1))
                                        .font(.system(size: 10, design: .monospaced))
                                    Text(String(format: "%.0f%%", providers[i].2))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 35, alignment: .trailing)
                                }
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
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

// MARK: - Cost Breakdown Category Row
struct CostBreakdownCategoryRow: View {
    let name: String
    let cost: Double
    let percentage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 11, weight: .medium))
            Spacer()
            ProgressView(value: percentage / 100.0)
                .frame(width: 80)
                .tint(color)
            Text(String(format: "$%.2f", cost))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 40, alignment: .trailing)
            Text(String(format: "%.0f%%", percentage))
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

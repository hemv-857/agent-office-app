// WorkflowAnalyticsDashboardView.swift
import SwiftUI

struct WorkflowAnalyticsDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Analytics Dashboard").font(.headline)
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
                    // Summary row
                    HStack(spacing: 12) {
                        AnalyticsSummaryCard(title: "Total Runs", value: "\(store.costHistory.count)", icon: "bolt.fill", color: .blue)
                        AnalyticsSummaryCard(title: "Success Rate", value: "94%", icon: "checkmark.circle.fill", color: .green)
                        AnalyticsSummaryCard(title: "Avg Cost", value: String(format: "$%.3f", averageCost), icon: "dollarsign.circle", color: .purple)
                        AnalyticsSummaryCard(title: "Avg Time", value: "2.3s", icon: "clock.fill", color: .orange)
                    }

                    // Mode usage
                    GroupBox("Mode Usage") {
                        VStack(spacing: 6) {
                            ModeUsageRow(mode: "Parallel", count: 45, percentage: 0.45)
                            ModeUsageRow(mode: "Pipeline", count: 30, percentage: 0.30)
                            ModeUsageRow(mode: "Synthesis", count: 15, percentage: 0.15)
                            ModeUsageRow(mode: "Review", count: 10, percentage: 0.10)
                        }
                        .padding(8)
                    }

                    // Cost breakdown
                    GroupBox("Cost Breakdown") {
                        HStack(spacing: 12) {
                            CostPieChart()
                            VStack(alignment: .leading, spacing: 6) {
                                CostLegendRow(color: .blue, label: "Anthropic", value: "$0.85")
                                CostLegendRow(color: .green, label: "OpenAI", value: "$0.42")
                                CostLegendRow(color: .orange, label: "Ollama", value: "$0.00")
                            }
                            .font(.system(size: 10))
                        }
                        .padding(8)
                    }

                    // Agent activity
                    GroupBox("Top Agents") {
                        VStack(spacing: 6) {
                            TopAgentRow(name: "Architect", runs: 24, score: 92)
                            TopAgentRow(name: "Builder", runs: 48, score: 88)
                            TopAgentRow(name: "Reviewer", runs: 32, score: 95)
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
        .frame(width: 550, height: 560)
    }

    private var averageCost: Double {
        guard !store.costHistory.isEmpty else { return 0 }
        return store.costHistory.reduce(0) { $0 + $1.cost } / Double(store.costHistory.count)
    }
}

// MARK: - Analytics Summary Card
struct AnalyticsSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Mode Usage Row
struct ModeUsageRow: View {
    let mode: String
    let count: Int
    let percentage: Double

    var body: some View {
        HStack(spacing: 10) {
            Text(mode)
                .font(.system(size: 11))
                .frame(width: 80, alignment: .leading)
            ProgressView(value: percentage)
                .tint(.accentColor)
            Text("\(count)")
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Cost Pie Chart (simplified)
struct CostPieChart: View {
    var body: some View {
        ZStack {
            Circle().fill(.blue).frame(width: 60, height: 60).mask(
                Path { p in
                    p.move(to: CGPoint(x: 30, y: 30))
                    p.addArc(center: CGPoint(x: 30, y: 30), radius: 30, startAngle: .degrees(0), endAngle: .degrees(230), clockwise: false)
                    p.closeSubpath()
                }
            )
            Circle().fill(.green).frame(width: 60, height: 60).mask(
                Path { p in
                    p.move(to: CGPoint(x: 30, y: 30))
                    p.addArc(center: CGPoint(x: 30, y: 30), radius: 30, startAngle: .degrees(230), endAngle: .degrees(340), clockwise: false)
                    p.closeSubpath()
                }
            )
            Circle().fill(.orange).frame(width: 60, height: 60).mask(
                Path { p in
                    p.move(to: CGPoint(x: 30, y: 30))
                    p.addArc(center: CGPoint(x: 30, y: 30), radius: 30, startAngle: .degrees(340), endAngle: .degrees(360), clockwise: false)
                    p.closeSubpath()
                }
            )
        }
    }
}

// MARK: - Cost Legend Row
struct CostLegendRow: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Top Agent Row
struct TopAgentRow: View {
    let name: String
    let runs: Int
    let score: Int

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 70, alignment: .leading)
            Text("\(runs) runs")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(score)%")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(score >= 90 ? .green : .orange)
        }
    }
}

// WorkflowPerformanceTrendView.swift
import SwiftUI

struct WorkflowPerformanceTrendView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let timeRange = "Last 7 Days"

    private let dailyData: [(String, Int, Double)] = [
        ("Mon", 12, 0.08),
        ("Tue", 18, 0.12),
        ("Wed", 24, 0.16),
        ("Thu", 15, 0.10),
        ("Fri", 30, 0.20),
        ("Sat", 8, 0.05),
        ("Sun", 5, 0.03),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Trend").font(.headline)
                Spacer()
                Text(timeRange)
                    .font(.caption).foregroundStyle(.secondary)
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
                        PerformanceTrendStat(title: "Total Runs", value: "\(dailyData.map { $0.1 }.reduce(0, +))", trend: "+12%", up: true)
                        PerformanceTrendStat(title: "Total Cost", value: String(format: "$%.2f", dailyData.map { $0.2 }.reduce(0, +)), trend: "-5%", up: false)
                        PerformanceTrendStat(title: "Avg per Run", value: String(format: "$%.3f", avgCost), trend: "+2%", up: true)
                    }

                    // Bar chart
                    GroupBox("Daily Activity") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(dailyData, id: \.0) { day in
                                    VStack(spacing: 4) {
                                        Text("\(day.1)")
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.accentColor)
                                            .frame(width: 40, height: CGFloat(day.1) * 2.5)
                                        Text(day.0)
                                            .font(.system(size: 9))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(8)
                    }

                    // Trend by agent
                    GroupBox("Agent Performance Trend") {
                        VStack(spacing: 6) {
                            AgentTrendRow(name: "Architect", thisWeek: 24, lastWeek: 20, change: +20)
                            AgentTrendRow(name: "Builder", thisWeek: 48, lastWeek: 42, change: +14)
                            AgentTrendRow(name: "Reviewer", thisWeek: 32, lastWeek: 28, change: +14)
                            AgentTrendRow(name: "Tester", thisWeek: 18, lastWeek: 15, change: +20)
                            AgentTrendRow(name: "Planner", thisWeek: 12, lastWeek: 10, change: +20)
                        }
                        .padding(8)
                    }

                    // Cost trend
                    GroupBox("Cost Trend") {
                        VStack(spacing: 6) {
                            ForEach(dailyData, id: \.0) { day in
                                HStack {
                                    Text(day.0)
                                        .font(.system(size: 10))
                                        .frame(width: 30, alignment: .leading)
                                    ProgressView(value: day.2 / 0.20)
                                        .tint(day.2 > 0.15 ? .red : .blue)
                                    Text(String(format: "$%.3f", day.2))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 50, alignment: .trailing)
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
        .frame(width: 500, height: 560)
    }

    private var avgCost: Double {
        let total = dailyData.map { $0.2 }.reduce(0, +)
        return total / Double(dailyData.count)
    }
}

// MARK: - Performance Trend Stat
struct PerformanceTrendStat: View {
    let title: String
    let value: String
    let trend: String
    let up: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            HStack(spacing: 3) {
                Image(systemName: up ? "arrow.up" : "arrow.down")
                    .font(.system(size: 8))
                    .foregroundStyle(up ? .green : .red)
                Text(trend)
                    .font(.system(size: 9))
                    .foregroundStyle(up ? .green : .red)
            }
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Agent Trend Row
struct AgentTrendRow: View {
    let name: String
    let thisWeek: Int
    let lastWeek: Int
    let change: Int

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 11))
                .frame(width: 70, alignment: .leading)
            Text("\(thisWeek)")
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 30)
            Text("vs")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text("\(lastWeek)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 30)
            Spacer()
            HStack(spacing: 2) {
                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 8))
                    .foregroundStyle(change >= 0 ? .green : .red)
                Text("\(change >= 0 ? "+" : "")\(change)%")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(change >= 0 ? .green : .red)
            }
        }
    }
}

// AgentMetricsView.swift
import SwiftUI

struct AgentMetricsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedMetric = "usage"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Metrics").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Metric picker
            Picker("", selection: $selectedMetric) {
                Text("Usage").tag("usage")
                Text("Performance").tag("performance")
                Text("Cost").tag("cost")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Metric content
            ScrollView {
                switch selectedMetric {
                case "usage": UsageMetrics()
                case "performance": PerformanceMetrics()
                case "cost": CostMetrics()
                default: UsageMetrics()
                }
            }
            .padding()
        }
        .frame(width: 500, height: 450)
    }
}

// MARK: - Usage Metrics
struct UsageMetrics: View {
    @EnvironmentObject var store: AppStore

    var usageData: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for result in store.results {
            counts[result.agentName, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.map { (name: $0.key, count: $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agent Usage").font(.system(size: 13, weight: .semibold))

            if usageData.isEmpty {
                Text("No usage data yet").foregroundStyle(.secondary)
            } else {
                ForEach(usageData, id: \.name) { item in
                    HStack {
                        Text(item.name)
                            .font(.system(size: 12))
                            .frame(width: 120, alignment: .leading)
                        ProgressView(value: Double(item.count) / Double(usageData.first?.count ?? 1))
                            .frame(maxWidth: .infinity)
                        Text("\(item.count)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }

            Divider()

            Text("Total runs: \(store.results.count)")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Performance Metrics
struct PerformanceMetrics: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance").font(.system(size: 13, weight: .semibold))

            if store.results.isEmpty {
                Text("No results yet").foregroundStyle(.secondary)
            } else {
                let avgTokens = store.results.reduce(0) { $0 + $1.tokensUsed } / max(store.results.count, 1)
                let avgCost = store.results.reduce(0.0) { $0 + $1.costUsd } / Double(max(store.results.count, 1))

                HStack(spacing: 20) {
                    MetricCard(title: "Avg Tokens", value: "\(avgTokens)", icon: "text.alignleft")
                    MetricCard(title: "Avg Cost", value: String(format: "$%.4f", avgCost), icon: "dollarsign.circle")
                    MetricCard(title: "Total Results", value: "\(store.results.count)", icon: "list.bullet")
                }

                Divider()

                Text("Token Distribution").font(.system(size: 12, weight: .medium))

                // Simple token distribution visualization
                let maxTokens = store.results.map { $0.tokensUsed }.max() ?? 1
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(store.results.suffix(20)) { result in
                        VStack {
                            Rectangle()
                                .fill(Color.accentColor.opacity(0.6))
                                .frame(width: 8, height: CGFloat(result.tokensUsed) / CGFloat(max(maxTokens, 1)) * 100)
                            Text(String(result.tokensUsed).prefix(2))
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }
}

// MARK: - Cost Metrics
struct CostMetrics: View {
    @EnvironmentObject var store: AppStore

    var costByAgent: [(name: String, cost: Double)] {
        var costs: [String: Double] = [:]
        for result in store.results {
            costs[result.agentName, default: 0] += result.costUsd
        }
        return costs.sorted { $0.value > $1.value }.map { (name: $0.key, cost: $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cost Analysis").font(.system(size: 13, weight: .semibold))

            if costByAgent.isEmpty {
                Text("No cost data yet").foregroundStyle(.secondary)
            } else {
                let totalCost = costByAgent.reduce(0) { $0 + $1.1 }

                HStack(spacing: 20) {
                    MetricCard(title: "Total Cost", value: String(format: "$%.4f", totalCost), icon: "dollarsign.circle.fill")
                    MetricCard(title: "Agents Used", value: "\(costByAgent.count)", icon: "person.3")
                    MetricCard(title: "Avg per Agent", value: String(format: "$%.4f", totalCost / Double(max(costByAgent.count, 1))), icon: "chart.bar")
                }

                Divider()

                Text("Cost by Agent").font(.system(size: 12, weight: .medium))

                ForEach(costByAgent, id: \.name) { item in
                    HStack {
                        Text(item.name)
                            .font(.system(size: 12))
                            .frame(width: 120, alignment: .leading)
                        ProgressView(value: item.cost / max(costByAgent.first?.cost ?? 0.0001, 0.0001))
                            .frame(maxWidth: .infinity)
                        Text(String(format: "$%.4f", item.cost))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .trailing)
                    }
                }
            }
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

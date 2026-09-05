// AgentPerformanceComparisonView.swift
import SwiftUI

struct AgentPerformanceComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedMetric = "responseTime"

    private let metrics = [
        ("responseTime", "Response Time", "clock"),
        ("tokenUsage", "Token Usage", "text.alignleft"),
        ("costEfficiency", "Cost Efficiency", "dollarsign.circle"),
        ("successRate", "Success Rate", "checkmark.circle"),
        ("usageCount", "Usage Count", "chart.bar"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Performance").font(.headline)
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
                ForEach(metrics, id: \.0) { metric in
                    Label(metric.1, systemImage: metric.2).tag(metric.0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Performance bars
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(store.allAgents) { agent in
                        AgentPerformanceBar(
                            agent: agent,
                            value: getMetricValue(agent: agent, metric: selectedMetric),
                            maxValue: getMaxMetricValue(metric: selectedMetric),
                            metricName: metrics.first { $0.0 == selectedMetric }?.1 ?? ""
                        )
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
        .frame(width: 550, height: 500)
    }

    func getMetricValue(agent: Agent, metric: String) -> Double {
        // Simulated metrics - in production would come from actual usage data
        switch metric {
        case "responseTime": return Double.random(in: 0.5...3.0)
        case "tokenUsage": return Double.random(in: 100...2000)
        case "costEfficiency": return Double.random(in: 0.001...0.05)
        case "successRate": return Double.random(in: 0.7...1.0)
        case "usageCount": return Double(Int.random(in: 5...100))
        default: return 0
        }
    }

    func getMaxMetricValue(metric: String) -> Double {
        switch metric {
        case "responseTime": return 3.0
        case "tokenUsage": return 2000
        case "costEfficiency": return 0.05
        case "successRate": return 1.0
        case "usageCount": return 100
        default: return 1.0
        }
    }
}

// MARK: - Agent Performance Bar
struct AgentPerformanceBar: View {
    let agent: Agent
    let value: Double
    let maxValue: Double
    let metricName: String

    private var percentage: Double {
        min(1.0, value / maxValue)
    }

    private var barColor: Color {
        if percentage < 0.3 { return .green }
        if percentage < 0.7 { return .yellow }
        return .orange
    }

    var body: some View {
        HStack(spacing: 10) {
            Text("\(agent.emoji) \(agent.name)")
                .font(.system(size: 11))
                .frame(width: 120, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(nsColor: .separatorColor).opacity(0.3))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geometry.size.width * percentage, height: 16)
                }
            }
            .frame(height: 16)

            Text(formatValue(value))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }

    func formatValue(_ value: Double) -> String {
        switch metricName {
        case "Response Time": return String(format: "%.1fs", value)
        case "Token Usage": return "\(Int(value))"
        case "Cost Efficiency": return String(format: "$%.4f", value)
        case "Success Rate": return String(format: "%.0f%%", value * 100)
        case "Usage Count": return "\(Int(value))"
        default: return String(format: "%.2f", value)
        }
    }
}

// WorkflowAgentAgentPerformanceComparisonView.swift
import SwiftUI

struct WorkflowAgentPerformanceComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let metrics = ["Latency", "Throughput", "Error Rate", "Memory", "CPU"]

    @State private var selectedMetric = "Latency"
    @State private var selectedAgents = Set(["Architect", "Builder", "Reviewer"])

    private let data: [String: [String: Double]] = [
        "Latency": ["Architect": 1.2, "Builder": 0.8, "Reviewer": 1.5, "Tester": 2.1, "Planner": 1.8, "Security": 3.2],
        "Throughput": ["Architect": 45, "Builder": 85, "Reviewer": 32, "Tester": 28, "Planner": 22, "Security": 15],
        "Error Rate": ["Architect": 0.5, "Builder": 0.8, "Reviewer": 0.3, "Tester": 1.2, "Planner": 0.6, "Security": 0.2],
        "Memory": ["Architect": 128, "Builder": 256, "Reviewer": 96, "Tester": 180, "Planner": 80, "Security": 64],
        "CPU": ["Architect": 15, "Builder": 35, "Reviewer": 12, "Tester": 28, "Planner": 8, "Security": 5],
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Comparison").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Metric picker
            HStack {
                Text("Metric:")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Picker("", selection: $selectedMetric) {
                    ForEach(metrics, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Agent selection
            HStack {
                Text("Agents:")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(agents, id: \.self) { agent in
                            Text(agent)
                                .font(.system(size: 9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(selectedAgents.contains(agent) ? .blue : Color(nsColor: .controlBackgroundColor), in: Capsule())
                                .foregroundStyle(selectedAgents.contains(agent) ? .white : .primary)
                                .onTapGesture {
                                    if selectedAgents.contains(agent) {
                                        selectedAgents.remove(agent)
                                    } else {
                                        selectedAgents.insert(agent)
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Comparison chart
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(agents.filter { selectedAgents.contains($0) }, id: \.self) { agent in
                        let value = data[selectedMetric]?[agent] ?? 0
                        ComparisonChartRow(
                            agent: agent,
                            value: value,
                            maxValue: getMaxValue(for: selectedMetric),
                            label: getLabel(for: selectedMetric)
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }

    private func getMaxValue(for metric: String) -> Double {
        switch metric {
        case "Latency": return 5.0
        case "Throughput": return 100
        case "Error Rate": return 2.0
        case "Memory": return 300
        case "CPU": return 50
        default: return 100
        }
    }

    private func getLabel(for metric: String) -> String {
        switch metric {
        case "Latency": return "s"
        case "Throughput": return "req/s"
        case "Error Rate": return "%"
        case "Memory": return "MB"
        case "CPU": return "%"
        default: return ""
        }
    }
}

// MARK: - Comparison Chart Row
struct ComparisonChartRow: View {
    let agent: String
    let value: Double
    let maxValue: Double
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Text(agent)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                Rectangle()
                    .fill(.blue.opacity(0.3))
                    .frame(width: geo.size.width * min(value / maxValue, 1.0), height: 24)
                    .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 4))
            }
            .frame(height: 24)

            Text(String(format: "%.1f %@", value, label))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 60, alignment: .trailing)
        }
    }
}
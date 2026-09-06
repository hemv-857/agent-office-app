// WorkflowAgentPerformanceComparisonView.swift
import SwiftUI

struct WorkflowAgentPerformanceComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedAgents: Set<String> = ["Architect", "Builder", "Reviewer"]

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    private let metrics: [(String, [String: Double])] = [
        ("Tasks Completed", ["Architect": 24, "Builder": 48, "Reviewer": 32, "Tester": 18, "Planner": 12, "Security": 8]),
        ("Success Rate", ["Architect": 92.8, "Builder": 88.5, "Reviewer": 95.2, "Tester": 90.1, "Planner": 85.3, "Security": 97.0]),
        ("Avg Response Time", ["Architect": 2.3, "Builder": 1.8, "Reviewer": 3.1, "Tester": 2.0, "Planner": 1.5, "Security": 2.8]),
        ("Cost Efficiency", ["Architect": 85.0, "Builder": 78.0, "Reviewer": 92.0, "Tester": 88.0, "Planner": 90.0, "Security": 95.0]),
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

            // Agent selector
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(agents, id: \.self) { agent in
                        Text(agent)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedAgents.contains(agent) ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
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
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Metrics comparison
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(metrics.indices, id: \.self) { i in
                        let metric = metrics[i]
                        GroupBox(metric.0) {
                            VStack(spacing: 6) {
                                ForEach(Array(selectedAgents.sorted()), id: \.self) { agent in
                                    if let value = metric.1[agent] {
                                        HStack(spacing: 8) {
                                            Text(agent)
                                                .font(.system(size: 10, weight: .medium))
                                                .frame(width: 70, alignment: .leading)
                                            ProgressView(value: value / 100.0)
                                                .frame(maxWidth: .infinity)
                                            Text(String(format: "%.1f", value))
                                                .font(.system(size: 9, design: .monospaced))
                                                .frame(width: 40, alignment: .trailing)
                                        }
                                    }
                                }
                            }
                            .padding(8)
                        }
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
        .frame(width: 520, height: 560)
    }
}

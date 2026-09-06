// WorkflowAgentAgentComparisonView.swift
import SwiftUI

struct WorkflowAgentAgentComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let metrics = ["Accuracy", "Speed", "Cost", "Reliability", "Creativity"]

    @State private var selectedMetric = "Accuracy"
    @State private var selectedAgents = Set(["Architect", "Builder"])

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Comparison").font(.headline)
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
                .frame(maxWidth: 240)
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
                        ComparisonBarRow(
                            agent: agent,
                            value: getValue(for: agent, metric: selectedMetric)
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

    private func getValue(for agent: String, metric: String) -> Double {
        let data: [String: [String: Double]] = [
            "Architect": ["Accuracy": 96.2, "Speed": 72.0, "Cost": 0.04, "Reliability": 98.5, "Creativity": 85.0],
            "Builder": ["Accuracy": 94.8, "Speed": 85.0, "Cost": 0.03, "Reliability": 95.0, "Creativity": 78.0],
            "Reviewer": ["Accuracy": 97.1, "Speed": 68.0, "Cost": 0.05, "Reliability": 99.0, "Creativity": 65.0],
            "Tester": ["Accuracy": 93.5, "Speed": 78.0, "Cost": 0.02, "Reliability": 92.0, "Creativity": 60.0],
            "Planner": ["Accuracy": 95.0, "Speed": 70.0, "Cost": 0.03, "Reliability": 97.5, "Creativity": 88.0],
            "Security": ["Accuracy": 98.0, "Speed": 65.0, "Cost": 0.06, "Reliability": 99.5, "Creativity": 55.0],
        ]
        return data[agent]?[metric] ?? 0
    }
}

// MARK: - Comparison Bar Row
struct ComparisonBarRow: View {
    let agent: String
    let value: Double

    var body: some View {
        HStack(spacing: 10) {
            Text(agent)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                Rectangle()
                    .fill(.blue.opacity(0.3))
                    .frame(width: geo.size.width * value / 100.0, height: 20)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            }
            .frame(height: 20)

            Text(String(format: "%.1f", value))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 40, alignment: .trailing)
        }
    }
}
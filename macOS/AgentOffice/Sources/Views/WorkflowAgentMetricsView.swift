// WorkflowAgentMetricsView.swift
import SwiftUI

struct WorkflowAgentMetricsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, String, Double, Color)] = [
        ("Architect", "92%", 0.92, .blue),
        ("Builder", "88%", 0.88, .green),
        ("Reviewer", "95%", 0.95, .purple),
        ("Tester", "90%", 0.90, .orange),
        ("Planner", "85%", 0.85, .yellow),
    ]

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

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(metrics, id: \.0) { metric in
                        AgentMetricRow(
                            name: metric.0,
                            score: metric.1,
                            value: metric.2,
                            color: metric.3
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
        .frame(width: 420, height: 420)
    }
}

// MARK: - Agent Metric Row
struct AgentMetricRow: View {
    let name: String
    let score: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 70, alignment: .leading)
            ProgressView(value: value)
                .tint(color)
                .frame(width: 120)
            Text(score)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .frame(width: 35, alignment: .trailing)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

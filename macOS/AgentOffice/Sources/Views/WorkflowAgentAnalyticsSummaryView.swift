// WorkflowAgentAnalyticsSummaryView.swift
import SwiftUI

struct WorkflowAgentAnalyticsSummaryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let insights: [(String, String, String)] = [
        ("Peak Performance", "Your best workflow: Parallel Research (98.2% success)", "green"),
        ("Cost Efficiency", "Haiku saves 60% on simple tasks vs Sonnet", "blue"),
        ("Token Usage", "Average 2,847 tokens per workflow run", "purple"),
        ("Time Savings", "Workflows save ~3.2 hours/day vs manual", "orange"),
    ]

    private let topAgents: [(String, Int, Double)] = [
        ("Architect", 89, 96.2),
        ("Builder", 124, 94.8),
        ("Reviewer", 98, 97.1),
        ("Tester", 76, 93.5),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Analytics Summary").font(.headline)
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
                    // Key insights
                    GroupBox("Key Insights") {
                        VStack(spacing: 6) {
                            ForEach(insights.indices, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(Color(insights[i].2 == "green" ? .green : insights[i].2 == "blue" ? .blue : insights[i].2 == "purple" ? .purple : .orange))
                                        .frame(width: 8, height: 8)
                                    Text(insights[i].0)
                                        .font(.system(size: 11, weight: .semibold))
                                        .frame(width: 100, alignment: .leading)
                                    Text(insights[i].1)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Top agents
                    GroupBox("Top Performing Agents") {
                        VStack(spacing: 4) {
                            ForEach(topAgents.indices, id: \.self) { i in
                                HStack {
                                    Text(topAgents[i].0)
                                        .font(.system(size: 11, weight: .medium))
                                        .frame(width: 80, alignment: .leading)
                                    Text("\(topAgents[i].1) tasks")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(String(format: "%.1f%%", topAgents[i].2))
                                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(topAgents[i].2 > 95 ? .green : .blue)
                                }
                                .padding(.vertical, 2)
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
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 440)
    }
}

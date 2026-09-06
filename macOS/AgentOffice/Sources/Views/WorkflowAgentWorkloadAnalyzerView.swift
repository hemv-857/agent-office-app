// WorkflowAgentWorkloadAnalyzerView.swift
import SwiftUI

struct WorkflowAgentWorkloadAnalyzerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let currentLoad: [Double] = [0.35, 0.55, 0.45, 0.25, 0.15, 0.20]
    private let weeklyAvg: [Double] = [0.32, 0.48, 0.42, 0.28, 0.18, 0.22]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workload Analyzer").font(.headline)
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
                    // Load comparison
                    GroupBox("Current vs Average Load") {
                        VStack(spacing: 8) {
                            ForEach(agents.indices, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Text(agents[i])
                                        .font(.system(size: 11, weight: .medium))
                                        .frame(width: 70, alignment: .trailing)
                                    VStack(spacing: 2) {
                                        HStack(spacing: 4) {
                                            Text("Now")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.secondary)
                                            ProgressView(value: currentLoad[i])
                                                .frame(maxWidth: .infinity)
                                            Text(String(format: "%.0f%%", currentLoad[i] * 100))
                                                .font(.system(size: 8, design: .monospaced))
                                                .frame(width: 30, alignment: .trailing)
                                        }
                                        HStack(spacing: 4) {
                                            Text("Avg")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.secondary)
                                            ProgressView(value: weeklyAvg[i])
                                                .frame(maxWidth: .infinity)
                                                .tint(.secondary)
                                            Text(String(format: "%.0f%%", weeklyAvg[i] * 100))
                                                .font(.system(size: 8, design: .monospaced))
                                                .foregroundStyle(.secondary)
                                                .frame(width: 30, alignment: .trailing)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Recommendations
                    GroupBox("Recommendations") {
                        VStack(spacing: 6) {
                            WorkloadRecommendationRow(agent: "Builder", recommendation: "Reduce load by 10%", color: .orange)
                            WorkloadRecommendationRow(agent: "Planner", recommendation: "Can absorb more tasks", color: .green)
                            WorkloadRecommendationRow(agent: "Tester", recommendation: "Available for new work", color: .green)
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
        .frame(width: 520, height: 480)
    }
}

// MARK: - Workload Recommendation Row
struct WorkloadRecommendationRow: View {
    let agent: String
    let recommendation: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(agent)
                .font(.system(size: 11, weight: .medium))
            Spacer()
            Text(recommendation)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

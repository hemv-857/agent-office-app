// WorkflowAgentPerformanceView.swift
import SwiftUI

struct WorkflowAgentPerformanceView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let performance: [(String, Int, Int, Double)] = [
        ("Architect", 24, 92, 0.02),
        ("Builder", 48, 88, 0.05),
        ("Reviewer", 32, 95, 0.03),
        ("Tester", 18, 90, 0.02),
        ("Planner", 12, 85, 0.01),
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

            ScrollView {
                VStack(spacing: 10) {
                    // Summary cards
                    HStack(spacing: 12) {
                        AgentPerfStatCard(title: "Tasks", value: "\(performance.map { $0.1 }.reduce(0, +))", icon: "list.bullet", color: .blue)
                        AgentPerfStatCard(title: "Score", value: "90%", icon: "chart.bar.fill", color: .green)
                        AgentPerfStatCard(title: "Cost", value: "$0.13", icon: "dollarsign.circle", color: .purple)
                    }

                    // Per-agent performance
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Per Agent").font(.system(size: 12, weight: .semibold))
                        ForEach(performance, id: \.0) { perf in
                            HStack {
                                Text(perf.0)
                                    .font(.system(size: 11))
                                    .frame(width: 70, alignment: .leading)
                                Text("\(perf.1) tasks")
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 50)
                                Text("\(perf.2)%")
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 35)
                                Text(String(format: "$%.2f", perf.3))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 450, height: 480)
    }
}

// MARK: - AgentPerf Stat Card
struct AgentPerfStatCard: View {
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
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

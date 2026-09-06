// WorkflowAgentWorkloadDistributionView.swift
import SwiftUI

struct WorkflowAgentWorkloadDistributionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let workloads: [Double] = [0.35, 0.55, 0.45, 0.25, 0.15, 0.20]
    private let maxWorkload: Double = 0.55

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workload Distribution").font(.headline)
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
                    // Horizontal bar chart
                    GroupBox("Current Load") {
                        VStack(spacing: 8) {
                            ForEach(agents.indices, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Text(agents[i])
                                        .font(.system(size: 11, weight: .medium))
                                        .frame(width: 70, alignment: .trailing)
                                    ProgressView(value: workloads[i])
                                        .frame(maxWidth: .infinity)
                                        .tint(workloadColor(workloads[i]))
                                    Text(String(format: "%.0f%%", workloads[i] * 100))
                                        .font(.system(size: 10, design: .monospaced))
                                        .frame(width: 40, alignment: .trailing)
                                }
                            }
                        }
                        .padding(8)
                    }

                    // Load balance suggestion
                    GroupBox("Load Balance") {
                        VStack(spacing: 6) {
                            LoadBalanceRow(agent: "Builder", current: "55%", suggestion: "Move 10% → Architect", color: .orange)
                            LoadBalanceRow(agent: "Architect", current: "35%", suggestion: "Can absorb more", color: .green)
                            LoadBalanceRow(agent: "Tester", current: "25%", suggestion: "Available for tasks", color: .green)
                            LoadBalanceRow(agent: "Planner", current: "15%", suggestion: "Underutilized", color: .yellow)
                        }
                        .padding(8)
                    }

                    // Summary
                    HStack(spacing: 16) {
                        WorkloadStat(label: "Avg Load", value: String(format: "%.0f%%", workloads.reduce(0, +) / Double(workloads.count) * 100))
                        WorkloadStat(label: "Peak", value: String(format: "%.0f%%", maxWorkload * 100))
                        WorkloadStat(label: "Underused", value: "\(workloads.filter { $0 < 0.2 }.count)")
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
        .frame(width: 480, height: 520)
    }

    private func workloadColor(_ load: Double) -> Color {
        if load > 0.5 { return .red }
        if load > 0.3 { return .orange }
        return .green
    }
}

// MARK: - Load Balance Row
struct LoadBalanceRow: View {
    let agent: String
    let current: String
    let suggestion: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(agent)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 70, alignment: .leading)
            Text(current)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
            Text(suggestion)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Workload Stat
struct WorkloadStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

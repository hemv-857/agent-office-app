// WorkflowAgentPerformanceDetailView.swift
import SwiftUI

struct WorkflowAgentPerformanceDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let agent: Agent

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(agent.emoji) \(agent.name)").font(.headline)
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
                    // Agent info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Agent Info").font(.system(size: 12, weight: .semibold))
                        HStack {
                            Text("Division:")
                            Spacer()
                            Text(agent.division)
                        }
                        HStack {
                            Text("Role:")
                            Spacer()
                            Text(agent.officeRole)
                        }
                        HStack {
                            Text("Domain:")
                            Spacer()
                            Text(agent.domain.isEmpty ? "General" : agent.domain)
                        }
                    }
                    .font(.system(size: 11))
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Performance metrics
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Performance").font(.system(size: 12, weight: .semibold))
                        PerfMetricRow(label: "Tasks Completed", value: "\(Int.random(in: 10...100))")
                        PerfMetricRow(label: "Success Rate", value: "\(Int.random(in: 80...99))%")
                        PerfMetricRow(label: "Avg Response Time", value: String(format: "%.1fs", Double.random(in: 1...3)))
                        PerfMetricRow(label: "Tokens Used", value: "\(Int.random(in: 1000...10000))")
                        PerfMetricRow(label: "Total Cost", value: String(format: "$%.4f", Double.random(in: 0.01...0.1)))
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Recent activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity").font(.system(size: 12, weight: .semibold))
                        ForEach(0..<3) { i in
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 6, height: 6)
                                Text("Completed task #\(100 - i)")
                                    .font(.system(size: 10))
                                Spacer()
                                Text("\(i + 1)m ago")
                                    .font(.system(size: 9))
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
        .frame(width: 420, height: 480)
    }
}

// MARK: - Perf Metric Row
struct PerfMetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
    }
}

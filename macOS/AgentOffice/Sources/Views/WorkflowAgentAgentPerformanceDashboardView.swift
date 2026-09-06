// WorkflowAgentAgentPerformanceDashboardView.swift
import SwiftUI

struct WorkflowAgentAgentPerformanceDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Dashboard").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Key metrics
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                DashboardMetricCard(title: "Avg Latency", value: "1.8s", trend: "-0.2s", color: .green)
                DashboardMetricCard(title: "Throughput", value: "245/min", trend: "+12", color: .blue)
                DashboardMetricCard(title: "Error Rate", value: "0.8%", trend: "-0.3%", color: .orange)
                DashboardMetricCard(title: "Uptime", value: "99.9%", trend: "+0.1%", color: .purple)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Agent breakdown
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"], id: \.self) { agent in
                        DashboardAgentRow(
                            agent: agent,
                            latency: Double.random(in: 0.5...3.0),
                            throughput: Int.random(in: 10...100),
                            errors: Double.random(in: 0...2),
                            status: ["Healthy", "Busy", "Degraded"].randomElement()!
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
        .frame(width: 560, height: 480)
    }
}

// MARK: - Metric Card
struct DashboardMetricCard: View {
    let title: String
    let value: String
    let trend: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Text(trend)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(trend.hasPrefix("-") ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Dashboard Agent Row
struct DashboardAgentRow: View {
    let agent: String
    let latency: Double
    let throughput: Int
    let errors: Double
    let status: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(agent)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("Latency: \(String(format: "%.1f", latency))s")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Text("Throughput: \(throughput)/min")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Errors: \(String(format: "%.1f", errors))%")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(errors > 1 ? .red : .green)
                .frame(width: 80, alignment: .trailing)

            Text(status)
                .font(.system(size: 9, weight: .medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.15), in: Capsule())
                .foregroundStyle(statusColor)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }

    private var statusColor: Color {
        switch status {
        case "Healthy": return .green
        case "Busy": return .orange
        default: return .red
        }
    }
}
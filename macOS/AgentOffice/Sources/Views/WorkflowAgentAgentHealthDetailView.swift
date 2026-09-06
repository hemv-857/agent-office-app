// WorkflowAgentAgentHealthDetailView.swift
import SwiftUI

struct WorkflowAgentAgentHealthDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, Double, Double, Double, String, [String])] = [
        ("Architect", 96.2, 94.5, 1.2, "Healthy", ["Design review", "API contracts", "Patterns"]),
        ("Builder", 94.8, 96.0, 0.8, "Healthy", ["Implementation", "Tests", "Refactor"]),
        ("Reviewer", 97.1, 98.0, 1.5, "Healthy", ["Code review", "Security", "Performance"]),
        ("Tester", 93.5, 92.0, 2.1, "Degraded", ["Unit tests", "Integration", "E2E"]),
        ("Planner", 95.0, 93.5, 1.8, "Healthy", ["Sprint plan", "Roadmap", "Estimation"]),
        ("Security", 98.0, 99.0, 3.2, "Healthy", ["Audit", "Compliance", "Vuln scan"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Health Detail").font(.headline)
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
                    ForEach(agents.indices, id: \.self) { i in
                        AgentHealthDetailCard(
                            name: agents[i].0,
                            accuracy: agents[i].1,
                            uptime: agents[i].2,
                            latency: agents[i].3,
                            status: agents[i].4,
                            capabilities: agents[i].5
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
        .frame(width: 500, height: 520)
    }
}

// MARK: - Agent Health Detail Card
struct AgentHealthDetailCard: View {
    let name: String
    let accuracy: Double
    let uptime: Double
    let latency: Double
    let status: String
    let capabilities: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text(status)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(statusColor)
            }

            HStack(spacing: 16) {
                MetricMini(label: "Accuracy", value: String(format: "%.1f%%", accuracy), color: accuracy > 95 ? .green : .orange)
                MetricMini(label: "Uptime", value: String(format: "%.1f%%", uptime), color: uptime > 95 ? .green : .orange)
                MetricMini(label: "Latency", value: String(format: "%.1fs", latency), color: latency < 1.5 ? .green : .orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Capabilities")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(capabilities, id: \.self) { cap in
                            Text(cap)
                                .font(.system(size: 8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.blue.opacity(0.15), in: Capsule())
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }

    private var statusColor: Color {
        status == "Healthy" ? .green : .orange
    }
}

// MARK: - Metric Mini
struct MetricMini: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
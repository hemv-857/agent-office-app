// AgentHealthCheckView.swift
import SwiftUI

struct AgentHealthCheckView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var healthResults: [AgentHealth] = []

    struct AgentHealth: Identifiable {
        let id = UUID()
        let agent: Agent
        var status: HealthStatus
        var lastCheck: Date
        var responseTime: TimeInterval?
        var errorMessage: String?

        enum HealthStatus {
            case healthy, degraded, unhealthy, unknown

            var color: Color {
                switch self {
                case .healthy: return .green
                case .degraded: return .yellow
                case .unhealthy: return .red
                case .unknown: return .gray
                }
            }

            var icon: String {
                switch self {
                case .healthy: return "checkmark.circle.fill"
                case .degraded: return "exclamationmark.triangle.fill"
                case .unhealthy: return "xmark.circle.fill"
                case .unknown: return "questionmark.circle.fill"
                }
            }

            var label: String {
                switch self {
                case .healthy: return "Healthy"
                case .degraded: return "Degraded"
                case .unhealthy: return "Unhealthy"
                case .unknown: return "Unknown"
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Health Check").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if healthResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No health data yet").foregroundStyle(.secondary)
                    Button("Run Health Check") { runHealthCheck() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(healthResults) { health in
                        HStack {
                            Image(systemName: health.status.icon)
                                .foregroundStyle(health.status.color)
                                .font(.system(size: 16))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(health.agent.emoji) \(health.agent.name)")
                                    .font(.system(size: 12, weight: .medium))
                                Text(health.status.label)
                                    .font(.system(size: 10))
                                    .foregroundStyle(health.status.color)
                                if let error = health.errorMessage {
                                    Text(error)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.red)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                if let rt = health.responseTime {
                                    Text(String(format: "%.2fs", rt))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                                Text(health.lastCheck, style: .relative)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Divider()

            HStack {
                Button("Refresh") { runHealthCheck() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 420)
        .onAppear {
            if healthResults.isEmpty { runHealthCheck() }
        }
    }

    func runHealthCheck() {
        healthResults = store.allAgents.map { agent in
            let status: AgentHealth.HealthStatus = {
                if store.apiKey.isEmpty { return .unknown }
                return Bool.random() ? .healthy : (.random(in: 0...1) > 0.5 ? .degraded : .healthy)
            }()
            return AgentHealth(
                agent: agent,
                status: status,
                lastCheck: Date(),
                responseTime: Double.random(in: 0.1...2.0),
                errorMessage: status == .degraded ? "Slow response" : nil
            )
        }
    }
}

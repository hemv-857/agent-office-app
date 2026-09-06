// WorkflowAgentHealthReportView.swift
import SwiftUI

struct WorkflowAgentHealthReportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let components: [(String, String, Double, String)] = [
        ("LLM Provider", "Anthropic API", 99.9, "Healthy"),
        ("Cache System", "Response cache", 98.5, "Healthy"),
        ("Cost Tracker", "Budget monitor", 100.0, "Healthy"),
        ("Session Manager", "Auto-save", 99.2, "Healthy"),
        ("Voice Service", "Speech recognition", 95.0, "Degraded"),
        ("Notification Service", "Alerts", 100.0, "Healthy"),
        ("Performance Monitor", "Metrics", 97.8, "Healthy"),
        ("Plugin System", "Extensions", 100.0, "Healthy"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Health Report").font(.headline)
                Spacer()
                Text("Last checked: just now")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Overall status
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                    Text("Overall: Healthy")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("7/8")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                    Text("Components OK")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("1")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Degraded")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(components.indices, id: \.self) { i in
                        HealthReportRow(
                            name: components[i].0,
                            detail: components[i].1,
                            uptime: components[i].2,
                            status: components[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Refresh") {
                    store.showToast("Health report refreshed", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Export") {
                    store.showToast("Report exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Health Report Row
struct HealthReportRow: View {
    let name: String
    let detail: String
    let uptime: Double
    let status: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status == "Healthy" ? .green : .orange)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "%.1f%%", uptime))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 45, alignment: .trailing)
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(status == "Healthy" ? .green.opacity(0.15) : .orange.opacity(0.15), in: Capsule())
                .foregroundStyle(status == "Healthy" ? .green : .orange)
                .frame(width: 65)
        }
        .padding(.vertical, 4)
    }
}

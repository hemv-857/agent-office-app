// WorkflowAgentSystemHealthMonitorView.swift
import SwiftUI

struct WorkflowAgentSystemHealthMonitorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let components: [(String, String, Double, Color)] = [
        ("CPU Usage", "Active", 0.35, .green),
        ("Memory", "Normal", 0.42, .green),
        ("Disk I/O", "Low", 0.15, .green),
        ("Network", "Active", 0.58, .orange),
        ("API Latency", "Normal", 0.28, .green),
        ("Error Rate", "Low", 0.05, .green),
        ("Cache Hit", "Good", 0.72, .blue),
        ("Queue Depth", "Empty", 0.0, .green),
    ]

    private let alerts: [(String, String, Color)] = [
        ("API rate limit approaching (80%)", "warning", .orange),
        ("Memory usage spike detected", "resolved", .green),
        ("Network timeout on Ollama", "resolved", .green),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Health").font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("Healthy")
                        .font(.system(size: 10))
                        .foregroundStyle(.green)
                }
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Components
                    GroupBox("System Components") {
                        VStack(spacing: 6) {
                            ForEach(components.indices, id: \.self) { i in
                                HealthComponentRow(
                                    name: components[i].0,
                                    status: components[i].1,
                                    usage: components[i].2,
                                    color: components[i].3
                                )
                            }
                        }
                        .padding(8)
                    }

                    // Alerts
                    GroupBox("Recent Alerts") {
                        VStack(spacing: 6) {
                            ForEach(alerts.indices, id: \.self) { i in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(alerts[i].2)
                                        .frame(width: 6, height: 6)
                                    Text(alerts[i].0)
                                        .font(.system(size: 10))
                                    Spacer()
                                    Text(alerts[i].1)
                                        .font(.system(size: 8))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(alerts[i].2.opacity(0.15), in: Capsule())
                                        .foregroundStyle(alerts[i].2)
                                }
                            }
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Refresh") {
                    store.showToast("Health refreshed", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Health Component Row
struct HealthComponentRow: View {
    let name: String
    let status: String
    let usage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 90, alignment: .leading)
            ProgressView(value: usage)
                .frame(maxWidth: .infinity)
                .tint(color)
            Text(String(format: "%.0f%%", usage * 100))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 35, alignment: .trailing)
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.15), in: Capsule())
                .foregroundStyle(color)
        }
    }
}

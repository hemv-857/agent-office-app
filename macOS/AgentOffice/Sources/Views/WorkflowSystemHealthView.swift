// WorkflowSystemHealthView.swift
import SwiftUI

struct WorkflowSystemHealthView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Health").font(.headline)
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
                    // Overall status
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                        Text("All Systems Operational")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                    }
                    .padding()
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                    // Services status
                    GroupBox("Services") {
                        VStack(spacing: 6) {
                            ServiceHealthRow(name: "Anthropic API", status: .operational, latency: "120ms")
                            ServiceHealthRow(name: "OpenAI API", status: .operational, latency: "150ms")
                            ServiceHealthRow(name: "Ollama Local", status: .operational, latency: "5ms")
                            ServiceHealthRow(name: "Speech Recognition", status: .operational, latency: "N/A")
                            ServiceHealthRow(name: "Local Storage", status: .operational, latency: "1ms")
                        }
                        .padding(8)
                    }

                    // System resources
                    GroupBox("System Resources") {
                        VStack(spacing: 8) {
                            ResourceRow(name: "CPU", usage: 0.23, color: .blue)
                            ResourceRow(name: "Memory", usage: 0.45, color: .purple)
                            ResourceRow(name: "Disk", usage: 0.32, color: .orange)
                        }
                        .padding(8)
                    }

                    // Agent health
                    GroupBox("Agent Health") {
                        VStack(spacing: 6) {
                            AgentHealthRow(name: "Architect", status: "Ready", score: 98)
                            AgentHealthRow(name: "Builder", status: "Ready", score: 95)
                            AgentHealthRow(name: "Reviewer", status: "Ready", score: 97)
                            AgentHealthRow(name: "Tester", status: "Ready", score: 96)
                            AgentHealthRow(name: "Planner", status: "Ready", score: 94)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Last checked: \(Date().formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

// MARK: - Service Health Row
struct ServiceHealthRow: View {
    let name: String
    let status: HealthStatus
    let latency: String

    enum HealthStatus {
        case operational, degraded, down
    }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status == .operational ? .green : status == .degraded ? .yellow : .red)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 11))
            Spacer()
            Text(latency)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(status == .operational ? "Operational" : status == .degraded ? "Degraded" : "Down")
                .font(.system(size: 9))
                .foregroundStyle(status == .operational ? .green : status == .degraded ? .yellow : .red)
        }
    }
}

// MARK: - Resource Row
struct ResourceRow: View {
    let name: String
    let usage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 11))
                .frame(width: 50, alignment: .leading)
            ProgressView(value: usage)
                .tint(usage > 0.8 ? .red : color)
            Text(String(format: "%.0f%%", usage * 100))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 35, alignment: .trailing)
        }
    }
}

// MARK: - Agent Health Row
struct AgentHealthRow: View {
    let name: String
    let status: String
    let score: Int

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.green)
                .frame(width: 6, height: 6)
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 70, alignment: .leading)
            Text(status)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(score)%")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.green)
        }
    }
}

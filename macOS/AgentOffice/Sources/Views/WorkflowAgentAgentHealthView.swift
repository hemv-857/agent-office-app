// WorkflowAgentAgentHealthView.swift
import SwiftUI

struct WorkflowAgentAgentHealthView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, Double, Double, String)] = [
        ("Architect", 96.2, 98.5, "Healthy"),
        ("Builder", 94.8, 95.0, "Healthy"),
        ("Reviewer", 97.1, 99.0, "Healthy"),
        ("Tester", 93.5, 92.0, "Degraded"),
        ("Planner", 95.0, 97.5, "Healthy"),
        ("Security", 98.0, 99.5, "Healthy"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Health").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("5/6")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Healthy")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("1")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Degraded")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("95.8%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Avg Accuracy")
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
                    ForEach(agents.indices, id: \.self) { i in
                        AgentHealthStatusRow(
                            name: agents[i].0,
                            accuracy: agents[i].1,
                            uptime: agents[i].2,
                            status: agents[i].3
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
        .frame(width: 480, height: 440)
    }
}

// MARK: - Agent Health Row
struct AgentHealthStatusRow: View {
    let name: String
    let accuracy: Double
    let uptime: Double
    let status: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status == "Healthy" ? .green : .orange)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            ProgressView(value: accuracy / 100.0)
                .frame(maxWidth: .infinity)
                .tint(accuracy > 95 ? .green : .orange)
            Text(String(format: "%.1f%%", accuracy))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 40, alignment: .trailing)
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

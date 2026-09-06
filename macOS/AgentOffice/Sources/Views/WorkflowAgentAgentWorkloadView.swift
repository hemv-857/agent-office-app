// WorkflowAgentAgentWorkloadView.swift
import SwiftUI

struct WorkflowAgentAgentWorkloadView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, Int, Int, Int, Double)] = [
        ("Architect", 8, 12, 5, 72.0),
        ("Builder", 15, 8, 3, 85.0),
        ("Reviewer", 5, 18, 2, 68.0),
        ("Tester", 12, 10, 4, 78.0),
        ("Planner", 6, 14, 8, 55.0),
        ("Security", 3, 20, 1, 45.0),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Workload").font(.headline)
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
                StatPill(label: "Active", value: "49", color: .blue)
                WorkloadStatPill(label: "Queued", value: "82", color: .orange)
                WorkloadStatPill(label: "Blocked", value: "23", color: .red)
                WorkloadStatPill(label: "Avg Util.", value: "67%", color: .green)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Table
            ScrollView {
                VStack(spacing: 2) {
                    // Header
                    HStack(spacing: 12) {
                        Text("Agent")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .leading)
                        Text("Active")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .trailing)
                        Text("Queued")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .trailing)
                        Text("Blocked")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .trailing)
                        Text("Utilization")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(agents.indices, id: \.self) { i in
                        WorkloadRow(
                            name: agents[i].0,
                            active: agents[i].1,
                            queued: agents[i].2,
                            blocked: agents[i].3,
                            utilization: agents[i].4
                        )
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 460, height: 460)
    }
}

// MARK: - Stat Pill
struct WorkloadStatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Workload Row
struct WorkloadRow: View {
    let name: String
    let active: Int
    let queued: Int
    let blocked: Int
    let utilization: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 70, alignment: .leading)
            Text("\(active)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.blue)
                .frame(width: 50, alignment: .trailing)
            Text("\(queued)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.orange)
                .frame(width: 50, alignment: .trailing)
            Text("\(blocked)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.red)
                .frame(width: 50, alignment: .trailing)

            ProgressView(value: utilization / 100.0)
                .frame(width: 60)
                .tint(utilization > 80 ? .red : utilization > 60 ? .orange : .green)
            Text(String(format: "%.0f%%", utilization))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 35, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
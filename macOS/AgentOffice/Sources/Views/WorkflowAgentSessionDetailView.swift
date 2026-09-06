// WorkflowAgentSessionDetailView.swift
import SwiftUI

struct WorkflowAgentSessionDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester"]
    private let tasks = 12
    private let duration = "14:32"
    private let cost = "$0.58"
    private let tokens = "8,420"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Detail").font(.headline)
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
                    // Overview
                    GroupBox("Overview") {
                        VStack(spacing: 6) {
                            SessionDetailStatRow(label: "Duration", value: duration)
                            SessionDetailStatRow(label: "Tasks", value: "\(tasks)")
                            SessionDetailStatRow(label: "Cost", value: cost)
                            SessionDetailStatRow(label: "Tokens", value: tokens)
                            SessionDetailStatRow(label: "Agents", value: "\(agents.count)")
                        }
                        .padding(8)
                    }

                    // Agents
                    GroupBox("Participants") {
                        VStack(spacing: 4) {
                            ForEach(agents, id: \.self) { agent in
                                HStack {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 8, height: 8)
                                    Text(agent)
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    Text("Active")
                                        .font(.system(size: 9))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.green.opacity(0.15), in: Capsule())
                                        .foregroundStyle(.green)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(8)
                    }

                    // Notes
                    GroupBox("Session Notes") {
                        Text("Workflow completed successfully. All quality gates passed. Ready for next session.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Session exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

// MARK: - Session Detail Stat Row
struct SessionDetailStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
        }
    }
}

// WorkflowAgentRoleAssignmentMatrixView.swift
import SwiftUI

struct WorkflowAgentRoleAssignmentMatrixView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let roles = ["Lead", "Support", "Observer"]

    private let assignments: [[String]] = [
        ["Lead", "Observer", "Support", "Observer", "Lead", "Observer"],
        ["Observer", "Lead", "Observer", "Observer", "Observer", "Support"],
        ["Support", "Observer", "Lead", "Support", "Observer", "Lead"],
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Role Assignments").font(.headline)
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
                    // Matrix
                    GroupBox("Agent-Role Matrix") {
                        VStack(spacing: 0) {
                            // Header
                            HStack(spacing: 0) {
                                Rectangle().fill(.clear).frame(width: 70, height: 30)
                                ForEach(agents, id: \.self) { agent in
                                    Text(agent.prefix(4).description)
                                        .font(.system(size: 8, weight: .semibold))
                                        .frame(width: 60, height: 30)
                                        .background(.quaternary)
                                }
                            }

                            // Rows
                            ForEach(roles.indices, id: \.self) { roleIdx in
                                HStack(spacing: 0) {
                                    Text(roles[roleIdx])
                                        .font(.system(size: 9, weight: .semibold))
                                        .frame(width: 70, height: 36)
                                        .background(.quaternary)

                                    ForEach(agents.indices, id: \.self) { agentIdx in
                                        let assignment = assignments[roleIdx][agentIdx]
                                        Text(assignment.prefix(3).description)
                                            .font(.system(size: 8, weight: .medium))
                                            .frame(width: 60, height: 36)
                                            .background(
                                                assignment == "Lead" ? Color.accentColor.opacity(0.3) :
                                                assignment == "Support" ? Color.green.opacity(0.2) :
                                                Color(nsColor: .controlBackgroundColor)
                                            )
                                    }
                                }
                            }
                        }
                        .padding(4)
                    }

                    // Legend
                    HStack(spacing: 12) {
                        RoleLegendItem(label: "Lead", color: .accentColor.opacity(0.3))
                        RoleLegendItem(label: "Support", color: .green.opacity(0.2))
                        RoleLegendItem(label: "Observer", color: Color(nsColor: .controlBackgroundColor))
                    }

                    // Summary
                    GroupBox("Role Distribution") {
                        VStack(spacing: 4) {
                            ForEach(roles, id: \.self) { role in
                                let count = assignments.flatMap { $0 }.filter { $0 == role }.count
                                HStack {
                                    Text(role)
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    Text("\(count) assignments")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.secondary)
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
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Role Legend Item
struct RoleLegendItem: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 9))
        }
    }
}

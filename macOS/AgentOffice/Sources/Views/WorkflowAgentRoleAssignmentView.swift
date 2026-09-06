// WorkflowAgentRoleAssignmentView.swift
import SwiftUI

struct WorkflowAgentRoleAssignmentView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var assignments: [String: String] = [:]

    private let roles: [(String, String, String)] = [
        ("System Design", "blueprint", "Architect leads"),
        ("Implementation", "chevron.left.forwardslash.chevron.right", "Builder executes"),
        ("Code Review", "checkmark.magnifyingglass", "Reviewer validates"),
        ("Testing", "testtube.2", "Tester verifies"),
        ("Planning", "list.bullet.clipboard", "Planner organizes"),
        ("Documentation", "doc.text", "Writer documents"),
        ("Security", "lock.shield", "Security hardens"),
        ("DevOps", "server.rack", "DevOps deploys"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Role Assignment").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(roles, id: \.0) { role in
                        RoleAssignmentRow(
                            roleName: role.0,
                            icon: role.1,
                            hint: role.2,
                            assignedAgent: assignments[role.0],
                            agents: store.allAgents,
                            onAssign: { agentName in assignments[role.0] = agentName },
                            onClear: { assignments.removeValue(forKey: role.0) }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(assignments.count)/\(roles.count) roles assigned")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Clear All") { assignments.removeAll() }
                    .buttonStyle(.bordered)
                Button("Apply") {
                    for (role, agentName) in assignments {
                        if let agent = store.allAgents.first(where: { $0.name == agentName }),
                           let deskRole = AgentRole(rawValue: role.lowercased().replacingOccurrences(of: " ", with: "")) {
                            store.seatAgent(agent, at: deskRole)
                        }
                    }
                    store.showToast("Roles assigned", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(assignments.isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 520)
    }
}

// MARK: - Role Assignment Row
struct RoleAssignmentRow: View {
    let roleName: String
    let icon: String
    let hint: String
    let assignedAgent: String?
    let agents: [Agent]
    let onAssign: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(assignedAgent != nil ? .green : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(roleName)
                    .font(.system(size: 12, weight: .semibold))
                Text(hint)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let assigned = assignedAgent {
                Text(assigned)
                    .font(.system(size: 10))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.1), in: Capsule())
                    .foregroundStyle(.green)
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                Menu {
                    ForEach(agents.prefix(10)) { agent in
                        Button(action: { onAssign(agent.name) }) {
                            HStack {
                                Text(agent.emoji)
                                Text(agent.name)
                            }
                        }
                    }
                } label: {
                    Text("Assign")
                        .font(.system(size: 10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())
                }
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

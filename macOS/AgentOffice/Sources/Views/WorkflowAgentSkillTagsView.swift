// WorkflowAgentSkillTagsView.swift
import SwiftUI

struct WorkflowAgentSkillTagsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var agentSkills: [String: Set<String>] = [:]
    @State private var selectedAgent: Agent?
    @State private var newTag = ""

    @State private var availableTags = [
        "Swift", "Python", "TypeScript", "Go", "Rust", "Java",
        "React", "SwiftUI", "UIKit", "Node.js", "FastAPI", "Django",
        "SQL", "GraphQL", "REST", "gRPC", "Docker", "K8s",
        "AWS", "GCP", "Azure", "CI/CD", "Git", "Testing",
        "UI/UX", "API Design", "Security", "DevOps", "ML", "Data",
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Skill Tags").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            HStack(spacing: 12) {
                // Agent picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Agent")
                        .font(.system(size: 12, weight: .semibold))
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(store.allAgents.prefix(12)) { agent in
                                let tags = agentSkills[agent.id]
                                let count = tags?.count ?? 0
                                HStack(spacing: 8) {
                                    Text(agent.emoji).font(.system(size: 14))
                                    Text(agent.name)
                                        .font(.system(size: 11))
                                    Spacer()
                                    Text("\(count)")
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(8)
                                .background(selectedAgent?.id == agent.id ? Color.accentColor.opacity(0.1) : .clear, in: RoundedRectangle(cornerRadius: 6))
                                .onTapGesture { selectedAgent = agent }
                            }
                        }
                    }
                    .frame(width: 180)
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Available tags
                    Text("Available Tags")
                        .font(.system(size: 12, weight: .semibold))
                    FlowLayout(spacing: 4) {
                        ForEach(availableTags, id: \.self) { tag in
                            let isAssigned = agentSkills[selectedAgent?.id ?? ""]?.contains(tag) ?? false
                            Text(tag)
                                .font(.system(size: 9))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(isAssigned ? Color.accentColor.opacity(0.2) : Color(nsColor: .controlBackgroundColor), in: Capsule())
                                .foregroundStyle(isAssigned ? Color.accentColor : .primary)
                                .onTapGesture { toggleTag(tag) }
                        }
                    }

                    // Custom tag
                    HStack(spacing: 6) {
                        TextField("Custom tag...", text: $newTag)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            if !newTag.isEmpty {
                                availableTags.append(newTag)
                                newTag = ""
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    // Current assignment
                    if let agent = selectedAgent {
                        let tags = agentSkills[agent.id] ?? []
                        Text("Assigned: \(tags.count) tags")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 560, height: 480)
    }

    private func toggleTag(_ tag: String) {
        guard let agent = selectedAgent else { return }
        if agentSkills[agent.id] == nil {
            agentSkills[agent.id] = []
        }
        if agentSkills[agent.id]?.contains(tag) == true {
            agentSkills[agent.id]?.remove(tag)
        } else {
            agentSkills[agent.id]?.insert(tag)
        }
    }
}

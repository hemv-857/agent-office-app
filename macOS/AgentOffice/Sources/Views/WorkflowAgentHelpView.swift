// WorkflowAgentHelpView.swift
import SwiftUI

struct WorkflowAgentHelpView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, [String])] = [
        ("Agent Roles", [
            "Architect: System design and architecture",
            "Builder: Code implementation",
            "Reviewer: Code review and quality",
            "Tester: Testing and validation",
            "Planner: Task planning and coordination",
        ]),
        ("Agent Divisions", [
            "Engineering: Technical implementation",
            "Product: Product strategy and design",
            "Marketing: Growth and outreach",
            "Data: Analytics and insights",
        ]),
        ("Custom Agents", [
            "Create agents with custom prompts",
            "Assign specific domains and roles",
            "Track agent performance",
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Guide").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(sections, id: \.0) { section in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(section.0)
                                .font(.system(size: 12, weight: .semibold))
                            ForEach(section.1, id: \.self) { item in
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.secondary)
                                    Text(item)
                                        .font(.system(size: 11))
                                }
                            }
                        }
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
        .frame(width: 420, height: 420)
    }
}

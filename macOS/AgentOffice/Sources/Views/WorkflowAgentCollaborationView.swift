// WorkflowAgentCollaborationView.swift
import SwiftUI

struct WorkflowAgentCollaborationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let collaborations: [(String, String, Int, String)] = [
        ("Architect", "Builder", 45, "Design & Implementation"),
        ("Builder", "Reviewer", 38, "Code Review"),
        ("Reviewer", "Tester", 32, "Quality Assurance"),
        ("Tester", "Planner", 28, "Bug Tracking"),
        ("Planner", "Architect", 25, "Requirements"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Collaborations").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(collaborations, id: \.0) { collab in
                        CollaborationRow(
                            agent1: collab.0,
                            agent2: collab.1,
                            interactions: collab.2,
                            type: collab.3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(collaborations.count) active collaborations")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 420)
    }
}

// MARK: - Collaboration Row
struct CollaborationRow: View {
    let agent1: String
    let agent2: String
    let interactions: Int
    let type: String

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(agent1)
                        .font(.system(size: 11, weight: .medium))
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text(agent2)
                        .font(.system(size: 11, weight: .medium))
                }
                Text(type)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(interactions) interactions")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

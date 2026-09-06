// WorkflowAgentAgentCollaborationView.swift
import SwiftUI

struct WorkflowAgentAgentCollaborationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let pairs: [(String, String, Double)] = [
        ("Architect", "Builder", 0.8),
        ("Builder", "Reviewer", 0.9),
        ("Tester", "Architect", 0.3),
        ("Planner", "Builder", 0.7),
        ("Security", "Reviewer", 0.5),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Collaboration").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(pairs.indices, id: \.self) { i in
                        AgentCollaborationPairRow(
                            agent1: pairs[i].0,
                            agent2: pairs[i].1,
                            strength: pairs[i].2
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
        .frame(width: 440, height: 400)
    }
}

// MARK: - Agent Collaboration Pair Row
struct AgentCollaborationPairRow: View {
    let agent1: String
    let agent2: String
    let strength: Double

    private var strengthColor: Color {
        if strength >= 0.8 { return .green }
        if strength >= 0.5 { return .orange }
        return .red
    }

    private var strengthLabel: String {
        if strength >= 0.8 { return "Strong" }
        if strength >= 0.5 { return "Medium" }
        return "Weak"
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(agent1)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(.secondary)
                .font(.system(size: 10))
            Text(agent2)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            Spacer()
            ProgressView(value: strength)
                .frame(width: 60)
                .tint(strengthColor)
            Text(strengthLabel)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(strengthColor.opacity(0.15), in: Capsule())
                .foregroundStyle(strengthColor)
        }
        .padding(.vertical, 4)
    }
}

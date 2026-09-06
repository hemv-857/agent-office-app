// WorkflowAgentAgentCollaborationHistoryView.swift
import SwiftUI

struct WorkflowAgentAgentCollaborationHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let collaborations: [(String, String, String, Bool)] = [
        ("Architect + Builder", "Parallel Research", "2.4 min", true),
        ("Builder + Reviewer", "Code Review", "5.8 min", true),
        ("Tester + Architect", "Quality Gate", "1.2 min", true),
        ("Planner + Builder", "Pipeline Build", "8.1 min", true),
        ("Security + Reviewer", "Security Audit", "3.6 min", true),
        ("All Agents", "Debate Analysis", "6.4 min", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Collaboration History").font(.headline)
                Spacer()
                Text("\(collaborations.count) sessions")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            List {
                ForEach(collaborations.indices, id: \.self) { i in
                    CollaborationHistoryRow(
                        agents: collaborations[i].0,
                        workflow: collaborations[i].1,
                        duration: collaborations[i].2,
                        success: collaborations[i].3
                    )
                }
            }
            .listStyle(.plain)

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

// MARK: - Collaboration History Row
struct CollaborationHistoryRow: View {
    let agents: String
    let workflow: String
    let duration: String
    let success: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(success ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(agents)
                    .font(.system(size: 11, weight: .semibold))
                Text(workflow)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(duration)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

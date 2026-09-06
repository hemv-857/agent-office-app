// WorkflowAgentAgentCommunicationLogView.swift
import SwiftUI

struct WorkflowAgentAgentCommunicationLogView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let logs: [(String, String, String, String, Color)] = [
        ("10:32:15", "Architect → Builder", "Design approved", "Start implementation", .green),
        ("10:35:22", "Builder → Reviewer", "PR #42 ready", "Please review", .blue),
        ("10:41:03", "Reviewer → Builder", "Changes requested", "Fix naming", .orange),
        ("10:45:18", "Tester → Architect", "Test plan review", "Add edge cases", .purple),
        ("10:50:33", "Security → All", "Security scan done", "No issues found", .green),
        ("10:55:01", "Planner → Builder", "Sprint update", "Priority changed", .cyan),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Communication Log").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(logs.indices, id: \.self) { i in
                        AgentCommLogRow(
                            time: logs[i].0,
                            participants: logs[i].1,
                            subject: logs[i].2,
                            preview: logs[i].3,
                            color: logs[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Clear") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 440)
    }
}

// MARK: - Communication Log Row
struct AgentCommLogRow: View {
    let time: String
    let participants: String
    let subject: String
    let preview: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(time)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(participants)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(subject)
                    .font(.system(size: 11, weight: .medium))
                Text(preview)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
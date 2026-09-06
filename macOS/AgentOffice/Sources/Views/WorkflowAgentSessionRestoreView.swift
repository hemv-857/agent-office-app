// WorkflowAgentSessionRestoreView.swift
import SwiftUI

struct WorkflowAgentSessionRestoreView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let sessions: [(String, String, String, String)] = [
        ("Morning standup", "Today 9:00 AM", "3 agents", "Architect, Builder, Planner"),
        ("Code review batch", "Today 2:00 PM", "2 agents", "Reviewer, Security"),
        ("Feature sprint", "Yesterday 10:00 AM", "4 agents", "Planner, Architect, Builder, Tester"),
        ("Bug triage", "Yesterday 3:00 PM", "3 agents", "Tester, Builder, Reviewer"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Restore").font(.headline)
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
                    ForEach(sessions.indices, id: \.self) { i in
                        SessionRestoreRow(
                            name: sessions[i].0,
                            time: sessions[i].1,
                            agentCount: sessions[i].2,
                            agents: sessions[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Import Session") {
                    store.showToast("Session imported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 400)
    }
}

// MARK: - Session Restore Row
struct SessionRestoreRow: View {
    let name: String
    let time: String
    let agentCount: String
    let agents: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(.green)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                HStack(spacing: 4) {
                    Text(time)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(agentCount)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Text(agents)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Restore") { }
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}

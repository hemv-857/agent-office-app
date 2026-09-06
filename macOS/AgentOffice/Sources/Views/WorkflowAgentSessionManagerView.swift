// WorkflowAgentSessionManagerView.swift
import SwiftUI

struct WorkflowAgentSessionManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedSession = 0

    private let sessions: [(String, String, Int, Double, String)] = [
        ("Session 1", "Pipeline workflow with 4 agents", 12, 0.84, "Active"),
        ("Session 2", "Code review session", 8, 0.42, "Completed"),
        ("Session 3", "Security audit workflow", 6, 0.28, "Completed"),
        ("Session 4", "Sprint planning session", 4, 0.15, "Paused"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Manager").font(.headline)
                Spacer()
                Text("\(sessions.count) sessions")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Session list
            List {
                ForEach(sessions.indices, id: \.self) { i in
                    SessionManagerRow(
                        name: sessions[i].0,
                        description: sessions[i].1,
                        tasks: sessions[i].2,
                        cost: sessions[i].3,
                        status: sessions[i].4,
                        isSelected: selectedSession == i,
                        onSelect: { selectedSession = i }
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            // Actions
            HStack(spacing: 8) {
                Button("New Session") {
                    store.showToast("New session created", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Export") {
                    store.showToast("Session exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Delete") {
                    store.showToast("Session deleted", type: .warning)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Session Manager Row
struct SessionManagerRow: View {
    let name: String
    let description: String
    let tasks: Int
    let cost: Double
    let status: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(status == "Active" ? .green : status == "Paused" ? .orange : .secondary)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(tasks) tasks")
                    .font(.system(size: 9, design: .monospaced))
                Text(String(format: "$%.2f", cost))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(status)
                    .font(.system(size: 8))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(
                        (status == "Active" ? Color.green : status == "Paused" ? Color.orange : Color.secondary)
                            .opacity(0.15), in: Capsule()
                    )
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.05) : .clear)
        .onTapGesture(perform: onSelect)
    }
}

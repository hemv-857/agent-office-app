// WorkflowAgentInteractionView.swift
import SwiftUI

struct WorkflowAgentInteractionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let interactions: [(String, String, String, String)] = [
        ("Architect", "Builder", "Design specs", "Completed"),
        ("Builder", "Reviewer", "Code review", "In Progress"),
        ("Reviewer", "Tester", "Test plan", "Pending"),
        ("Tester", "Planner", "Bug report", "Pending"),
        ("Planner", "Architect", "Requirements", "Completed"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Interactions").font(.headline)
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
                    ForEach(interactions.indices, id: \.self) { index in
                        InteractionRow(
                            from: interactions[index].0,
                            to: interactions[index].1,
                            task: interactions[index].2,
                            status: interactions[index].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(interactions.count) interactions")
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

// MARK: - Interaction Row
struct InteractionRow: View {
    let from: String
    let to: String
    let task: String
    let status: String

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(from)
                        .font(.system(size: 11, weight: .medium))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text(to)
                        .font(.system(size: 11, weight: .medium))
                }
                Text(task)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(status == "Completed" ? Color.green.opacity(0.2) : status == "In Progress" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2), in: Capsule())
                .foregroundStyle(status == "Completed" ? .green : status == "In Progress" ? .blue : .gray)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

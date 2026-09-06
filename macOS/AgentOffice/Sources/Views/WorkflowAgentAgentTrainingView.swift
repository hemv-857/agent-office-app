// WorkflowAgentAgentTrainingView.swift
import SwiftUI

struct WorkflowAgentAgentTrainingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    private let trainingData: [(String, String, Int)] = [
        ("Architect", "Design patterns review", 12),
        ("Builder", "API implementation patterns", 18),
        ("Reviewer", "Code quality standards", 15),
        ("Tester", "Test case generation", 10),
        ("Planner", "Sprint planning templates", 8),
        ("Security", "Security audit checklist", 6),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Training").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("6")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Agents")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("69")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Training Items")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("92%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.purple)
                    Text("Coverage")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(trainingData.indices, id: \.self) { i in
                        AgentTrainingRow(
                            agent: trainingData[i].0,
                            topic: trainingData[i].1,
                            items: trainingData[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Train All") {
                    store.showToast("Training started", type: .success)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

// MARK: - Agent Training Row
struct AgentTrainingRow: View {
    let agent: String
    let topic: String
    let items: Int

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(agent)
                    .font(.system(size: 11, weight: .semibold))
                Text(topic)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(items) items")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

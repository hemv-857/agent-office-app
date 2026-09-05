// WorkflowWorkflowHelpView.swift
import SwiftUI

struct WorkflowWorkflowHelpView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, String, [String])] = [
        ("Parallel Mode", "Run all agents simultaneously", [
            "Best for independent tasks",
            "Fastest completion time",
            "All agents see the same prompt",
        ]),
        ("Pipeline Mode", "Chain agent outputs sequentially", [
            "Each agent builds on previous output",
            "Good for dependent tasks",
            "Creates a chain of responses",
        ]),
        ("Synthesis Mode", "Merge all outputs into one", [
            "All agents run independently",
            "Results are combined at the end",
            "Best for comprehensive analysis",
        ]),
        ("Review Mode", "Peer review between agents", [
            "Agents review each other's work",
            "Catches errors and improvements",
            "Good for code quality",
        ]),
        ("Debate Mode", "Structured discussion format", [
            "Agents take positions and debate",
            "Reaches balanced conclusions",
            "Good for decision-making",
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Guide").font(.headline)
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
                            Text(section.1)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            ForEach(section.2, id: \.self) { item in
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
        .frame(width: 450, height: 450)
    }
}

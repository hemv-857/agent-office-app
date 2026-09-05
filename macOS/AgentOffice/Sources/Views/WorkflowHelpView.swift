// WorkflowHelpView.swift
import SwiftUI

struct WorkflowHelpView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, String)] = [
        ("Getting Started", "Select agents, choose a mode, enter your prompt, and click Run."),
        ("Parallel Mode", "All agents run simultaneously. Best for independent tasks."),
        ("Pipeline Mode", "Agents run sequentially. Output of one feeds into the next."),
        ("Synthesis Mode", "All agents run, then results are merged into one response."),
        ("Review Mode", "Agents review each other's work for quality."),
        ("Debate Mode", "Agents discuss and debate to reach a conclusion."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Help").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sections, id: \.0) { section in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(section.0)
                                .font(.system(size: 12, weight: .semibold))
                            Text(section.1)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
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
        .frame(width: 420, height: 400)
    }
}

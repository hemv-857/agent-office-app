// WorkflowDocumentationView.swift
import SwiftUI

struct WorkflowDocumentationView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, String, [String])] = [
        ("Getting Started", "Quick start guide", [
            "Select agents from the sidebar",
            "Choose a workflow mode",
            "Enter your prompt",
            "Click Run to start",
        ]),
        ("Workflow Modes", "Available modes", [
            "Parallel: All agents run simultaneously",
            "Pipeline: Sequential chain of agents",
            "Synthesis: Merge all outputs",
            "Review: Peer review between agents",
            "Debate: Structured discussion",
        ]),
        ("Keyboard Shortcuts", "Quick actions", [
            "⌘K: Command palette",
            "⌘1-8: Quick actions",
            "⌘⇧S: Save session",
            "⌘⇧P: Save preset",
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Documentation").font(.headline)
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.0)
                                .font(.system(size: 13, weight: .semibold))
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

// ChangelogView.swift
import SwiftUI

struct ChangelogView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Changelog").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ChangelogSection(
                        version: "1.0.0",
                        date: "2026-01-15",
                        changes: [
                            ("feature", "Pure native macOS SwiftUI app"),
                            ("feature", "8-agent office grid with drag-and-drop"),
                            ("feature", "10 workflow modes (parallel, pipeline, synthesis, review, debate, etc.)"),
                            ("feature", "Streaming LLM responses (Anthropic, OpenAI, Ollama)"),
                            ("feature", "Git integration (branch, diff, commit, push)"),
                            ("feature", "Voice input via Speech framework"),
                            ("feature", "Cost tracking with budget alerts"),
                            ("feature", "Agent memory system"),
                            ("feature", "Keyboard shortcuts (⌘K, ⌘1-8, ⌘↑/↓, etc.)"),
                            ("feature", "Session notes and export"),
                            ("feature", "Workflow templates with auto-seating"),
                            ("feature", "Menu bar status indicator"),
                        ]
                    )

                    ChangelogSection(
                        version: "1.1.0",
                        date: "2026-01-20",
                        changes: [
                            ("feature", "Analytics dashboard with trend charts"),
                            ("feature", "Batch run - prompt across multiple agents"),
                            ("feature", "Agent comparison - side-by-side responses"),
                            ("feature", "Conversation history with search"),
                            ("feature", "Prompt templates system"),
                            ("feature", "Task queue with status tracking"),
                            ("feature", "Storage management view"),
                            ("feature", "Plugin system"),
                            ("feature", "Custom command registry"),
                            ("feature", "Workflow chains"),
                            ("feature", "Clipboard history manager"),
                            ("feature", "System diagnostics view"),
                            ("feature", "TTS for agent responses"),
                            ("feature", "Markdown rendering in chat"),
                            ("fix", "Keyboard shortcuts manager build error"),
                        ]
                    )
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
        .frame(width: 500, height: 500)
    }
}

// MARK: - Changelog Section
struct ChangelogSection: View {
    let version: String
    let date: String
    let changes: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("v\(version)")
                    .font(.system(size: 14, weight: .bold))
                Text(date)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ForEach(Array(changes.enumerated()), id: \.offset) { _, change in
                HStack(alignment: .top, spacing: 8) {
                    Text(change.0 == "feature" ? "✨" : "🐛")
                        .font(.system(size: 10))
                    Text(change.1)
                        .font(.system(size: 11))
                }
            }
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

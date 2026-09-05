// WorkflowFAQView.swift
import SwiftUI

struct WorkflowFAQView: View {
    @Environment(\.dismiss) var dismiss

    private let faqs: [(String, String)] = [
        ("What is Agent Office?", "A native macOS app for orchestrating AI agents in a virtual office environment."),
        ("Which LLM providers are supported?", "Anthropic (Claude), OpenAI (GPT), and Ollama (local models)."),
        ("What are workflow modes?", "Different ways agents collaborate: parallel, pipeline, synthesis, review, debate."),
        ("Can I use custom agents?", "Yes, you can create custom agents with custom system prompts."),
        ("How do I save my work?", "Use ⌘⇧S to save sessions, ⌘⇧P to save presets."),
        ("Is my data private?", "All data is stored locally on your Mac. API calls go directly to providers."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FAQ").font(.headline)
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
                    ForEach(faqs.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(faqs[index].0)
                                .font(.system(size: 12, weight: .semibold))
                            Text(faqs[index].1)
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
        .frame(width: 450, height: 420)
    }
}

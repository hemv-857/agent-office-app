// WorkflowAcknowledgementsView.swift
import SwiftUI

struct WorkflowAcknowledgementsView: View {
    @Environment(\.dismiss) var dismiss

    private let acknowledgements: [(String, String)] = [
        ("SwiftUI", "Apple's declarative UI framework"),
        ("Anthropic", "Claude AI model provider"),
        ("OpenAI", "GPT AI model provider"),
        ("Ollama", "Local AI model runtime"),
        ("Speech Framework", "Voice recognition"),
        ("Combine", "Reactive programming"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Acknowledgements").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Agent Office uses the following technologies and services:")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    ForEach(acknowledgements, id: \.0) { ack in
                        HStack {
                            Text(ack.0)
                                .font(.system(size: 11, weight: .medium))
                            Spacer()
                            Text(ack.1)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
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
        .frame(width: 420, height: 380)
    }
}

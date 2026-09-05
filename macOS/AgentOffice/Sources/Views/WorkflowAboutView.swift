// WorkflowAboutView.swift
import SwiftUI

struct WorkflowAboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("About Agent Office").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                // App icon
                Image(systemName: "person.3.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Agent Office")
                    .font(.title2)

                Text("Version 1.1.0")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Text("A native macOS app for orchestrating AI agents in a virtual office environment.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Credits
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Built with:")
                        Spacer()
                        Text("SwiftUI")
                            .font(.system(size: 10, weight: .medium))
                    }
                    HStack {
                        Text("LLM Providers:")
                        Spacer()
                        Text("Anthropic, OpenAI, Ollama")
                            .font(.system(size: 10, weight: .medium))
                    }
                    HStack {
                        Text("License:")
                        Spacer()
                        Text("MIT")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                .font(.system(size: 10))
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 420)
    }
}

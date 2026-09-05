// AgentPersonalityView.swift
import SwiftUI

struct AgentPersonalityView: View {
    let agent: Agent
    @Environment(\.dismiss) var dismiss

    private let traits: [(String, Double, String)] = [
        ("Creativity", 0.8, "sparkles"),
        ("Analytical", 0.9, "brain"),
        ("Communication", 0.7, "bubble.left"),
        ("Technical", 0.95, "hammer"),
        ("Leadership", 0.6, "person.2"),
        ("Detail-Oriented", 0.85, "doc.text.magnifyingglass"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Profile").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Agent header
                    HStack(spacing: 12) {
                        Text(agent.emoji)
                            .font(.system(size: 40))
                        VStack(alignment: .leading) {
                            Text(agent.name)
                                .font(.system(size: 18, weight: .bold))
                            Text(agent.division)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text(agent.officeRole)
                                .font(.system(size: 11))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1), in: Capsule())
                                .foregroundStyle(.blue)
                        }
                        Spacer()
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("About").font(.system(size: 12, weight: .semibold))
                        Text(agent.description)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    // Domain
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Domain").font(.system(size: 12, weight: .semibold))
                        Text(agent.domain)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    // Personality traits
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personality Traits").font(.system(size: 12, weight: .semibold))
                        ForEach(traits, id: \.0) { trait in
                            HStack {
                                Image(systemName: trait.2)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.accentColor)
                                    .frame(width: 20)
                                Text(trait.0)
                                    .font(.system(size: 11))
                                Spacer()
                                ProgressView(value: trait.1)
                                    .frame(width: 100)
                                Text(String(format: "%.0f%%", trait.1 * 100))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 35, alignment: .trailing)
                            }
                        }
                    }

                    // System prompt preview
                    VStack(alignment: .leading, spacing: 4) {
                        Text("System Prompt Preview").font(.system(size: 12, weight: .semibold))
                        Text(String(agent.systemPrompt.prefix(200)) + "...")
                            .font(.system(size: 10, design: .monospaced))
                            .padding(8)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                            .textSelection(.enabled)
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
        .frame(width: 450, height: 500)
    }
}

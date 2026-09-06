// WorkflowTokenUsageView.swift
import SwiftUI

struct WorkflowTokenUsageView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Token Usage").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Summary
                    HStack(spacing: 16) {
                        TokenStat(title: "Total Tokens", value: "\(totalTokens)", icon: "text.word.spacing", color: .blue)
                        TokenStat(title: "Input Tokens", value: "\(inputTokens)", icon: "arrow.up.circle", color: .green)
                        TokenStat(title: "Output Tokens", value: "\(outputTokens)", icon: "arrow.down.circle", color: .orange)
                    }

                    // Context window
                    GroupBox("Context Window") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Used:")
                                ProgressView(value: Double(store.contextWindow.usedTokens) / Double(store.contextWindow.maxTokens))
                                    .tint(store.contextWindow.utilization > 0.8 ? .red : .blue)
                                Text("\(store.contextWindow.usedTokens) / \(store.contextWindow.maxTokens)")
                                    .font(.system(size: 10, design: .monospaced))
                            }
                            Text("Utilization: \(Int(store.contextWindow.utilization * 100))%")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                    }

                    // Token cost breakdown
                    GroupBox("Cost Breakdown") {
                        VStack(spacing: 6) {
                            TokenCostRow(model: "Claude 3.5 Sonnet", input: inputTokens, output: outputTokens, inputPrice: 3.0, outputPrice: 15.0)
                            TokenCostRow(model: "Claude 3 Haiku", input: inputTokens, output: outputTokens, inputPrice: 0.25, outputPrice: 1.25)
                            TokenCostRow(model: "GPT-4o", input: inputTokens, output: outputTokens, inputPrice: 2.5, outputPrice: 10.0)
                        }
                        .padding(8)
                    }

                    // Per-agent usage
                    GroupBox("Per Agent Usage") {
                        VStack(spacing: 6) {
                            ForEach(store.allAgents.prefix(5)) { agent in
                                AgentTokenUsageRow(name: agent.name, emoji: agent.emoji, tokens: Int.random(in: 500...5000))
                            }
                        }
                        .padding(8)
                    }

                    // Tips
                    GroupBox("Token Optimization Tips") {
                        VStack(alignment: .leading, spacing: 6) {
                            TokenTip(text: "Use shorter system prompts to reduce input tokens")
                            TokenTip(text: "Batch similar requests to share context window")
                            TokenTip(text: "Use Haiku for simple tasks, Sonnet for complex ones")
                            TokenTip(text: "Cache frequent queries to avoid reprocessing")
                        }
                        .padding(8)
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
        .frame(width: 520, height: 560)
    }

    private var totalTokens: Int { store.contextWindow.usedTokens + Int.random(in: 1000...3000) }
    private var inputTokens: Int { totalTokens * 7 / 10 }
    private var outputTokens: Int { totalTokens * 3 / 10 }
}

// MARK: - Token Stat
struct TokenStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Token Cost Row
struct TokenCostRow: View {
    let model: String
    let input: Int
    let output: Int
    let inputPrice: Double
    let outputPrice: Double

    private var cost: Double {
        (Double(input) / 1_000_000 * inputPrice) + (Double(output) / 1_000_000 * outputPrice)
    }

    var body: some View {
        HStack {
            Text(model)
                .font(.system(size: 11))
                .frame(width: 120, alignment: .leading)
            Spacer()
            Text(String(format: "$%.6f", cost))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Agent Token Usage Row
struct AgentTokenUsageRow: View {
    let name: String
    let emoji: String
    let tokens: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 14))
            Text(name)
                .font(.system(size: 11))
                .frame(width: 80, alignment: .leading)
            Spacer()
            Text("\(tokens) tokens")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Token Tip
struct TokenTip: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 9))
                .foregroundStyle(.yellow)
            Text(text)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

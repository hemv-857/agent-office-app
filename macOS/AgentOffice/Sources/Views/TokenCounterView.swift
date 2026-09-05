// TokenCounterView.swift
import SwiftUI

struct TokenCounterView: View {
    let text: String
    let model: String

    private var estimatedTokens: Int {
        // Rough estimate: ~4 chars per token for English
        max(1, text.count / 4)
    }

    private var tokenColor: Color {
        if estimatedTokens < 1000 { return .green }
        if estimatedTokens < 4000 { return .yellow }
        if estimatedTokens < 8000 { return .orange }
        return .red
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "text.alignleft")
                .font(.system(size: 9))
            Text("\(estimatedTokens) tokens")
                .font(.system(size: 9, design: .monospaced))
        }
        .foregroundStyle(tokenColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(tokenColor.opacity(0.1), in: Capsule())
    }
}

// MARK: - Cost Estimator
struct CostEstimatorView: View {
    let tokens: Int
    let provider: LLMProvider

    private var estimatedCost: Double {
        switch provider {
        case .anthropic:
            return Double(tokens) * 0.000003
        case .openai:
            return Double(tokens) * 0.000003
        case .ollama:
            return 0.0
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 9))
            Text(String(format: "$%.4f", estimatedCost))
                .font(.system(size: 9, design: .monospaced))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(.quaternary, in: Capsule())
    }
}

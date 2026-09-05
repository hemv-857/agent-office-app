// PromptLengthWarningView.swift
import SwiftUI

struct PromptLengthWarningView: View {
    let prompt: String
    let maxTokens: Int = 4000
    @Environment(\.dismiss) var dismiss

    private var estimatedTokens: Int {
        prompt.count / 4
    }

    private var usagePercent: Double {
        Double(estimatedTokens) / Double(maxTokens) * 100
    }

    private var severity: TokenSeverity {
        if usagePercent > 90 { return .critical }
        if usagePercent > 70 { return .warning }
        return .ok
    }

    enum TokenSeverity {
        case ok, warning, critical

        var color: Color {
            switch self {
            case .ok: return .green
            case .warning: return .orange
            case .critical: return .red
            }
        }

        var icon: String {
            switch self {
            case .ok: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.octagon.fill"
            }
        }

        var message: String {
            switch self {
            case .ok: return "Prompt is within limits"
            case .warning: return "Prompt is getting long"
            case .critical: return "Prompt may exceed context window"
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: severity.icon)
                    .foregroundStyle(severity.color)
                    .font(.system(size: 24))
                Text("Prompt Length Check")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                ProgressView(value: min(usagePercent, 100), total: 100)
                    .tint(severity.color)

                HStack {
                    Text("Estimated: \(estimatedTokens) tokens")
                    Spacer()
                    Text("Max: \(maxTokens)")
                }
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)

                Text(severity.message)
                    .font(.system(size: 11))
                    .foregroundStyle(severity.color)
            }

            if severity != .ok {
                Text("Consider breaking your prompt into smaller parts or removing unnecessary details.")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("OK") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(width: 350)
    }
}

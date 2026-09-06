// WorkflowAgentAgentRateLimitView.swift
import SwiftUI

struct WorkflowAgentAgentRateLimitView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let limits: [(String, String, Int, Int, Double, Color)] = [
        ("Anthropic", "Claude 3.5 Sonnet", 50, 42, 84.0, .orange),
        ("OpenAI", "GPT-4o", 60, 38, 63.3, .blue),
        ("Ollama", "Llama 3 70B", 100, 95, 95.0, .green),
        ("Anthropic", "Claude 3 Opus", 30, 12, 40.0, .yellow),
        ("OpenAI", "GPT-4 Turbo", 50, 28, 56.0, .purple),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Rate Limits").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(limits.indices, id: \.self) { i in
                        RateLimitRow(
                            provider: limits[i].0,
                            model: limits[i].1,
                            limit: limits[i].2,
                            used: limits[i].3,
                            percentage: limits[i].4,
                            color: limits[i].5
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Reset Counters") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 400)
    }
}

// MARK: - Rate Limit Row
struct RateLimitRow: View {
    let provider: String
    let model: String
    let limit: Int
    let used: Int
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(provider)
                    .font(.system(size: 11, weight: .semibold))
                Text(model)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(used) / \(limit)")
                    .font(.system(size: 11, design: .monospaced))
            }

            ProgressView(value: percentage / 100.0)
                .tint(percentage > 90 ? .red : percentage > 70 ? .orange : .green)

            HStack {
                Text("\(Int(percentage))% used")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(limit - used) remaining")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
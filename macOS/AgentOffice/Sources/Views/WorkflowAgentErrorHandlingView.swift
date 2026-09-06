// WorkflowAgentErrorHandlingView.swift
import SwiftUI

struct WorkflowAgentErrorHandlingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let errors: [(String, String, String)] = [
        ("Rate Limit", "API rate limit exceeded. Retry after 60s.", "Retry"),
        ("Token Overflow", "Prompt exceeded max token limit. Truncating.", "Truncate"),
        ("Provider Down", "Anthropic API is temporarily unavailable.", "Switch Provider"),
        ("Budget Exceeded", "Daily budget limit reached. Upgrade or wait.", "Upgrade"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Error Handling").font(.headline)
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
                    ForEach(errors.indices, id: \.self) { i in
                        ErrorHandlingRow(
                            type: errors[i].0,
                            message: errors[i].1,
                            action: errors[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 400)
    }
}

// MARK: - Error Handling Row
struct ErrorHandlingRow: View {
    let type: String
    let message: String
    let action: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.system(size: 11, weight: .semibold))
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action) {}
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding(10)
        .background(.orange.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

// WorkflowAgentWorkflowOptimizationView.swift
import SwiftUI

struct WorkflowAgentWorkflowOptimizationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let suggestions: [(String, String, String)] = [
        ("Enable Caching", "Cache repeated prompts to reduce API calls by ~15%", "Save $0.25/day"),
        ("Use Haiku for Simple Tasks", "Route simple queries to Haiku instead of Sonnet", "Save $0.40/day"),
        ("Batch Similar Prompts", "Group related prompts to reduce overhead tokens", "Save $0.15/day"),
        ("Optimize Token Limits", "Set max_tokens based on expected output length", "Save $0.10/day"),
        ("Monitor Daily Spend", "Set budget alerts to catch cost anomalies early", "Prevent overspend"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Optimization").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("$0.90")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Potential Daily Savings")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("5")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Optimizations Available")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("27%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.purple)
                    Text("Est. Cost Reduction")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(suggestions.indices, id: \.self) { i in
                        WorkflowOptSuggestionRow(
                            title: suggestions[i].0,
                            detail: suggestions[i].1,
                            savings: suggestions[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Apply All") {
                    store.showToast("Optimizations applied", type: .success)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 480)
    }
}

// MARK: - Optimization Suggestion Row
struct WorkflowOptSuggestionRow: View {
    let title: String
    let detail: String
    let savings: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.green.opacity(0.2))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(savings)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.green)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.green.opacity(0.1), in: Capsule())
        }
        .padding(.vertical, 4)
    }
}

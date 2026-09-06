// WorkflowAgentWorkflowOptimizerView.swift
import SwiftUI

struct WorkflowAgentWorkflowOptimizerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let suggestions: [(String, String, String, Double)] = [
        ("Parallelize independent tasks", "Run Builder and Tester in parallel to reduce total time", "Saves ~15 min", 15.0),
        ("Use caching for repeated prompts", "Cache common prompt responses to reduce API calls", "Saves ~$0.12/day", 12.0),
        ("Switch to smaller model for review", "Use Haiku for simple code reviews", "Saves ~$0.08/day", 8.0),
        ("Batch similar operations", "Group related API calls to reduce overhead", "Saves ~10 min", 10.0),
        ("Add error recovery steps", "Add retry logic for transient failures", "Improves reliability", 5.0),
    ]

    private let metrics: [(String, String, String)] = [
        ("Current Duration", "45 min", "Target: 30 min"),
        ("Current Cost", "$0.84/day", "Target: $0.60/day"),
        ("Success Rate", "94.2%", "Target: 98%"),
        ("Parallel Efficiency", "65%", "Target: 85%"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Optimizer").font(.headline)
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
                    // Current metrics
                    GroupBox("Current Performance") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(metrics.indices, id: \.self) { i in
                                OptimizerMetricCard(
                                    label: metrics[i].0,
                                    current: metrics[i].1,
                                    target: metrics[i].2
                                )
                            }
                        }
                        .padding(8)
                    }

                    // Optimization suggestions
                    GroupBox("Optimization Suggestions") {
                        VStack(spacing: 6) {
                            ForEach(suggestions.indices, id: \.self) { i in
                                OptimizationSuggestionRow(
                                    title: suggestions[i].0,
                                    description: suggestions[i].1,
                                    savings: suggestions[i].2
                                )
                            }
                        }
                        .padding(8)
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
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Optimizer Metric Card
struct OptimizerMetricCard: View {
    let label: String
    let current: String
    let target: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(current)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 10, weight: .medium))
            Text(target)
                .font(.system(size: 9))
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Optimization Suggestion Row
struct OptimizationSuggestionRow: View {
    let title: String
    let description: String
    let savings: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 12))
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(savings)
                .font(.system(size: 9, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.green.opacity(0.1), in: Capsule())
                .foregroundStyle(.green)
        }
    }
}

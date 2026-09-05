// WorkflowOptimizationSuggestionsView.swift
import SwiftUI

struct WorkflowOptimizationSuggestionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let suggestions: [(String, String, String)] = [
        ("Use Pipeline Mode", "For sequential tasks, pipeline mode chains agent outputs for better results.", "pipeline"),
        ("Enable Quality Gate", "Add quality validation before final output to catch issues early.", "qualityGate"),
        ("Try Parallel for Speed", "Parallel mode runs all agents simultaneously for faster completion.", "parallel"),
        ("Use Debate for Decisions", "Debate mode helps reach better decisions through structured discussion.", "debate"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Optimization Tips").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(suggestions.indices, id: \.self) { index in
                        SuggestionRow(
                            title: suggestions[index].0,
                            description: suggestions[index].1,
                            mode: suggestions[index].2
                        )
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
        .frame(width: 450, height: 420)
    }
}

// MARK: - Suggestion Row
struct SuggestionRow: View {
    let title: String
    let description: String
    let mode: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(mode)
                .font(.system(size: 9))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.1), in: Capsule())
                .foregroundStyle(.blue)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

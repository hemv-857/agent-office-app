// WorkflowInsightsView.swift
import SwiftUI

struct WorkflowInsightsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let insights: [(String, String, String)] = [
        ("Peak Performance", "Your agents perform best in the morning", "light.max.fill"),
        ("Cost Optimization", "Parallel mode saves 15% on average", "dollarsign.circle"),
        ("Quality Tip", "Review mode catches 92% of issues", "checkmark.shield"),
        ("Usage Pattern", "You run 3x more workflows on weekdays", "calendar"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Insights").font(.headline)
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
                    ForEach(insights, id: \.0) { insight in
                        InsightRow(
                            title: insight.0,
                            message: insight.1,
                            icon: insight.2
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
        .frame(width: 420, height: 400)
    }
}

// MARK: - Insight Row
struct InsightRow: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

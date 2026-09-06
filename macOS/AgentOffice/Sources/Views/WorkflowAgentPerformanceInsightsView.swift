// WorkflowAgentPerformanceInsightsView.swift
import SwiftUI

struct WorkflowAgentPerformanceInsightsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let insights: [(String, String, String)] = [
        ("Peak Efficiency", "Your Parallel workflows run 23% faster than average", "green"),
        ("Cost Optimization", "Switching to Haiku for simple tasks saves $0.40/day", "blue"),
        ("Agent Strength", "Reviewer has 97.1% accuracy — highest among all agents", "purple"),
        ("Time Alert", "Pipeline workflows averaging 8.1 min — consider optimization", "orange"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Insights").font(.headline)
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
                    ForEach(insights.indices, id: \.self) { i in
                        PerformanceInsightRow(
                            title: insights[i].0,
                            detail: insights[i].1,
                            color: insights[i].2
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

// MARK: - Performance Insight Row
struct PerformanceInsightRow: View {
    let title: String
    let detail: String
    let color: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(color == "green" ? .green : color == "blue" ? .blue : color == "purple" ? .purple : .orange))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

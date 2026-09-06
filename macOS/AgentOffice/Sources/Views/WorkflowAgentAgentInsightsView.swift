// WorkflowAgentAgentInsightsView.swift
import SwiftUI

struct WorkflowAgentAgentInsightsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let insights: [(String, String, String)] = [
        ("Builder", "blue", "Most productive agent with 289 tasks completed this week"),
        ("Reviewer", "orange", "Caught 12 potential issues in code reviews"),
        ("Security", "green", "Zero security vulnerabilities found in last 5 scans"),
        ("Tester", "purple", "Test coverage increased from 82% to 94%"),
        ("Architect", "cyan", "Designed 3 new system components this sprint"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Insights").font(.headline)
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
                        AgentInsightRow(
                            agent: insights[i].0,
                            insight: insights[i].2
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
        .frame(width: 460, height: 400)
    }
}

// MARK: - Agent Insight Row
struct AgentInsightRow: View {
    let agent: String
    let insight: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(agent)
                    .font(.system(size: 11, weight: .semibold))
                Text(insight)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}

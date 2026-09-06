// WorkflowAgentSessionAnalyticsView.swift
import SwiftUI

struct WorkflowAgentSessionAnalyticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, String, String, Color)] = [
        ("Total Sessions", "47", "+3 this week", .blue),
        ("Avg Duration", "8.2 min", "-1.4 min", .green),
        ("Success Rate", "96.8%", "+1.2%", .purple),
        ("Avg Cost", "$0.24", "-$0.03", .green),
    ]

    private let recentSessions: [(String, String, Bool)] = [
        ("Parallel Research", "2.4 min", true),
        ("Code Review", "5.8 min", true),
        ("Pipeline Build", "8.1 min", true),
        ("Debate Analysis", "6.4 min", true),
        ("Quality Gate", "1.2 min", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Analytics").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Metrics
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(metrics.indices, id: \.self) { i in
                    SessionAnalyticsStat(
                        label: metrics[i].0,
                        value: metrics[i].1,
                        change: metrics[i].2,
                        color: metrics[i].3
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Recent sessions
            GroupBox("Recent Sessions") {
                VStack(spacing: 4) {
                    ForEach(recentSessions.indices, id: \.self) { i in
                        HStack {
                            Image(systemName: recentSessions[i].2 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(recentSessions[i].2 ? .green : .red)
                            Text(recentSessions[i].0)
                                .font(.system(size: 10, weight: .medium))
                            Spacer()
                            Text(recentSessions[i].1)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

// MARK: - Session Analytics Stat
struct SessionAnalyticsStat: View {
    let label: String
    let value: String
    let change: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(change)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

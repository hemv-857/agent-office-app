// WorkflowAgentPerformanceDashboardView.swift
import SwiftUI

struct WorkflowAgentPerformanceDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let stats: [(String, String, String, Color)] = [
        ("Tasks Today", "12", "+3 from yesterday", .green),
        ("Avg Response", "2.1s", "-0.3s improvement", .blue),
        ("Success Rate", "94.2%", "+1.8% this week", .green),
        ("Cost Today", "$0.84", "42% of budget", .orange),
        ("Active Agents", "4", "2 idle", .green),
        ("Queue Depth", "3", "2 high priority", .orange),
    ]

    private let recentActivity: [(String, String, String, Color)] = [
        ("Architect", "Completed system design review", "2 min ago", .green),
        ("Builder", "Pushed code for API endpoints", "5 min ago", .blue),
        ("Reviewer", "Approved PR #42", "12 min ago", .green),
        ("Tester", "Started regression tests", "15 min ago", .orange),
        ("Security", "Completed vulnerability scan", "20 min ago", .green),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Dashboard").font(.headline)
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
                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(stats.indices, id: \.self) { i in
                            PerformanceDashboardStat(
                                label: stats[i].0,
                                value: stats[i].1,
                                detail: stats[i].2,
                                color: stats[i].3
                            )
                        }
                    }

                    // Recent activity
                    GroupBox("Recent Activity") {
                        VStack(spacing: 6) {
                            ForEach(recentActivity.indices, id: \.self) { i in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(recentActivity[i].3)
                                        .frame(width: 6, height: 6)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(recentActivity[i].0)
                                            .font(.system(size: 11, weight: .semibold))
                                        Text(recentActivity[i].1)
                                            .font(.system(size: 10))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(recentActivity[i].2)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(8)
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
        .frame(width: 520, height: 520)
    }
}

// MARK: - Performance Dashboard Stat
struct PerformanceDashboardStat: View {
    let label: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
            Text(detail)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

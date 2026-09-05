// AnalyticsDashboardView.swift
import SwiftUI

struct AnalyticsDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeRange = "week"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Analytics Dashboard").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Time range picker
            Picker("", selection: $selectedTimeRange) {
                Text("Day").tag("day")
                Text("Week").tag("week")
                Text("Month").tag("month")
                Text("All").tag("all")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Dashboard content
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 16) {
                    // Total workflows
                    DashboardCard(
                        title: "Total Workflows",
                        value: "\(WorkflowAnalyticsService.shared.analytics.totalWorkflows)",
                        icon: "arrow.triangle.2.circlepath",
                        color: .blue
                    )

                    // Total tokens
                    DashboardCard(
                        title: "Total Tokens",
                        value: formatTokens(WorkflowAnalyticsService.shared.analytics.totalTokens),
                        icon: "text.alignleft",
                        color: .green
                    )

                    // Total cost
                    DashboardCard(
                        title: "Total Cost",
                        value: String(format: "$%.2f", WorkflowAnalyticsService.shared.analytics.totalCost),
                        icon: "dollarsign.circle",
                        color: .orange
                    )

                    // Success rate
                    DashboardCard(
                        title: "Success Rate",
                        value: String(format: "%.1f%%", WorkflowAnalyticsService.shared.analytics.successRate * 100),
                        icon: "checkmark.circle",
                        color: .purple
                    )

                    // Most used mode
                    DashboardCard(
                        title: "Most Used Mode",
                        value: WorkflowAnalyticsService.shared.analytics.mostUsedMode.isEmpty ? "N/A" : WorkflowAnalyticsService.shared.analytics.mostUsedMode.capitalized,
                        icon: "sparkles",
                        color: .cyan
                    )

                    // Most used agent
                    DashboardCard(
                        title: "Most Active Agent",
                        value: WorkflowAnalyticsService.shared.analytics.mostUsedAgent.isEmpty ? "N/A" : WorkflowAnalyticsService.shared.analytics.mostUsedAgent,
                        icon: "person.circle",
                        color: .pink
                    )
                }
                .padding()

                // Daily trend chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Trend").font(.system(size: 13, weight: .semibold))
                    TrendChart(data: getDailyTrend())
                        .frame(height: 150)
                }
                .padding()

                // Agent performance
                VStack(alignment: .leading, spacing: 8) {
                    Text("Agent Performance").font(.system(size: 13, weight: .semibold))
                    ForEach(getAgentPerformance(), id: \.0) { agent in
                        HStack {
                            Text(agent.0)
                                .font(.system(size: 11))
                                .frame(width: 100, alignment: .leading)
                            ProgressView(value: agent.1 / 1000)
                                .frame(maxWidth: .infinity)
                            Text("\(Int(agent.1))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export Analytics") {
                    exportAnalytics()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }

    func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000)
        }
        return "\(tokens)"
    }

    func getDailyTrend() -> [(String, Double)] {
        let trend = WorkflowAnalyticsService.shared.getTrend(days: 7)
        return trend.map { (formatDate($0.date), Double($0.workflows)) }
    }

    func getAgentPerformance() -> [(String, Double)] {
        return WorkflowAnalyticsService.shared.getAgentPerformance().prefix(10).map { ($0.0, $0.1) }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    func exportAnalytics() {
        if let data = WorkflowAnalyticsService.shared.exportAnalytics() {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "analytics-\(formatDate(Date())).json"

            if panel.runModal() == .OK, let url = panel.url {
                try? data.write(to: url)
            }
        }
    }
}

// MARK: - Dashboard Card
struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Spacer()
            }
            HStack {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                Spacer()
            }
            HStack {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Trend Chart
struct TrendChart: View {
    let data: [(String, Double)]

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(data, id: \.0) { item in
                VStack {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.6))
                        .frame(width: 20, height: CGFloat(item.1) * 20)
                    Text(item.0)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

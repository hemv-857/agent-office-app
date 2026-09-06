// WorkflowAgentPerformanceDashboardDetailView.swift
import SwiftUI

struct WorkflowAgentPerformanceDashboardDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, String, String, Color)] = [
        ("Tasks Today", "12", "+3 from yesterday", .green),
        ("Avg Response", "2.1s", "-0.3s improvement", .blue),
        ("Success Rate", "94.2%", "+1.8% this week", .green),
        ("Cost Today", "$0.84", "42% of budget", .orange),
        ("Active Agents", "4", "2 idle", .green),
        ("Queue Depth", "3", "2 high priority", .orange),
    ]

    private let hourlyData: [(String, Double)] = [
        ("9am", 0.12), ("10am", 0.18), ("11am", 0.22), ("12pm", 0.08),
        ("1pm", 0.15), ("2pm", 0.20), ("3pm", 0.09), ("4pm", 0.0),
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
                        ForEach(metrics.indices, id: \.self) { i in
                            PerformanceDashboardDetailStat(
                                label: metrics[i].0,
                                value: metrics[i].1,
                                detail: metrics[i].2,
                                color: metrics[i].3
                            )
                        }
                    }

                    // Hourly chart
                    GroupBox("Hourly Activity") {
                        HStack(alignment: .bottom, spacing: 6) {
                            ForEach(hourlyData.indices, id: \.self) { i in
                                VStack(spacing: 4) {
                                    Text(String(format: "$%.2f", hourlyData[i].1))
                                        .font(.system(size: 7, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.accentColor.opacity(hourlyData[i].1 > 0.15 ? 1 : 0.5))
                                        .frame(width: 28, height: max(hourlyData[i].1 * 200, 4))
                                    Text(hourlyData[i].0)
                                        .font(.system(size: 8))
                                }
                            }
                        }
                        .frame(height: 120)
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

// MARK: - Performance Dashboard Detail Stat
struct PerformanceDashboardDetailStat: View {
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

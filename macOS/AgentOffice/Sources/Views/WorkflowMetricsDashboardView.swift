// WorkflowMetricsDashboardView.swift
import SwiftUI

struct WorkflowMetricsDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, String, String, Color)] = [
        ("Total Workflows", "247", "+12 today", .blue),
        ("Success Rate", "94.7%", "+2.1% vs last week", .green),
        ("Avg Duration", "4.2 min", "-0.8 min improvement", .purple),
        ("Total Tokens", "1.2M", "+89K today", .orange),
        ("Total Cost", "$18.42", "$2.14 today", .green),
        ("Active Agents", "6", "All healthy", .blue),
    ]

    private let workflowTypes: [(String, Int, Double)] = [
        ("Parallel", 45, 3.2),
        ("Pipeline", 38, 5.8),
        ("Review", 32, 2.1),
        ("Debate", 28, 6.4),
        ("Synthesis", 25, 4.5),
        ("Quality Gate", 22, 1.8),
        ("Conditional", 18, 3.9),
        ("Collab", 15, 5.2),
        ("Builder", 12, 4.1),
        ("Pipeline-Approval", 10, 7.2),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Metrics").font(.headline)
                Spacer()
                Text("Last 30 days")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Stat cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(metrics.indices, id: \.self) { i in
                            MetricsStatCard(
                                label: metrics[i].0,
                                value: metrics[i].1,
                                subtitle: metrics[i].2,
                                color: metrics[i].3
                            )
                        }
                    }

                    // Workflow type breakdown
                    GroupBox("Workflow Type Breakdown") {
                        VStack(spacing: 4) {
                            ForEach(workflowTypes.indices, id: \.self) { i in
                                HStack {
                                    Text(workflowTypes[i].0)
                                        .font(.system(size: 10, weight: .medium))
                                        .frame(width: 100, alignment: .leading)
                                    ProgressView(value: Double(workflowTypes[i].1) / 45.0)
                                        .frame(maxWidth: .infinity)
                                    Text("\(workflowTypes[i].1)")
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 25)
                                    Text(String(format: "%.1f min", workflowTypes[i].2))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 45, alignment: .trailing)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export") {
                    store.showToast("Metrics exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 560, height: 520)
    }
}

// MARK: - Metrics Stat Card
struct MetricsStatCard: View {
    let label: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(subtitle)
                .font(.system(size: 8))
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

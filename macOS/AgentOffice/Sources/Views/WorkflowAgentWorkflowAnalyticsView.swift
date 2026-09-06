// WorkflowAgentWorkflowAnalyticsView.swift
import SwiftUI

struct WorkflowAgentWorkflowAnalyticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let workflows: [(String, Int, Double, Double, String)] = [
        ("Pipeline", 24, 2.1, 85.0, "stable"),
        ("Parallel", 18, 1.8, 92.0, "improving"),
        ("Review", 32, 2.5, 78.0, "declining"),
        ("Debate", 12, 3.2, 88.0, "stable"),
        ("Synthesis", 8, 2.8, 90.0, "improving"),
    ]

    private let stats: [(String, String, Color)] = [
        ("Total Runs", "94", .blue),
        ("Avg Duration", "2.5 min", .green),
        ("Success Rate", "86.8%", .green),
        ("Cost per Run", "$0.009", .orange),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Analytics").font(.headline)
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
                    // Summary stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(stats.indices, id: \.self) { i in
                            WorkflowAnalyticsStat(
                                label: stats[i].0,
                                value: stats[i].1,
                                color: stats[i].2
                            )
                        }
                    }

                    // Workflow breakdown
                    GroupBox("Workflow Performance") {
                        VStack(spacing: 4) {
                            // Header
                            HStack {
                                Text("Workflow").font(.system(size: 9, weight: .semibold)).frame(width: 70)
                                Text("Runs").font(.system(size: 9, weight: .semibold)).frame(width: 40, alignment: .trailing)
                                Text("Avg Time").font(.system(size: 9, weight: .semibold)).frame(width: 60, alignment: .trailing)
                                Text("Success").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                                Text("Trend").font(.system(size: 9, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)

                            ForEach(workflows.indices, id: \.self) { i in
                                HStack {
                                    Text(workflows[i].0)
                                        .font(.system(size: 10, weight: .medium))
                                        .frame(width: 70, alignment: .leading)
                                    Text("\(workflows[i].1)")
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 40, alignment: .trailing)
                                    Text(String(format: "%.1fm", workflows[i].2))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 60, alignment: .trailing)
                                    Text(String(format: "%.0f%%", workflows[i].3))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
                                    Text(workflows[i].4)
                                        .font(.system(size: 8))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(
                                            workflows[i].4 == "improving" ? Color.green.opacity(0.15) :
                                            workflows[i].4 == "declining" ? Color.red.opacity(0.15) :
                                            Color.secondary.opacity(0.15), in: Capsule()
                                        )
                                        .foregroundStyle(
                                            workflows[i].4 == "improving" ? Color.green :
                                            workflows[i].4 == "declining" ? Color.red :
                                            Color.secondary
                                        )
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(4)
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

// MARK: - Workflow Analytics Stat
struct WorkflowAnalyticsStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

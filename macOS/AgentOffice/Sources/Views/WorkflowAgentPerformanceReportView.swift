// WorkflowAgentPerformanceReportView.swift
import SwiftUI

struct WorkflowAgentPerformanceReportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let summary: [(String, String, Color)] = [
        ("Total Tasks", "94", .blue),
        ("Success Rate", "94.2%", .green),
        ("Avg Response Time", "2.1s", .blue),
        ("Total Cost", "$12.42", .orange),
    ]

    private let agentPerformance: [(String, Int, Double, Double)] = [
        ("Architect", 24, 92.8, 2.3),
        ("Builder", 48, 88.5, 1.8),
        ("Reviewer", 32, 95.2, 3.1),
        ("Tester", 18, 90.1, 2.0),
        ("Planner", 12, 85.3, 1.5),
        ("Security", 8, 97.0, 2.8),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Report").font(.headline)
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
                    // Summary
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(summary.indices, id: \.self) { i in
                            PerformanceReportStat(
                                label: summary[i].0,
                                value: summary[i].1,
                                color: summary[i].2
                            )
                        }
                    }

                    // Agent performance
                    GroupBox("Agent Performance") {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Agent").font(.system(size: 9, weight: .semibold)).frame(width: 70)
                                Text("Tasks").font(.system(size: 9, weight: .semibold)).frame(width: 40, alignment: .trailing)
                                Text("Success").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                                Text("Avg Time").font(.system(size: 9, weight: .semibold)).frame(width: 50, alignment: .trailing)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)

                            ForEach(agentPerformance.indices, id: \.self) { i in
                                HStack {
                                    Text(agentPerformance[i].0)
                                        .font(.system(size: 10, weight: .medium))
                                        .frame(width: 70, alignment: .leading)
                                    Text("\(agentPerformance[i].1)")
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 40, alignment: .trailing)
                                    Text(String(format: "%.1f%%", agentPerformance[i].2))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
                                    Text(String(format: "%.1fs", agentPerformance[i].3))
                                        .font(.system(size: 9, design: .monospaced))
                                        .frame(width: 50, alignment: .trailing)
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
                Button("Export Report") {
                    store.showToast("Report exported", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 520)
    }
}

// MARK: - Performance Report Stat
struct PerformanceReportStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

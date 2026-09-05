// WorkflowPerformanceReportView.swift
import SwiftUI

struct WorkflowPerformanceReportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

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
                VStack(spacing: 16) {
                    // Summary
                    VStack(spacing: 8) {
                        Text("Performance Summary")
                            .font(.system(size: 14, weight: .semibold))
                        HStack(spacing: 20) {
                            ReportMetric(label: "Score", value: "87/100")
                            ReportMetric(label: "Rank", value: "Excellent")
                            ReportMetric(label: "Trend", value: "+5%")
                        }
                    }
                    .padding()
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                    // Metrics breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Metrics Breakdown").font(.system(size: 12, weight: .semibold))
                        ReportRow(label: "Speed", value: "92%", bar: 0.92)
                        ReportRow(label: "Quality", value: "88%", bar: 0.88)
                        ReportRow(label: "Cost Efficiency", value: "85%", bar: 0.85)
                        ReportRow(label: "Success Rate", value: "94%", bar: 0.94)
                        ReportRow(label: "Utilization", value: "78%", bar: 0.78)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Recommendations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommendations").font(.system(size: 12, weight: .semibold))
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 10))
                            Text("Consider using parallel mode for independent tasks to improve speed.")
                                .font(.system(size: 10))
                        }
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 10))
                            Text("Cache frequently used results to reduce token usage.")
                                .font(.system(size: 10))
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 450, height: 500)
    }
}

// MARK: - Report Metric
struct ReportMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Report Row
struct ReportRow: View {
    let label: String
    let value: String
    let bar: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .frame(width: 80, alignment: .leading)
            ProgressView(value: bar)
                .frame(width: 100)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 35, alignment: .trailing)
        }
    }
}

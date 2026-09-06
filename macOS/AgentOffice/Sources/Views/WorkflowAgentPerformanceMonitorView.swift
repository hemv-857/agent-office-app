// WorkflowAgentPerformanceMonitorView.swift
import SwiftUI

struct WorkflowAgentPerformanceMonitorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, String, String, Color)] = [
        ("CPU Usage", "23%", "Normal", .green),
        ("Memory", "128 MB", "4.2% of 3 GB", .blue),
        ("API Calls", "47", "12 today", .purple),
        ("Cache Hits", "82%", "+5% vs avg", .green),
        ("Avg Latency", "1.2s", "P95: 2.8s", .blue),
        ("Error Rate", "0.8%", "< 1% threshold", .green),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Monitor").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Status
            HStack(spacing: 12) {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                Text("All systems operational")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.green)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(metrics.indices, id: \.self) { i in
                        PerformanceMonitorMetric(
                            label: metrics[i].0,
                            value: metrics[i].1,
                            detail: metrics[i].2,
                            color: metrics[i].3
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Refresh") {
                    store.showToast("Metrics refreshed", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

// MARK: - Performance Monitor Metric
struct PerformanceMonitorMetric: View {
    let label: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(detail)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

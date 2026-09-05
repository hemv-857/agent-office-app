// WorkflowPerformanceMetricsView.swift
import SwiftUI

struct WorkflowPerformanceMetricsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, String, String, Color)] = [
        ("Avg Response Time", "1.2s", "bolt.fill", .yellow),
        ("Success Rate", "94%", "checkmark.circle.fill", .green),
        ("Tokens per Run", "1,200", "text.word.spacing", .blue),
        ("Cost per Run", "$0.03", "dollarsign.circle", .orange),
        ("Agent Utilization", "88%", "person.3.fill", .purple),
        ("Cache Hit Rate", "72%", "archivebox.fill", .cyan),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Metrics").font(.headline)
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
                    ForEach(metrics, id: \.0) { metric in
                        MetricRow(
                            title: metric.0,
                            value: metric.1,
                            icon: metric.2,
                            color: metric.3
                        )
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
        .frame(width: 400, height: 420)
    }
}

// MARK: - Metric Row
struct MetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 20)
            Text(title)
                .font(.system(size: 11))
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

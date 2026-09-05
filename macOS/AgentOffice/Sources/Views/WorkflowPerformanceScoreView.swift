// WorkflowPerformanceScoreView.swift
import SwiftUI

struct WorkflowPerformanceScoreView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, Double, String)] = [
        ("Speed", 0.85, "Average response time"),
        ("Quality", 0.92, "Output accuracy"),
        ("Cost Efficiency", 0.78, "Tokens per dollar"),
        ("Success Rate", 0.94, "Completed without errors"),
        ("Agent Utilization", 0.88, "Active agent time"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Score").font(.headline)
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
                    // Overall score
                    VStack(spacing: 8) {
                        Text("Overall Score")
                            .font(.system(size: 12, weight: .semibold))
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                            Circle()
                                .trim(from: 0, to: 0.87)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Text("87")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                        }
                        .frame(width: 100, height: 100)
                        Text("Excellent")
                            .font(.system(size: 11))
                            .foregroundStyle(.green)
                    }

                    // Metrics
                    VStack(spacing: 8) {
                        ForEach(metrics, id: \.0) { metric in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(metric.0)
                                        .font(.system(size: 11, weight: .medium))
                                    Text(metric.2)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                ProgressView(value: metric.1)
                                    .frame(width: 80)
                                Text(String(format: "%.0f%%", metric.1 * 100))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 35, alignment: .trailing)
                            }
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
        .frame(width: 420, height: 480)
    }
}

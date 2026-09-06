// WorkflowAgentAgentMetricsView.swift
import SwiftUI

struct WorkflowAgentAgentMetricsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let metrics: [(String, Int, Double, Double)] = [
        ("Architect", 142, 96.2, 1.2),
        ("Builder", 289, 94.8, 0.8),
        ("Reviewer", 167, 97.1, 1.5),
        ("Tester", 98, 93.5, 2.1),
        ("Planner", 76, 95.0, 1.8),
        ("Security", 45, 98.0, 3.2),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Metrics").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Summary
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("817")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Total Tasks")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("95.8%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Avg Accuracy")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("1.8s")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Avg Response")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Table header
            HStack(spacing: 12) {
                Text("Agent")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .leading)
                Text("Tasks")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
                Text("Accuracy")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                Text("Avg Time")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal)

            Divider()

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(metrics.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            Text(metrics[i].0)
                                .font(.system(size: 11, weight: .medium))
                                .frame(width: 70, alignment: .leading)
                            Text("\(metrics[i].1)")
                                .font(.system(size: 11, design: .monospaced))
                                .frame(width: 50, alignment: .trailing)
                            ProgressView(value: metrics[i].2 / 100.0)
                                .frame(width: 60)
                                .tint(metrics[i].2 > 95 ? .green : .orange)
                            Text(String(format: "%.1fs", metrics[i].3))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 420)
    }
}

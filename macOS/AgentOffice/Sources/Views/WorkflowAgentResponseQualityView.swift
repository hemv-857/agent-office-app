// WorkflowAgentResponseQualityView.swift
import SwiftUI

struct WorkflowAgentResponseQualityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, Double, Double, Double, Double, Int)] = [
        ("Architect", 94.5, 96.2, 92.8, 94.5, 142),
        ("Builder", 92.1, 94.8, 90.5, 92.5, 289),
        ("Reviewer", 97.8, 98.2, 96.5, 97.5, 167),
        ("Tester", 91.2, 93.5, 89.8, 91.5, 98),
        ("Planner", 93.8, 95.0, 92.0, 93.6, 76),
        ("Security", 98.5, 99.0, 97.8, 98.4, 45),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Response Quality").font(.headline)
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
                    Text("94.7%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Avg Quality")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("817")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                    Text("Responses")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("2.1%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Error Rate")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Table
            ScrollView {
                VStack(spacing: 2) {
                    HStack(spacing: 12) {
                        Text("Agent")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .leading)
                        Text("Accuracy")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 55, alignment: .trailing)
                        Text("Completeness")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 75, alignment: .trailing)
                        Text("Relevance")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .trailing)
                        Text("Overall")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 55, alignment: .trailing)
                        Text("Count")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 45, alignment: .trailing)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(agents.indices, id: \.self) { i in
                        QualityAnalysisRow(
                            name: agents[i].0,
                            accuracy: agents[i].1,
                            completeness: agents[i].2,
                            relevance: agents[i].3,
                            overall: agents[i].4,
                            count: agents[i].5
                        )
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
        .frame(width: 500, height: 440)
    }
}

// MARK: - Quality Analysis Row
struct QualityAnalysisRow: View {
    let name: String
    let accuracy: Double
    let completeness: Double
    let relevance: Double
    let overall: Double
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)

            QualityBar(value: accuracy)
                .frame(width: 55)
            Text(String(format: "%.1f", accuracy))
                .font(.system(size: 10, design: .monospaced))

            QualityBar(value: completeness)
                .frame(width: 75)
            Text(String(format: "%.1f", completeness))
                .font(.system(size: 10, design: .monospaced))

            QualityBar(value: relevance)
                .frame(width: 60)
            Text(String(format: "%.1f", relevance))
                .font(.system(size: 10, design: .monospaced))

            ProgressView(value: overall / 100.0)
                .frame(width: 55)
                .tint(overall > 97 ? .green : overall > 95 ? .orange : .red)
            Text(String(format: "%.1f", overall))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 35, alignment: .trailing)

            Text("\(count)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Quality Bar
struct QualityBar: View {
    let value: Double

    var body: some View {
        ProgressView(value: value / 100.0)
            .tint(value > 97 ? .green : value > 95 ? .orange : .red)
    }
}
// WorkflowAgentResponseQualityAnalyzerView.swift
import SwiftUI

struct WorkflowAgentResponseQualityAnalyzerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let analyses: [(String, String, Double, Double, Double)] = [
        ("Architect", "Microservice boundary analysis", 95.0, 88.0, 92.0),
        ("Builder", "API endpoint implementation", 87.0, 91.0, 85.0),
        ("Reviewer", "Code review findings", 92.0, 96.0, 94.0),
        ("Tester", "Test coverage report", 88.0, 85.0, 90.0),
        ("Planner", "Sprint velocity forecast", 82.0, 79.0, 85.0),
        ("Security", "Vulnerability assessment", 96.0, 94.0, 98.0),
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

            ScrollView {
                VStack(spacing: 12) {
                    // Summary
                    GroupBox("Quality Overview") {
                        HStack(spacing: 16) {
                            QualityOverviewStat(label: "Avg Score", value: String(format: "%.0f", analyses.map { ($0.2 + $0.3 + $0.4) / 3 }.reduce(0, +) / Double(analyses.count)))
                            QualityOverviewStat(label: "Best", value: analyses.map { max($0.2, $0.3, $0.4) }.max().map { String(format: "%.0f", $0) } ?? "0")
                            QualityOverviewStat(label: "Needs Work", value: "\(analyses.filter { min($0.2, $0.3, $0.4) < 85 }.count)")
                        }
                        .padding(8)
                    }

                    // Per-agent quality
                    ForEach(analyses.indices, id: \.self) { i in
                        GroupBox(analyses[i].0) {
                            VStack(spacing: 6) {
                                Text(analyses[i].1)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 12) {
                                    QualityMetricPill(label: "Accuracy", value: analyses[i].2)
                                    QualityMetricPill(label: "Clarity", value: analyses[i].3)
                                    QualityMetricPill(label: "Completeness", value: analyses[i].4)
                                }
                            }
                            .padding(8)
                        }
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
        .frame(width: 520, height: 560)
    }
}

// MARK: - Quality Overview Stat
struct QualityOverviewStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quality Metric Pill
struct QualityMetricPill: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.0f", value))
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(pillColor)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(pillColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
    }

    private var pillColor: Color {
        if value >= 95 { return .green }
        if value >= 90 { return .blue }
        if value >= 85 { return .orange }
        return .red
    }
}

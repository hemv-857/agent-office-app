// WorkflowSessionComparisonDetailView.swift
import SwiftUI

struct WorkflowSessionComparisonDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Comparison").font(.headline)
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
                    // Headers
                    HStack(spacing: 16) {
                        ComparisonHeader(title: "Session A", subtitle: "Parallel Mode", color: .blue)
                        ComparisonHeader(title: "Session B", subtitle: "Pipeline Mode", color: .purple)
                    }

                    // Metrics comparison
                    GroupBox("Performance") {
                        VStack(spacing: 6) {
                            ComparisonRow(label: "Duration", valueA: "2m 15s", valueB: "3m 42s")
                            ComparisonRow(label: "Tokens Used", valueA: "4,200", valueB: "6,800")
                            ComparisonRow(label: "Cost", valueA: "$0.042", valueB: "$0.068")
                            ComparisonRow(label: "Agents Used", valueA: "4", valueB: "4")
                            ComparisonRow(label: "Success Rate", valueA: "100%", valueB: "100%")
                            ComparisonRow(label: "Avg Response", valueA: "1.2s", valueB: "1.8s")
                        }
                        .padding(8)
                    }

                    // Quality comparison
                    GroupBox("Quality") {
                        VStack(spacing: 8) {
                            QualityComparisonRow(label: "Code Quality", scoreA: 88, scoreB: 92)
                            QualityComparisonRow(label: "Completeness", scoreA: 95, scoreB: 90)
                            QualityComparisonRow(label: "Clarity", scoreA: 92, scoreB: 85)
                            QualityComparisonRow(label: "Accuracy", scoreA: 90, scoreB: 94)
                        }
                        .padding(8)
                    }

                    // Recommendation
                    GroupBox("Recommendation") {
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading) {
                                Text("Pipeline mode is recommended for complex tasks")
                                    .font(.system(size: 11, weight: .medium))
                                Text("Better quality output but slightly higher cost")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(8)
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
        .frame(width: 540, height: 560)
    }
}

// MARK: - Comparison Header
struct ComparisonHeader: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Comparison Row
struct ComparisonRow: View {
    let label: String
    let valueA: String
    let valueB: String

    var body: some View {
        HStack(spacing: 12) {
            Text(valueA)
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 80, alignment: .trailing)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            Text(valueB)
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 80, alignment: .leading)
        }
    }
}

// MARK: - Quality Comparison Row
struct QualityComparisonRow: View {
    let label: String
    let scoreA: Int
    let scoreB: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(scoreA)%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(scoreA >= scoreB ? .green : .primary)
                .frame(width: 40, alignment: .trailing)
            ProgressView(value: Double(scoreA) / 100.0)
                .tint(scoreA >= scoreB ? .green : .blue)
            Text(label)
                .font(.system(size: 10))
                .frame(width: 80, alignment: .center)
            ProgressView(value: Double(scoreB) / 100.0)
                .tint(scoreB >= scoreA ? .green : .blue)
            Text("\(scoreB)%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(scoreB >= scoreA ? .green : .primary)
                .frame(width: 40, alignment: .leading)
        }
    }
}

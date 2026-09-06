// WorkflowAgentSentimentAnalysisView.swift
import SwiftUI

struct WorkflowAgentSentimentAnalysisView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let sentiments: [(String, Double, Double, Double, String)] = [
        ("Architect", 0.72, 0.18, 0.10, "Positive"),
        ("Builder", 0.65, 0.25, 0.10, "Positive"),
        ("Reviewer", 0.45, 0.30, 0.25, "Neutral"),
        ("Tester", 0.55, 0.28, 0.17, "Positive"),
        ("Planner", 0.68, 0.22, 0.10, "Positive"),
        ("Security", 0.30, 0.35, 0.35, "Neutral"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sentiment Analysis").font(.headline)
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
                    Text("65%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                    Text("Avg Positive")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("26%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                    Text("Avg Neutral")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text("9%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                    Text("Avg Negative")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(sentiments.indices, id: \.self) { i in
                        SentimentRow(
                            agent: sentiments[i].0,
                            positive: sentiments[i].1,
                            neutral: sentiments[i].2,
                            negative: sentiments[i].3,
                            overall: sentiments[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 460, height: 440)
    }
}

// MARK: - Sentiment Row
struct SentimentRow: View {
    let agent: String
    let positive: Double
    let neutral: Double
    let negative: Double
    let overall: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(agent)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text(overall)
                    .font(.system(size: 9, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(overallColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(overallColor)
            }

            // Stacked bar
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.green)
                        .frame(width: geo.size.width * positive)
                    Rectangle()
                        .fill(.orange)
                        .frame(width: geo.size.width * neutral)
                    Rectangle()
                        .fill(.red)
                        .frame(width: geo.size.width * negative)
                }
            }
            .frame(height: 16)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Legend
            HStack(spacing: 16) {
                SentimentLegend(label: "Positive", value: positive, color: .green)
                SentimentLegend(label: "Neutral", value: neutral, color: .orange)
                SentimentLegend(label: "Negative", value: negative, color: .red)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }

    private var overallColor: Color {
        switch overall {
        case "Positive": return .green
        case "Negative": return .red
        default: return .orange
        }
    }
}

// MARK: - Sentiment Legend
struct SentimentLegend: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(label): \(Int(value * 100))%")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}
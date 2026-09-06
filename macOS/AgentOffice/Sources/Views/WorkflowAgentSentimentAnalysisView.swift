// WorkflowAgentSentimentAnalysisView.swift
import SwiftUI

struct WorkflowAgentSentimentAnalysisView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let entries: [(String, String, String, Color, Double)] = [
        ("Architect", "Excellent design patterns applied", "Just now", .green, 0.92),
        ("Builder", "Minor compilation issue resolved", "5 min ago", .blue, 0.78),
        ("Reviewer", "Thorough review with helpful feedback", "12 min ago", .green, 0.88),
        ("Tester", "Test coverage improved to 85%", "20 min ago", .green, 0.95),
        ("Planner", "Sprint goal on track", "30 min ago", .green, 0.85),
        ("Security", "No vulnerabilities detected", "45 min ago", .green, 0.90),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sentiment Analysis").font(.headline)
                Spacer()
                Text("Overall: Positive")
                    .font(.caption)
                    .foregroundStyle(.green)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    // Overall sentiment bar
                    GroupBox("Overall Sentiment") {
                        HStack(spacing: 12) {
                            SentimentPill(label: "Positive", count: 5, color: .green)
                            SentimentPill(label: "Neutral", count: 1, color: .blue)
                            SentimentPill(label: "Negative", count: 0, color: .red)
                        }
                        .padding(8)
                    }

                    // Agent sentiments
                    GroupBox("Agent Sentiments") {
                        VStack(spacing: 6) {
                            ForEach(entries.indices, id: \.self) { i in
                                SentimentRow(
                                    agent: entries[i].0,
                                    message: entries[i].1,
                                    time: entries[i].2,
                                    sentiment: entries[i].3,
                                    score: entries[i].4
                                )
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
        .frame(width: 520, height: 480)
    }
}

// MARK: - Sentiment Pill
struct SentimentPill: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Sentiment Row
struct SentimentRow: View {
    let agent: String
    let message: String
    let time: String
    let sentiment: Color
    let score: Double

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(sentiment)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(agent)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(time)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
                Text(message)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Text(String(format: "%.0f%%", score * 100))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(sentiment.opacity(0.15), in: Capsule())
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

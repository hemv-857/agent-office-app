// WorkflowAgentQualityScoreView.swift
import SwiftUI

struct WorkflowAgentQualityScoreView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let scores: [(String, Double, Double, Double, Double, Color)] = [
        ("Architect", 96.2, 94.5, 97.8, 95.1, .blue),
        ("Builder", 94.8, 96.0, 93.2, 95.5, .green),
        ("Reviewer", 97.1, 98.0, 96.5, 98.2, .orange),
        ("Tester", 93.5, 92.0, 94.8, 92.5, .purple),
        ("Planner", 95.0, 93.5, 96.0, 94.0, .cyan),
        ("Security", 98.0, 99.0, 97.5, 98.5, .red),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quality Scores").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Header
            HStack(spacing: 12) {
                Text("Agent")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .leading)
                Text("Code")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
                Text("Tests")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
                Text("Docs")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
                Text("Overall")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            Divider()

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(scores.indices, id: \.self) { i in
                        QualityScoreRow(
                            agent: scores[i].0,
                            code: scores[i].1,
                            tests: scores[i].2,
                            docs: scores[i].3,
                            overall: scores[i].4,
                            color: scores[i].5
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
        .frame(width: 440, height: 420)
    }
}

// MARK: - Quality Score Row
struct QualityScoreRow: View {
    let agent: String
    let code: Double
    let tests: Double
    let docs: Double
    let overall: Double
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(agent)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)

            ScoreCell(value: code)
            ScoreCell(value: tests)
            ScoreCell(value: docs)

            ProgressView(value: overall / 100.0)
                .frame(width: 50)
                .tint(overall > 97 ? .green : overall > 95 ? .orange : .red)
            Text(String(format: "%.1f", overall))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Score Cell
struct ScoreCell: View {
    let value: Double

    var body: some View {
        ProgressView(value: value / 100.0)
            .frame(width: 40)
            .tint(value > 97 ? .green : value > 95 ? .orange : .red)
    }
}
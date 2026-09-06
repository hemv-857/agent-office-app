// WorkflowAgentQualityScoreView.swift
import SwiftUI

struct WorkflowAgentQualityScoreView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, Double, Double, Double, Double)] = [
        ("Architect", 92.8, 88.5, 95.0, 90.0),
        ("Builder", 88.5, 85.0, 92.0, 82.0),
        ("Reviewer", 95.2, 92.0, 98.0, 94.0),
        ("Tester", 90.1, 86.0, 94.0, 88.0),
        ("Planner", 85.3, 82.0, 90.0, 80.0),
        ("Security", 97.0, 95.0, 99.0, 96.0),
    ]

    private let categories = ["Overall", "Accuracy", "Completeness", "Efficiency"]

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

            ScrollView {
                VStack(spacing: 12) {
                    // Scores grid
                    ForEach(agents.indices, id: \.self) { i in
                        GroupBox(agents[i].0) {
                            HStack(spacing: 16) {
                                QualityScoreBadge(score: agents[i].1)
                                VStack(spacing: 4) {
                                    ForEach(categories.indices, id: \.self) { j in
                                        HStack {
                                            Text(categories[j])
                                                .font(.system(size: 9))
                                                .frame(width: 80, alignment: .leading)
                                            ProgressView(value: [agents[i].1, agents[i].2, agents[i].3, agents[i].4][j] / 100.0)
                                                .frame(maxWidth: .infinity)
                                            Text(String(format: "%.0f", [agents[i].1, agents[i].2, agents[i].3, agents[i].4][j]))
                                                .font(.system(size: 9, design: .monospaced))
                                                .frame(width: 30, alignment: .trailing)
                                        }
                                    }
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

// MARK: - Quality Score Badge
struct QualityScoreBadge: View {
    let score: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.0f", score))
                .font(.system(size: 20, weight: .bold, design: .monospaced))
            Text("Overall")
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(width: 60)
        .padding(.vertical, 10)
        .background(scoreColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(scoreColor.opacity(0.3), lineWidth: 1)
        )
    }

    private var scoreColor: Color {
        if score >= 95 { return .green }
        if score >= 90 { return .blue }
        if score >= 85 { return .orange }
        return .red
    }
}

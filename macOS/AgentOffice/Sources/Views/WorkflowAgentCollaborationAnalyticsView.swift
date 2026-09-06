// WorkflowAgentCollaborationAnalyticsView.swift
import SwiftUI

struct WorkflowAgentCollaborationAnalyticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    private let matrix: [[Double]] = [
        [0.0, 0.8, 0.3, 0.2, 0.7, 0.4],
        [0.8, 0.0, 0.9, 0.6, 0.4, 0.3],
        [0.3, 0.9, 0.0, 0.8, 0.2, 0.5],
        [0.2, 0.6, 0.8, 0.0, 0.3, 0.7],
        [0.7, 0.4, 0.2, 0.3, 0.0, 0.1],
        [0.4, 0.3, 0.5, 0.7, 0.1, 0.0],
    ]

    private func intensity(_ value: Double) -> Color {
        if value >= 0.8 { return .green }
        if value >= 0.5 { return .orange }
        if value > 0.0 { return .yellow }
        return .clear
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Collaboration Analytics").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Matrix
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("").frame(width: 80, height: 30)
                        ForEach(agents, id: \.self) { agent in
                            Text(String(agent.prefix(3)))
                                .font(.system(size: 8, weight: .semibold))
                                .frame(width: 50, height: 30)
                        }
                    }
                    // Data rows
                    ForEach(agents.indices, id: \.self) { row in
                        HStack(spacing: 0) {
                            Text(agents[row])
                                .font(.system(size: 8, weight: .medium))
                                .frame(width: 80, height: 30, alignment: .trailing)
                                .padding(.trailing, 6)
                            ForEach(agents.indices, id: \.self) { col in
                                Rectangle()
                                    .fill(intensity(matrix[row][col]))
                                    .frame(width: 50, height: 30)
                                    .overlay(
                                        Text(String(format: "%.1f", matrix[row][col]))
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundStyle(matrix[row][col] > 0.5 ? .white : .primary)
                                    )
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Stats
            HStack(spacing: 16) {
                CollaborationAnalyticsStat(label: "Strongest Link", value: "Builder↔Reviewer", color: .green)
                CollaborationAnalyticsStat(label: "Avg Score", value: "0.48", color: .blue)
                CollaborationAnalyticsStat(label: "Active Pairs", value: "25/30", color: .purple)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 600, height: 480)
    }
}

// MARK: - Stat
struct CollaborationAnalyticsStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

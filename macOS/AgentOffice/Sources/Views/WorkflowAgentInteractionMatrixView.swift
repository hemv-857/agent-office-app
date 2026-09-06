// WorkflowAgentInteractionMatrixView.swift
import SwiftUI

struct WorkflowAgentInteractionMatrixView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Arch", "Build", "Rev", "Test", "Plan", "Sec"]
    private let matrix: [[String]] = [
        ["-", "5", "3", "1", "4", "2"],
        ["5", "-", "8", "4", "2", "1"],
        ["3", "8", "-", "6", "1", "3"],
        ["1", "4", "6", "-", "3", "1"],
        ["4", "2", "1", "3", "-", "1"],
        ["2", "1", "3", "1", "1", "-"],
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Interaction Matrix").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 12) {
                Text("Agent-to-Agent Interaction Frequency")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                // Matrix grid
                VStack(spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 50, height: 30)
                        ForEach(Array(agents.enumerated()), id: \.offset) { _, agent in
                            Text(agent)
                                .font(.system(size: 8, weight: .semibold))
                                .frame(width: 50, height: 30)
                                .background(.quaternary)
                        }
                    }

                    // Data rows
                    ForEach(Array(agents.enumerated()), id: \.offset) { rowIdx, agent in
                        HStack(spacing: 0) {
                            Text(agent)
                                .font(.system(size: 8, weight: .semibold))
                                .frame(width: 50, height: 36)
                                .background(.quaternary)

                            ForEach(Array(agents.enumerated()), id: \.offset) { colIdx, _ in
                                let val = matrix[rowIdx][colIdx]
                                let intensity = val == "-" ? 0.0 : Double(val)! / 8.0

                                Text(val)
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .frame(width: 50, height: 36)
                                    .background(
                                        val == "-"
                                            ? Color(nsColor: .controlBackgroundColor)
                                            : Color.accentColor.opacity(intensity * 0.6)
                                    )
                            }
                        }
                    }
                }

                // Legend
                HStack(spacing: 8) {
                    Text("Low")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    ForEach(0..<5) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor.opacity(Double(i) / 4.0 * 0.6))
                            .frame(width: 24, height: 12)
                    }
                    Text("High")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }

                // Summary
                GroupBox("Top Interactions") {
                    VStack(spacing: 4) {
                        MatrixStatPair(pair: "Builder ↔ Reviewer", count: "8", strength: "Very High")
                        MatrixStatPair(pair: "Reviewer ↔ Tester", count: "6", strength: "High")
                        MatrixStatPair(pair: "Architect ↔ Builder", count: "5", strength: "High")
                        MatrixStatPair(pair: "Architect ↔ Planner", count: "4", strength: "Medium")
                    }
                    .padding(8)
                }
            }
            .padding()

            Spacer()

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

// MARK: - Matrix Stat Pair
struct MatrixStatPair: View {
    let pair: String
    let count: String
    let strength: String

    var body: some View {
        HStack {
            Text(pair)
                .font(.system(size: 10, weight: .medium))
            Spacer()
            Text("\(count) interactions")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(strength)
                .font(.system(size: 9))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.quaternary, in: Capsule())
        }
    }
}

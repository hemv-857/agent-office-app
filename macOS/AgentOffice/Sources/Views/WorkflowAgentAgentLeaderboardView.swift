// WorkflowAgentAgentLeaderboardView.swift
import SwiftUI

struct WorkflowAgentAgentLeaderboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let leaderboard: [(String, Int, Double, Int)] = [
        ("Builder", 289, 94.8, 12450),
        ("Architect", 142, 96.2, 8920),
        ("Reviewer", 167, 97.1, 10200),
        ("Tester", 98, 93.5, 5640),
        ("Planner", 76, 95.0, 4310),
        ("Security", 45, 98.0, 3890),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Leaderboard").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(leaderboard.indices, id: \.self) { i in
                        AgentLeaderboardRow(
                            rank: i + 1,
                            name: leaderboard[i].0,
                            tasks: leaderboard[i].1,
                            accuracy: leaderboard[i].2,
                            score: leaderboard[i].3
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
        .frame(width: 460, height: 400)
    }
}

// MARK: - Leaderboard Row
struct AgentLeaderboardRow: View {
    let rank: Int
    let name: String
    let tasks: Int
    let accuracy: Double
    let score: Int

    private var medal: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(medal)
                .font(.system(size: 14))
                .frame(width: 30)

            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 70, alignment: .leading)

            Text("\(tasks) tasks")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)

            ProgressView(value: accuracy / 100.0)
                .frame(width: 50)
                .tint(accuracy > 95 ? .green : .orange)

            Text(String(format: "%.1f%%", accuracy))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 35, alignment: .trailing)

            Text("\(score) pts")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
// WorkflowAgentLeaderboardDetailView.swift
import SwiftUI

struct WorkflowAgentLeaderboardDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let leaderboard: [(Int, String, String, Int, Double, Double)] = [
        (1, "🏆", "Reviewer", 32, 95.2, 0.03),
        (2, "🥈", "Architect", 24, 92.8, 0.02),
        (3, "🥉", "Builder", 48, 88.5, 0.05),
        (4, "4", "Tester", 18, 90.1, 0.02),
        (5, "5", "Planner", 12, 85.3, 0.01),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Leaderboard").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    // Top 3 podium
                    HStack(spacing: 12) {
                        LeaderboardPodium(rank: 2, emoji: "🥈", name: leaderboard[1].2, score: leaderboard[1].4)
                        LeaderboardPodium(rank: 1, emoji: "🏆", name: leaderboard[0].2, score: leaderboard[0].4)
                        LeaderboardPodium(rank: 3, emoji: "🥉", name: leaderboard[2].2, score: leaderboard[2].4)
                    }
                    .padding(.vertical)

                    // Full list
                    GroupBox("Full Rankings") {
                        VStack(spacing: 4) {
                            // Header
                            HStack {
                                Text("#")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 30)
                                Text("Agent")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 80, alignment: .leading)
                                Text("Tasks")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 40)
                                Text("Score")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 45)
                                Text("Cost")
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(.quaternary)

                            ForEach(leaderboard, id: \.0) { entry in
                                LeaderboardRow(
                                    rank: entry.0,
                                    emoji: entry.1,
                                    name: entry.2,
                                    tasks: entry.3,
                                    score: entry.4,
                                    cost: entry.5
                                )
                            }
                        }
                        .padding(4)
                    }

                    // Stats
                    GroupBox("Statistics") {
                        HStack(spacing: 16) {
                            LeaderboardStat(label: "Total Tasks", value: "\(leaderboard.map { $0.3 }.reduce(0, +))")
                            LeaderboardStat(label: "Avg Score", value: String(format: "%.1f", leaderboard.map { $0.4 }.reduce(0, +) / Double(leaderboard.count)))
                            LeaderboardStat(label: "Total Cost", value: String(format: "$%.2f", leaderboard.map { $0.5 }.reduce(0, +)))
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
        .frame(width: 480, height: 560)
    }
}

// MARK: - Leaderboard Podium
struct LeaderboardPodium: View {
    let rank: Int
    let emoji: String
    let name: String
    let score: Double

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: rank == 1 ? 32 : 24))
            Text(name)
                .font(.system(size: 11, weight: .semibold))
            Text(String(format: "%.1f", score))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(rank == 1 ? Color.yellow.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(rank == 1 ? Color.yellow : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let emoji: String
    let name: String
    let tasks: Int
    let score: Double
    let cost: Double

    var body: some View {
        HStack(spacing: 10) {
            Text("\(rank)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .frame(width: 30)
            Text(emoji)
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 80, alignment: .leading)
            Text("\(tasks)")
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 40)
            Text(String(format: "%.1f", score))
                .font(.system(size: 10, design: .monospaced))
                .frame(width: 45)
            Text(String(format: "$%.2f", cost))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

// MARK: - Leaderboard Stat
struct LeaderboardStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

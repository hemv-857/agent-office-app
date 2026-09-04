// LeaderboardView.swift
import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var sorted: [(id: String, entry: LeaderboardEntry)] {
        store.leaderboard.map { (id: $0.key, entry: $0.value) }
            .sorted { $0.entry.runs > $1.entry.runs }
    }

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

            if sorted.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No data yet").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { rank, item in
                        HStack {
                            Text("#\(rank + 1)").font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(rank < 3 ? .yellow : .secondary)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text(item.entry.name).font(.system(size: 13, weight: .medium))
                                Text("\(item.entry.runs) runs").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "$%.4f", item.entry.totalCost)).font(.system(size: 12))
                                Text("\(item.entry.totalTokens) tokens").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 450, height: 400)
    }
}

// AgentPerformanceDashboardView.swift
import SwiftUI

struct AgentPerformanceDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Dashboard").font(.headline)
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
                    // Quick stats
                    HStack(spacing: 12) {
                        PerfStatCard(title: "Avg Speed", value: "1.2s", icon: "bolt.fill", color: .yellow)
                        PerfStatCard(title: "Success", value: "94%", icon: "checkmark.circle.fill", color: .green)
                        PerfStatCard(title: "Tokens", value: "12.5K", icon: "text.word.spacing", color: .blue)
                    }

                    // Agent leaderboard
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Performers").font(.system(size: 12, weight: .semibold))
                        ForEach(0..<5) { i in
                            HStack {
                                Text("\(i + 1)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .frame(width: 16)
                                Text(store.allAgents[i % store.allAgents.count].emoji)
                                Text(store.allAgents[i % store.allAgents.count].name)
                                    .font(.system(size: 11))
                                Spacer()
                                let score = Double.random(in: 0.7...1.0)
                                Text(String(format: "%.0f%%", score * 100))
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(score > 0.9 ? .green : .secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Recent activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity").font(.system(size: 12, weight: .semibold))
                        ForEach(0..<3) { i in
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 6, height: 6)
                                Text("Agent completed task #\(100 - i)")
                                    .font(.system(size: 10))
                                Spacer()
                                Text("\(i + 1)m ago")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 450, height: 480)
    }
}

// MARK: - Perf Stat Card
struct PerfStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

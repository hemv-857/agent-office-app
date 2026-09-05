// SessionSummaryStatsView.swift
import SwiftUI

struct SessionSummaryStatsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private var totalTokens: Int {
        store.results.reduce(into: 0) { $0 += $1.tokensUsed }
    }

    private var totalCost: Double {
        store.results.reduce(into: 0.0) { $0 += $1.costUsd }
    }

    private var avgResponseTime: Double {
        guard !store.results.isEmpty else { return 0 }
        return store.results.reduce(into: 0.0) { $0 += $1.elapsedMs } / Double(store.results.count) / 1000
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Summary").font(.headline)
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
                    // Stats grid
                    HStack(spacing: 12) {
                        SessionStatCard(title: "Results", value: "\(store.results.count)", icon: "doc.text", color: .blue)
                        SessionStatCard(title: "Tokens", value: "\(totalTokens)", icon: "text.word.spacing", color: .green)
                        SessionStatCard(title: "Cost", value: String(format: "$%.4f", totalCost), icon: "dollarsign.circle", color: .orange)
                        SessionStatCard(title: "Avg Time", value: String(format: "%.1fs", avgResponseTime), icon: "clock", color: .purple)
                    }

                    // Agent breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Agent Breakdown").font(.system(size: 12, weight: .semibold))
                        ForEach(store.allAgents.prefix(5)) { agent in
                            let agentResults = store.results.filter { $0.agentName == agent.name }
                            HStack {
                                Text(agent.emoji)
                                Text(agent.name)
                                    .font(.system(size: 11))
                                Spacer()
                                Text("\(agentResults.count) results")
                                    .font(.system(size: 10, design: .monospaced))
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
        .frame(width: 480, height: 450)
    }
}

// MARK: - Session Stat Card
struct SessionStatCard: View {
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

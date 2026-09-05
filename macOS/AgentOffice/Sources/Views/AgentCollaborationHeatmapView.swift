// AgentCollaborationHeatmapView.swift
import SwiftUI

struct AgentCollaborationHeatmapView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private var agents: [Agent] {
        Array(store.allAgents.prefix(8))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Collaboration").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Heatmap
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Collaboration Heatmap").font(.system(size: 12, weight: .semibold))
                        HeatmapGrid(agents: agents)
                    }

                    // Legend
                    HStack(spacing: 12) {
                        HeatmapLegendItem(color: .green.opacity(0.8), label: "High")
                        HeatmapLegendItem(color: .yellow.opacity(0.8), label: "Medium")
                        HeatmapLegendItem(color: .red.opacity(0.3), label: "Low")
                    }
                    .font(.system(size: 10))

                    // Top collaborations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Collaborations").font(.system(size: 12, weight: .semibold))
                        ForEach(getTopCollaborations(), id: \.0) { collab in
                            HStack {
                                Text(collab.0)
                                    .font(.system(size: 11))
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                Text(collab.1)
                                    .font(.system(size: 11))
                                Spacer()
                                Text("\(collab.2) times")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
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
        .frame(width: 500, height: 450)
    }

    func getTopCollaborations() -> [(String, String, Int)] {
        // Simulated collaboration data
        guard agents.count >= 2 else { return [] }
        return [
            (agents[0].name, agents[1].name, Int.random(in: 10...50)),
            (agents[2].name, agents[3].name, Int.random(in: 10...50)),
            (agents[4].name, agents[5].name, Int.random(in: 5...30)),
        ]
    }
}

// MARK: - Heatmap Grid
struct HeatmapGrid: View {
    let agents: [Agent]

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                Rectangle().fill(.clear).frame(width: 60, height: 20)
                ForEach(agents) { agent in
                    Text(String(agent.name.prefix(3)))
                        .font(.system(size: 7))
                        .frame(width: 35, height: 20)
                }
            }

            // Data rows
            ForEach(agents) { rowAgent in
                HStack(spacing: 0) {
                    Text(String(rowAgent.name.prefix(5)))
                        .font(.system(size: 8))
                        .frame(width: 60, height: 20, alignment: .trailing)
                        .padding(.trailing, 4)

                    ForEach(agents) { colAgent in
                        Rectangle()
                            .fill(heatmapColor(row: rowAgent, col: colAgent))
                            .frame(width: 35, height: 20)
                            .overlay(
                                Rectangle().stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
    }

    func heatmapColor(row: Agent, col: Agent) -> Color {
        if row.id == col.id { return .gray.opacity(0.3) }
        let value = abs(row.name.hashValue &+ col.name.hashValue) % 100
        if value > 70 { return .green.opacity(0.8) }
        if value > 40 { return .yellow.opacity(0.6) }
        return .red.opacity(0.3)
    }
}

// MARK: - Legend Item
struct HeatmapLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            Text(label).foregroundStyle(.secondary)
        }
    }
}

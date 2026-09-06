// WorkflowAgentAgentInteractionMatrixView.swift
import SwiftUI

struct WorkflowAgentAgentInteractionMatrixView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let matrix: [[Int]] = [
        [0, 12, 8, 3, 5, 2],
        [12, 0, 15, 7, 4, 3],
        [8, 15, 0, 10, 2, 6],
        [3, 7, 10, 0, 8, 4],
        [5, 4, 2, 8, 0, 3],
        [2, 3, 6, 4, 3, 0],
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

            // Header
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 70, alignment: .leading)
                ForEach(agents, id: \.self) { agent in
                    Text(agent)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 55)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            Divider()

            ScrollView {
                VStack(spacing: 1) {
                    ForEach(agents.indices, id: \.self) { i in
                        InteractionMatrixRow(
                            agent: agents[i],
                            values: matrix[i],
                            agents: agents
                        )
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            // Legend
            HStack(spacing: 16) {
                Text("Interactions")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach([0, 5, 10, 15], id: \.self) { val in
                        Circle()
                            .fill(intensityColor(val))
                            .frame(width: 12, height: 12)
                        if val < 15 { Text("\(val)").font(.system(size: 8)).foregroundStyle(.secondary) }
                    }
                }
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
        .frame(width: 520, height: 460)
    }

    private func intensityColor(_ value: Int) -> Color {
        switch value {
        case 0: return .gray.opacity(0.2)
        case 1...5: return .blue.opacity(0.4)
        case 6...10: return .green.opacity(0.6)
        case 11...15: return .orange.opacity(0.8)
        default: return .red
        }
    }
}

// MARK: - Interaction Matrix Row
struct InteractionMatrixRow: View {
    let agent: String
    let values: [Int]
    let agents: [String]

    var body: some View {
        HStack(spacing: 0) {
            Text(agent)
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            ForEach(values.indices, id: \.self) { j in
                let value = values[j]
                let isDiagonal = agents[j] == agent
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isDiagonal ? Color.gray.opacity(0.1) : intensityColor(value))
                        .frame(width: 48, height: 24)
                    if !isDiagonal && value > 0 {
                        Text("\(value)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(value > 10 ? .white : .primary)
                    }
                }
                .frame(width: 55)
            }
        }
    }

    private func intensityColor(_ value: Int) -> Color {
        switch value {
        case 0: return .gray.opacity(0.2)
        case 1...5: return .blue.opacity(0.4)
        case 6...10: return .green.opacity(0.6)
        case 11...15: return .orange.opacity(0.8)
        default: return .red
        }
    }
}
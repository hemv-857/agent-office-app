// AgentAvailabilityView.swift
import SwiftUI

struct AgentAvailabilityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Availability").font(.headline)
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
                    ForEach(store.allAgents) { agent in
                        AgentAvailabilityRow(agent: agent, isSeated: store.desks.contains { $0.agent?.id == agent.id })
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("Available: \(store.allAgents.count - store.desks.filter { $0.isOccupied }.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 450)
    }
}

// MARK: - Availability Row
struct AgentAvailabilityRow: View {
    let agent: Agent
    let isSeated: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(agent.emoji).font(.system(size: 16))
            VStack(alignment: .leading) {
                Text(agent.name).font(.system(size: 11, weight: .medium))
                Text(agent.division)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(isSeated ? .green : .gray)
                    .frame(width: 6, height: 6)
                Text(isSeated ? "Seated" : "Available")
                    .font(.system(size: 9))
                    .foregroundStyle(isSeated ? .green : .secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

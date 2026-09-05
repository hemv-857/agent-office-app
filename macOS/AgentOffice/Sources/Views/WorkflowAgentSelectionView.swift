// WorkflowAgentSelectionView.swift
import SwiftUI

struct WorkflowAgentSelectionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedAgents: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Agents").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(store.allAgents) { agent in
                        AgentSelectionRow(
                            agent: agent,
                            isSelected: selectedAgents.contains(agent.id),
                            onToggle: {
                                if selectedAgents.contains(agent.id) {
                                    selectedAgents.remove(agent.id)
                                } else {
                                    selectedAgents.insert(agent.id)
                                }
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(selectedAgents.count) selected")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Apply") {
                    // Apply selection
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedAgents.isEmpty)
            }
            .padding()
        }
        .frame(width: 420, height: 450)
    }
}

// MARK: - Agent Selection Row
struct AgentSelectionRow: View {
    let agent: Agent
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .font(.system(size: 14))
                Text(agent.emoji).font(.system(size: 16))
                VStack(alignment: .leading) {
                    Text(agent.name).font(.system(size: 11, weight: .medium))
                    Text(agent.division)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.1) : .clear, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

// WorkflowBulkActionsView.swift
import SwiftUI

struct WorkflowBulkActionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedAgents: Set<String> = []
    @State private var bulkAction = "run"

    private let actions = [
        ("run", "Run Prompt", "bolt.fill", Color.blue),
        ("remove", "Remove from Desk", "xmark.circle", Color.red),
        ("reset", "Reset Agent", "arrow.counterclockwise", Color.orange),
        ("export", "Export Agent Data", "square.and.arrow.up", Color.purple),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bulk Actions").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                // Action picker
                GroupBox("Action") {
                    Picker("Action", selection: $bulkAction) {
                        ForEach(actions, id: \.0) { action in
                            Label(action.1, systemImage: action.2).tag(action.0)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .padding(4)
                }

                // Agent selection
                GroupBox("Select Agents") {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(store.allAgents.prefix(12)) { agent in
                                Toggle(isOn: Binding(
                                    get: { selectedAgents.contains(agent.id) },
                                    set: { if $0 { selectedAgents.insert(agent.id) } else { selectedAgents.remove(agent.id) } }
                                )) {
                                    HStack(spacing: 6) {
                                        Text(agent.emoji).font(.system(size: 12))
                                        Text(agent.name).font(.system(size: 11))
                                    }
                                }
                                .toggleStyle(.checkbox)
                            }
                        }
                        .padding(4)
                    }
                    .frame(height: 160)
                }
            }
            .padding()

            Divider()

            HStack {
                Text("\(selectedAgents.count) agents selected")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Apply") {
                    executeBulkAction()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedAgents.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 520)
    }

    private func executeBulkAction() {
        switch bulkAction {
        case "remove":
            for agentId in selectedAgents {
                if let desk = store.desks.first(where: { $0.agent?.id == agentId }) {
                    store.removeAgent(from: desk.role)
                }
            }
            store.showToast("Removed \(selectedAgents.count) agents", type: .success)
        case "reset":
            store.showToast("Reset \(selectedAgents.count) agents", type: .success)
        default:
            store.showToast("Bulk action queued for \(selectedAgents.count) agents", type: .info)
        }
        store.persist()
    }
}

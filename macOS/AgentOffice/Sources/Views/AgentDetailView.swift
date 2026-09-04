// AgentDetailView.swift
import SwiftUI

struct AgentDetailView: View {
    let agent: Agent
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var isOccupied: Bool {
        store.desks.contains { $0.agent?.id == agent.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(agent.name).font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Avatar
                    HStack {
                        Text(agent.initials)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                        VStack(alignment: .leading) {
                            Text(agent.name).font(.title3.weight(.semibold))
                            Text(agent.division).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    // Info
                    GroupBox("Description") {
                        Text(agent.description).font(.body).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Role") {
                        Text(agent.officeRole).font(.body).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("System Prompt") {
                        ScrollView {
                            Text(agent.systemPrompt)
                                .font(.system(size: 11, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                    }

                    // Actions
                    HStack {
                        Button(action: {
                            if isOccupied {
                                if let desk = store.desks.first(where: { $0.agent?.id == agent.id }) {
                                    store.removeAgent(from: desk.role)
                                }
                            } else {
                                if let empty = store.desks.first(where: { !$0.isOccupied }) {
                                    store.seatAgent(agent, at: empty.role)
                                }
                            }
                        }) {
                            Label(isOccupied ? "Remove from Desk" : "Seat Agent", systemImage: isOccupied ? "xmark.circle" : "plus.circle")
                        }
                        .buttonStyle(.bordered)

                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(agent.systemPrompt, forType: .string)
                            store.showToast("Prompt copied", type: .success)
                        }) {
                            Label("Copy Prompt", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 550)
    }
}

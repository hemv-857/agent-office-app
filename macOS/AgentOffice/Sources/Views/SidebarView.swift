// SidebarView.swift
import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search agents...", text: $store.searchText)
                    .textFieldStyle(.plain)
                    .onChange(of: store.searchText) { store.applyFilters() }
                if !store.searchText.isEmpty {
                    Button(action: { store.searchText = ""; store.applyFilters() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

            // Filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    FilterPill(title: "All", isSelected: store.selectedDivision == nil) {
                        store.selectedDivision = nil
                        store.applyFilters()
                    }
                    ForEach(AgentDivision.allCases.filter { $0 != .custom }, id: \.self) { div in
                        FilterPill(title: div.rawValue, isSelected: store.selectedDivision == div) {
                            store.selectedDivision = div
                            store.applyFilters()
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.vertical, 6)

            Divider()

            // Agent list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(store.filteredAgents) { agent in
                        AgentRow(agent: agent)
                    }
                }
                .padding(8)
            }

            Divider()

            // Groups & Presets
            if !store.groups.isEmpty || !store.presets.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if !store.groups.isEmpty {
                        Text("Groups").font(.system(size: 10, weight: .semibold)).foregroundStyle(.tertiary)
                            .padding(.horizontal, 10)
                        ForEach(store.groups) { group in
                            Button(action: {
                                store.clearOffice()
                                for agentId in group.agentIds {
                                    if let agent = store.allAgents.first(where: { $0.id == agentId }),
                                       let desk = store.desks.first(where: { !$0.isOccupied }) {
                                        store.seatAgent(agent, at: desk.role)
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "folder").font(.system(size: 9))
                                    Text(group.name).font(.system(size: 11))
                                    Spacer()
                                    Text("\(group.agentIds.count)").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if !store.presets.isEmpty {
                        Text("Presets").font(.system(size: 10, weight: .semibold)).foregroundStyle(.tertiary)
                            .padding(.horizontal, 10)
                        ForEach(store.presets) { preset in
                            Button(action: { store.loadPreset(preset) }) {
                                HStack {
                                    Image(systemName: "bookmark").font(.system(size: 9))
                                    Text(preset.name).font(.system(size: 11))
                                    Spacer()
                                    Text("\(preset.seating.count)").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
                Divider()
            }

            // Bottom toolbar
            HStack(spacing: 8) {
                Button(action: { store.showGroupSave = true }) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 10))
                }
                .buttonStyle(.plain)
                .help("Save group")

                Button(action: { store.showPresetSave = true }) {
                    Image(systemName: "bookmark.badge.plus")
                        .font(.system(size: 10))
                }
                .buttonStyle(.plain)
                .help("Save preset")

                Button(action: store.clearOffice) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                }
                .buttonStyle(.plain)
                .help("Clear office")

                Spacer()

                Text("\(store.allAgents.count) agents")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(.background)
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Agent Row
struct AgentRow: View {
    let agent: Agent
    @EnvironmentObject var store: AppStore

    var isOccupied: Bool {
        store.desks.contains { $0.agent?.id == agent.id }
    }

    var body: some View {
        HStack(spacing: 8) {
            // Initials avatar
            Text(agent.initials)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(0.7), in: RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text(agent.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Text(agent.division)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isOccupied {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.green)
            }
        }
        .padding(6)
        .background(isOccupied ? Color.accentColor.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
        .onTapGesture {
            if isOccupied {
                if let desk = store.desks.first(where: { $0.agent?.id == agent.id }) {
                    store.removeAgent(from: desk.role)
                }
            } else {
                if let emptyDesk = store.desks.first(where: { !$0.isOccupied }) {
                    store.seatAgent(agent, at: emptyDesk.role)
                } else {
                    store.showToast("No empty desks", type: .error)
                }
            }
        }
        .onDrag {
            NSItemProvider(object: agent.id as NSString)
        }
    }
}

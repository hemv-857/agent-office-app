// WorkflowAgentRosterView.swift
import SwiftUI

struct WorkflowAgentRosterView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var sortBy: SortOption = .name
    @State private var filterDivision: String?
    @State private var showFavoritesOnly = false

    enum SortOption: String, CaseIterable {
        case name = "Name"
        case division = "Division"
        case role = "Role"
        case status = "Status"
    }

    private var filteredAgents: [Agent] {
        var agents = store.allAgents

        if !searchText.isEmpty {
            agents = agents.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.division.localizedCaseInsensitiveContains(searchText) ||
                $0.officeRole.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let div = filterDivision {
            agents = agents.filter { $0.division == div }
        }

        if showFavoritesOnly {
            agents = agents.filter { store.favoriteAgentIds.contains($0.id) }
        }

        switch sortBy {
        case .name: agents.sort { $0.name < $1.name }
        case .division: agents.sort { $0.division < $1.division }
        case .role: agents.sort { $0.officeRole < $1.officeRole }
        case .status: agents.sort { a, b in
            let aSeated = store.desks.contains { $0.agent?.id == a.id }
            let bSeated = store.desks.contains { $0.agent?.id == b.id }
            return aSeated == bSeated ? a.name < b.name : aSeated
        }
        }

        return agents
    }

    private let divisions = ["Engineering", "Design", "Marketing", "Operations", "Strategy", "Product", "Security", "QA"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Roster").font(.headline)
                Spacer()
                Text("\(filteredAgents.count) agents")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search + filters
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search agents...", text: $searchText).textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(7)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

                Toggle(isOn: $showFavoritesOnly) {
                    Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                        .foregroundStyle(showFavoritesOnly ? .yellow : .secondary)
                }
                .toggleStyle(.checkbox)
                .help("Favorites only")
            }

            HStack(spacing: 8) {
                Picker("Sort", selection: $sortBy) {
                    ForEach(SortOption.allCases, id: \.self) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                }
                .pickerStyle(.segmented)

                Menu {
                    Button("All Divisions") { filterDivision = nil }
                    Divider()
                    ForEach(divisions, id: \.self) { div in
                        Button(div) { filterDivision = div }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(filterDivision ?? "Division")
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 10))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
                }
            }

            // Agent list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredAgents) { agent in
                        RosterAgentRow(agent: agent, isSeated: store.desks.contains { $0.agent?.id == agent.id })
                            .onTapGesture {
                                store.showAgentDetail = agent
                            }
                    }
                }
                .padding()
            }
        }
        .frame(width: 560, height: 560)
    }
}

// MARK: - Roster Agent Row
struct RosterAgentRow: View {
    let agent: Agent
    let isSeated: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(agent.emoji).font(.system(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name)
                    .font(.system(size: 12, weight: .semibold))
                HStack(spacing: 6) {
                    Text(agent.division)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(agent.officeRole)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if isSeated {
                Text("Seated")
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.green.opacity(0.15), in: Capsule())
                    .foregroundStyle(.green)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

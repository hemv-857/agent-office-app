// WorkspaceOverviewView.swift
import SwiftUI

struct WorkspaceOverviewView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workspace Overview").font(.headline)
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
                    // Quick stats
                    HStack(spacing: 12) {
                        OverviewStatCard(title: "Agents", value: "\(store.allAgents.count)", icon: "person.3", color: .blue)
                        OverviewStatCard(title: "Desks", value: "\(store.desks.filter { $0.isOccupied }.count)/\(store.desks.count)", icon: "desktopcomputer", color: .green)
                        OverviewStatCard(title: "Results", value: "\(store.results.count)", icon: "doc.text", color: .orange)
                        OverviewStatCard(title: "Groups", value: "\(store.groups.count)", icon: "folder", color: .purple)
                    }

                    // Desk grid mini
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Office Grid").font(.system(size: 12, weight: .semibold))
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(store.desks) { desk in
                                DeskMiniCard(desk: desk)
                            }
                        }
                    }

                    // Recent activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Results").font(.system(size: 12, weight: .semibold))
                        ForEach(store.results.suffix(3)) { result in
                            HStack {
                                Text(result.agentName)
                                    .font(.system(size: 10))
                                    .frame(width: 80, alignment: .leading)
                                Text(String(result.response.prefix(50)))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Spacer()
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
        .frame(width: 550, height: 450)
    }
}

// MARK: - Overview Stat Card
struct OverviewStatCard: View {
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
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Desk Mini Card
struct DeskMiniCard: View {
    let desk: Desk

    var body: some View {
        VStack(spacing: 2) {
            if let agent = desk.agent {
                Text(agent.emoji).font(.system(size: 16))
                Text(agent.name)
                    .font(.system(size: 7))
                    .lineLimit(1)
            } else {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(.tertiary)
                Text(desk.role.rawValue)
                    .font(.system(size: 7))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 50, height: 50)
        .background(desk.isOccupied ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}

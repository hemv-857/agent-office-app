// WorkflowWorkspaceStatisticsView.swift
import SwiftUI

struct WorkflowWorkspaceStatisticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workspace Statistics").font(.headline)
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
                    // Office stats
                    HStack(spacing: 12) {
                        WorkspaceStatCard(title: "Desks", value: "\(store.desks.count)", icon: "desktopcomputer", color: .blue)
                        WorkspaceStatCard(title: "Occupied", value: "\(store.desks.filter { $0.isOccupied }.count)", icon: "person.fill", color: .green)
                        WorkspaceStatCard(title: "Empty", value: "\(store.desks.filter { !$0.isOccupied }.count)", icon: "plus.circle", color: .orange)
                    }

                    // Results stats
                    HStack(spacing: 12) {
                        WorkspaceStatCard(title: "Results", value: "\(store.results.count)", icon: "doc.text", color: .purple)
                        WorkspaceStatCard(title: "Groups", value: "\(store.groups.count)", icon: "folder", color: .yellow)
                        WorkspaceStatCard(title: "Presets", value: "\(store.presets.count)", icon: "slider.horizontal.3", color: .pink)
                    }

                    // Workspace layout
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Office Layout").font(.system(size: 12, weight: .semibold))
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                            ForEach(store.desks) { desk in
                                WorkspaceMiniDesk(desk: desk)
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
        .frame(width: 450, height: 450)
    }
}

// MARK: - Workspace Stat Card
struct WorkspaceStatCard: View {
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

// MARK: - Workspace Mini Desk
struct WorkspaceMiniDesk: View {
    let desk: Desk

    var body: some View {
        VStack(spacing: 2) {
            if let agent = desk.agent {
                Text(agent.emoji).font(.system(size: 12))
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 32, height: 32)
        .background(desk.isOccupied ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 4))
    }
}

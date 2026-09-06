// WorkflowWorkspaceOverviewView.swift
import SwiftUI

struct WorkflowWorkspaceOverviewView: View {
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
                VStack(spacing: 12) {
                    // Quick stats
                    HStack(spacing: 12) {
                        WorkspaceOverviewStatCard(title: "Total Agents", value: "\(store.allAgents.count)", icon: "person.3", color: .blue)
                        WorkspaceOverviewStatCard(title: "Active", value: "\(store.desks.filter { $0.isOccupied }.count)", icon: "bolt.fill", color: .green)
                        WorkspaceOverviewStatCard(title: "Results", value: "\(store.results.count)", icon: "doc.text", color: .orange)
                        WorkspaceOverviewStatCard(title: "Cost Today", value: String(format: "$%.2f", store.todayCost), icon: "dollarsign.circle", color: .purple)
                    }

                    // Office layout
                    GroupBox("Office Layout") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(Array(store.desks.enumerated()), id: \.element.id) { idx, desk in
                                WorkspaceDeskMini(desk: desk, number: idx + 1)
                            }
                        }
                        .padding(8)
                    }

                    // Recent activity
                    GroupBox("Recent Activity") {
                        VStack(spacing: 4) {
                            ForEach(store.activityLog.suffix(5)) { activity in
                                HStack {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 6, height: 6)
                                    Text(activity.message)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(activity.timestamp, style: .relative)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            if store.activityLog.isEmpty {
                                Text("No recent activity")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(8)
                    }

                    // Quick actions
                    GroupBox("Quick Actions") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            WorkspaceQuickActionCard(icon: "person.badge.plus", title: "Add Agent", color: .blue) { store.showCustomAgent = true; dismiss() }
                            WorkspaceQuickActionCard(icon: "square.and.arrow.up", title: "Export", color: .green) { store.showExport = true; dismiss() }
                            WorkspaceQuickActionCard(icon: "gearshape", title: "Settings", color: .purple) { store.showSettings = true; dismiss() }
                            WorkspaceQuickActionCard(icon: "bell", title: "Notifications", color: .orange) { store.showNotificationsCenter = true; dismiss() }
                            WorkspaceQuickActionCard(icon: "arrow.clockwise", title: "Backup", color: .teal) { store.showBackupRestore = true; dismiss() }
                            WorkspaceQuickActionCard(icon: "chart.bar.fill", title: "Analytics", color: .pink) { store.showAnalyticsDashboard = true; dismiss() }
                        }
                        .padding(8)
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
        .frame(width: 560, height: 560)
    }
}

// MARK: - Workspace Overview Stat Card
struct WorkspaceOverviewStatCard: View {
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

// MARK: - Workspace Desk Mini
struct WorkspaceDeskMini: View {
    let desk: Desk
    let number: Int

    var body: some View {
        VStack(spacing: 3) {
            if let agent = desk.agent {
                Text(agent.emoji).font(.system(size: 14))
                Text(agent.name)
                    .font(.system(size: 7))
                    .lineLimit(1)
            } else {
                Text("\(number)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Text(desk.role.rawValue)
                    .font(.system(size: 7))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 48, height: 48)
        .background(desk.isOccupied ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Workspace Quick Action Card
struct WorkspaceQuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// WorkflowAgentAgentWorkspaceOverviewView.swift
import SwiftUI

struct WorkflowAgentAgentWorkspaceOverviewView: View {
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

            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                OverviewCard(title: "Active Agents", value: "6", icon: "person.3.fill", color: .blue)
                OverviewCard(title: "Tasks Today", value: "47", icon: "checkmark.circle.fill", color: .green)
                OverviewCard(title: "Cost Today", value: "$2.34", icon: "dollarsign.circle.fill", color: .orange)
                OverviewCard(title: "Success Rate", value: "96.2%", icon: "chart.line.uptrend.xyaxis", color: .purple)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Quick actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        QuickActionButton(title: "New Session", icon: "plus.circle", color: .blue) { }
                        QuickActionButton(title: "Run Workflow", icon: "play.circle", color: .green) { }
                        QuickActionButton(title: "View Reports", icon: "doc.text", color: .purple) { }
                        QuickActionButton(title: "Settings", icon: "gear", color: .gray) { }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)

            Divider()

            // Recent activity
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Activity")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                VStack(spacing: 4) {
                    ActivityItem(time: "10:32", action: "Builder completed API /users", agent: "Builder", color: .green)
                    ActivityItem(time: "10:28", action: "Reviewer approved PR #42", agent: "Reviewer", color: .blue)
                    ActivityItem(time: "10:15", action: "Architect updated design doc", agent: "Architect", color: .purple)
                    ActivityItem(time: "09:45", action: "Tester ran integration suite", agent: "Tester", color: .orange)
                    ActivityItem(time: "09:30", action: "Security scan completed", agent: "Security", color: .red)
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }
}

// MARK: - Overview Card
struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .frame(width: 80, height: 70)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Item
struct ActivityItem: View {
    let time: String
    let action: String
    let agent: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(time)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 1) {
                Text(action)
                    .font(.system(size: 10, weight: .medium))
                Text(agent)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
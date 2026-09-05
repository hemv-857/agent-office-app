// WorkflowWorkspaceDashboardView.swift
import SwiftUI

struct WorkflowWorkspaceDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workspace Dashboard").font(.headline)
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
                        DashboardStat(title: "Agents", value: "\(store.allAgents.count)", icon: "person.3", color: .blue)
                        DashboardStat(title: "Active", value: "\(store.desks.filter { $0.isOccupied }.count)", icon: "bolt.fill", color: .green)
                        DashboardStat(title: "Results", value: "\(store.results.count)", icon: "doc.text", color: .orange)
                        DashboardStat(title: "Cost", value: String(format: "$%.2f", store.todayCost), icon: "dollarsign.circle", color: .purple)
                    }

                    // Office grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Office Grid").font(.system(size: 12, weight: .semibold))
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                            ForEach(store.desks) { desk in
                                DashboardDeskCell(desk: desk)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Recent results
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Results").font(.system(size: 12, weight: .semibold))
                        ForEach(store.results.suffix(3)) { result in
                            HStack {
                                Text(result.agentName)
                                    .font(.system(size: 10, weight: .medium))
                                    .frame(width: 60, alignment: .leading)
                                Text(String(result.response.prefix(40)))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Spacer()
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
        .frame(width: 500, height: 480)
    }
}

// MARK: - Dashboard Stat
struct DashboardStat: View {
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
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Dashboard Desk Cell
struct DashboardDeskCell: View {
    let desk: Desk

    var body: some View {
        VStack(spacing: 2) {
            if let agent = desk.agent {
                Text(agent.emoji).font(.system(size: 14))
                Text(agent.name)
                    .font(.system(size: 7))
                    .lineLimit(1)
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                Text(desk.role.rawValue)
                    .font(.system(size: 7))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 44, height: 44)
        .background(desk.isOccupied ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}

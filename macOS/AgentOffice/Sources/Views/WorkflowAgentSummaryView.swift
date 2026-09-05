// WorkflowAgentSummaryView.swift
import SwiftUI

struct WorkflowAgentSummaryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Summary").font(.headline)
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
                    // Overview
                    HStack(spacing: 12) {
                        SummaryCard(title: "Total", value: "\(store.allAgents.count)", color: .blue)
                        SummaryCard(title: "Active", value: "\(store.desks.filter { $0.isOccupied }.count)", color: .green)
                        SummaryCard(title: "Idle", value: "\(store.allAgents.count - store.desks.filter { $0.isOccupied }.count)", color: .gray)
                    }

                    // By division
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Division").font(.system(size: 12, weight: .semibold))
                        let divisions = Dictionary(grouping: store.allAgents, by: \.division)
                        ForEach(divisions.sorted(by: { $0.key < $1.key }), id: \.key) { division, agents in
                            HStack {
                                Text(division)
                                    .font(.system(size: 11))
                                Spacer()
                                Text("\(agents.count)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // By role
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Role").font(.system(size: 12, weight: .semibold))
                        let roles = Dictionary(grouping: store.allAgents, by: \.officeRole)
                        ForEach(roles.sorted(by: { $0.key < $1.key }), id: \.key) { role, agents in
                            HStack {
                                Text(role)
                                    .font(.system(size: 11))
                                Spacer()
                                Text("\(agents.count)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
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
        .frame(width: 420, height: 480)
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

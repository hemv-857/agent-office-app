// WorkflowAgentAgentSchedulingView.swift
import SwiftUI

struct WorkflowAgentAgentSchedulingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    @State private var schedule: [String: [String: Bool]] = [:]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Scheduling").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Header
            HStack(spacing: 0) {
                Text("Agent")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .leading)
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            Divider()

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(agents, id: \.self) { agent in
                        SchedulingRow(
                            agent: agent,
                            days: days,
                            schedule: schedule[agent] ?? [:],
                            onToggle: { day in
                                var agentSchedule = schedule[agent] ?? [:]
                                agentSchedule[day] = !(agentSchedule[day] ?? false)
                                schedule[agent] = agentSchedule
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                Button("Clear All") { schedule.removeAll() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 580, height: 420)
        .onAppear { randomize() }
    }

    private func randomize() {
        var newSchedule: [String: [String: Bool]] = [:]
        for agent in agents {
            var days: [String: Bool] = [:]
            for day in self.days {
                days[day] = Bool.random()
            }
            newSchedule[agent] = days
        }
        schedule = newSchedule
    }
}

// MARK: - Scheduling Row
struct SchedulingRow: View {
    let agent: String
    let days: [String]
    let schedule: [String: Bool]
    let onToggle: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(agent)
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 70, alignment: .leading)
            ForEach(days, id: \.self) { day in
                Button(action: { onToggle(day) }) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(schedule[day] == true ? .blue : Color(nsColor: .controlBackgroundColor))
                        .frame(height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.quaternary, lineWidth: 0.5)
                        )
                        .overlay(
                            Text(schedule[day] == true ? "●" : "")
                                .font(.system(size: 8))
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
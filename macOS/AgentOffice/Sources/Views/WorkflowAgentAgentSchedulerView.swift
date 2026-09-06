// WorkflowAgentAgentSchedulerView.swift
import SwiftUI

struct WorkflowAgentAgentSchedulerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let scheduled: [(String, String, String, String, Bool)] = [
        ("Daily Standup", "09:00", "Daily", "Planner + Team", true),
        ("Code Review Batch", "14:00", "Weekdays", "Reviewer", true),
        ("Security Scan", "22:00", "Daily", "Security", true),
        ("Weekly Report", "Friday 17:00", "Weekly", "Planner", true),
        ("Model Retraining", "02:00", "Monthly", "Builder", false),
        ("Cache Cleanup", "03:00", "Weekly", "System", true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Scheduler").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(scheduled.indices, id: \.self) { i in
                        ScheduledTaskRow(
                            name: scheduled[i].0,
                            time: scheduled[i].1,
                            frequency: scheduled[i].2,
                            agents: scheduled[i].3,
                            enabled: scheduled[i].4
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Add Schedule") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 420)
    }
}

// MARK: - Scheduled Task Row
struct ScheduledTaskRow: View {
    let name: String
    let time: String
    let frequency: String
    let agents: String
    let enabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: enabled ? "calendar.badge.checkmark" : "calendar.badge.exclamationmark")
                .foregroundStyle(enabled ? .green : .orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                HStack(spacing: 8) {
                    Label(time, systemImage: "clock")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Label(frequency, systemImage: "repeat")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(agents)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .trailing)

            Toggle("", isOn: .constant(enabled))
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
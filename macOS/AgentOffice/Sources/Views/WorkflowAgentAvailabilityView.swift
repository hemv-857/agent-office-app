// WorkflowAgentAvailabilityView.swift
import SwiftUI

struct WorkflowAgentAvailabilityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let agents: [(String, String, Bool, String)] = [
        ("Architect", "In meeting", false, "30 min"),
        ("Builder", "Working on API", true, "Available now"),
        ("Reviewer", "In code review", false, "15 min"),
        ("Tester", "Running tests", true, "Available now"),
        ("Planner", "Sprint planning", false, "1 hour"),
        ("Security", "Available", true, "Available now"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Availability").font(.headline)
                Spacer()
                Text("\(agents.filter { $0.2 }.count)/\(agents.count) available")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(agents.indices, id: \.self) { i in
                        AvailabilityRow(
                            name: agents[i].0,
                            activity: agents[i].1,
                            available: agents[i].2,
                            freeIn: agents[i].3
                        )
                    }
                }
                .padding()
            }

            // Summary
            Divider()
            HStack(spacing: 16) {
                AvailabilityStat(label: "Available", value: "\(agents.filter { $0.2 }.count)", color: .green)
                AvailabilityStat(label: "Busy", value: "\(agents.filter { !$0.2 }.count)", color: .orange)
                AvailabilityStat(label: "Total", value: "\(agents.count)", color: .blue)
            }
            .padding(12)

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

// MARK: - Availability Row
struct AvailabilityRow: View {
    let name: String
    let activity: String
    let available: Bool
    let freeIn: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(available ? .green : .orange)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                Text(activity)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(freeIn)
                .font(.system(size: 10))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(available ? .green.opacity(0.1) : .orange.opacity(0.1), in: Capsule())
                .foregroundStyle(available ? .green : .orange)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Availability Stat
struct AvailabilityStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

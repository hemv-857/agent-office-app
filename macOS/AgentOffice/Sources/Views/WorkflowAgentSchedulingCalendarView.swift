// WorkflowAgentSchedulingCalendarView.swift
import SwiftUI

struct WorkflowAgentSchedulingCalendarView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedDate = Date()
    @State private var selectedAgent = ""

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]
    private let timeSlots = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"]

    private let schedule: [(String, String, String, Color)] = [
        ("9:00 AM", "Architect", "System Design Review", .blue),
        ("10:00 AM", "Builder", "API Implementation", .green),
        ("11:00 AM", "Reviewer", "Code Review Sprint", .purple),
        ("1:00 PM", "Tester", "E2E Testing", .orange),
        ("2:00 PM", "Planner", "Sprint Planning", .teal),
        ("3:00 PM", "Security", "Security Audit", .red),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Schedule").font(.headline)
                Spacer()
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .frame(width: 140)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            List {
                ForEach(Array(timeSlots.enumerated()), id: \.offset) { index, slot in
                    HStack(spacing: 0) {
                        Text(slot)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .trailing)
                            .padding(.trailing, 10)

                        Rectangle()
                            .fill(.quaternary)
                            .frame(width: 1)

                        if let event = schedule.first(where: { $0.0 == slot }) {
                            ScheduleEventCard(
                                agent: event.1,
                                task: event.2,
                                color: event.3
                            )
                            .padding(.leading, 10)
                        } else {
                            Rectangle()
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .frame(height: 50)
                                .padding(.leading, 10)
                        }
                    }
                    .frame(height: 55)
                }
            }
            .listStyle(.plain)

            // Agent legend
            Divider()
            HStack(spacing: 10) {
                ForEach(Array(agents.enumerated()), id: \.offset) { _, agent in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colorForAgent(agent))
                            .frame(width: 6, height: 6)
                        Text(agent)
                            .font(.system(size: 9))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }

    private func colorForAgent(_ agent: String) -> Color {
        switch agent {
        case "Architect": return .blue
        case "Builder": return .green
        case "Reviewer": return .purple
        case "Tester": return .orange
        case "Planner": return .teal
        case "Security": return .red
        default: return .secondary
        }
    }
}

// MARK: - Schedule Event Card
struct ScheduleEventCard: View {
    let agent: String
    let task: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(agent)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(color)
            Text(task)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

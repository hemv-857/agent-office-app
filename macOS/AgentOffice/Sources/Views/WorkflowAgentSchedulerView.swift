// WorkflowAgentSchedulerView.swift
import SwiftUI

struct WorkflowAgentSchedulerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedDate = Date()
    @State private var selectedAgent: Agent?
    @State private var scheduleType = "once"

    private let timeSlots = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"]

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

            HStack(spacing: 16) {
                // Calendar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date").font(.system(size: 12, weight: .semibold))
                    DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)

                    Picker("Repeat", selection: $scheduleType) {
                        Text("Once").tag("once")
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Time slots
                    Text("Time Slots").font(.system(size: 12, weight: .semibold))
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(timeSlots, id: \.self) { slot in
                                HStack {
                                    Text(slot)
                                        .font(.system(size: 10, design: .monospaced))
                                        .frame(width: 70, alignment: .leading)
                                    Circle()
                                        .fill(Int.random(in: 0...3) > 1 ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                    Text(Int.random(in: 0...3) > 1 ? "Scheduled" : "Open")
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .frame(height: 200)

                    // Agent picker
                    Text("Agent").font(.system(size: 12, weight: .semibold))
                    Picker("Agent", selection: $selectedAgent) {
                        Text("Select agent...").tag(nil as Agent?)
                        ForEach(store.allAgents.prefix(10)) { agent in
                            Text("\(agent.emoji) \(agent.name)").tag(agent as Agent?)
                        }
                    }
                }
            }
            .padding()

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Schedule") {
                    store.showToast("Scheduled for \(selectedDate.formatted(date: .abbreviated, time: .shortened))", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 560, height: 520)
    }
}

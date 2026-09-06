// WorkflowAgentWorkflowSchedulerView.swift
import SwiftUI

struct WorkflowAgentWorkflowSchedulerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedTime = Date()
    @State private var repeatDaily = false

    private let scheduled: [(String, String, String)] = [
        ("Daily Standup", "09:00 AM", "Every day"),
        ("Code Review", "02:00 PM", "Weekdays"),
        ("Weekly Report", "Friday 5 PM", "Weekly"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Scheduler").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // New schedule
            GroupBox("Schedule New") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Time:")
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    Toggle("Repeat daily", isOn: $repeatDaily)
                    Button("Add Schedule") {
                        store.showToast("Schedule added", type: .success)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Existing schedules
            GroupBox("Scheduled Workflows") {
                VStack(spacing: 4) {
                    ForEach(scheduled.indices, id: \.self) { i in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(scheduled[i].0)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(scheduled[i].2)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(scheduled[i].1)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 440, height: 440)
    }
}

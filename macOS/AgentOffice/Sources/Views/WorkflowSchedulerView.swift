// WorkflowSchedulerView.swift
import SwiftUI

struct WorkflowSchedulerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var scheduledWorkflows: [WorkflowScheduler.ScheduledWorkflow] = []
    @State private var showingAddSchedule = false
    @State private var scheduleName = ""
    @State private var schedulePrompt = ""
    @State private var scheduleMode: WorkflowMode = .parallel
    @State private var scheduleDate = Date()
    @State private var scheduleRecurrence: WorkflowScheduler.RecurrenceType = .none

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scheduled Workflows").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Scheduled workflows list
            if scheduledWorkflows.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No scheduled workflows").foregroundStyle(.secondary)
                    Text("Schedule workflows to run automatically")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(scheduledWorkflows) { workflow in
                        ScheduledWorkflowRow(workflow: workflow) {
                            toggleWorkflow(workflow)
                        } onDelete: {
                            deleteWorkflow(workflow)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Schedule Workflow") { showingAddSchedule = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingAddSchedule) {
            AddScheduleView(
                name: $scheduleName,
                prompt: $schedulePrompt,
                mode: $scheduleMode,
                date: $scheduleDate,
                recurrence: $scheduleRecurrence,
                onSave: addSchedule
            )
        }
        .onAppear {
            scheduledWorkflows = WorkflowScheduler.shared.scheduledWorkflows
        }
    }

    func addSchedule() {
        WorkflowScheduler.shared.scheduleWorkflow(
            name: scheduleName,
            prompt: schedulePrompt,
            mode: scheduleMode,
            agentRoles: [],
            date: scheduleDate,
            recurrence: scheduleRecurrence
        )
        scheduledWorkflows = WorkflowScheduler.shared.scheduledWorkflows
        scheduleName = ""
        schedulePrompt = ""
        showingAddSchedule = false
    }

    func toggleWorkflow(_ workflow: WorkflowScheduler.ScheduledWorkflow) {
        WorkflowScheduler.shared.toggleWorkflow(id: workflow.id)
        scheduledWorkflows = WorkflowScheduler.shared.scheduledWorkflows
    }

    func deleteWorkflow(_ workflow: WorkflowScheduler.ScheduledWorkflow) {
        WorkflowScheduler.shared.cancelWorkflow(id: workflow.id)
        scheduledWorkflows = WorkflowScheduler.shared.scheduledWorkflows
    }
}

// MARK: - Scheduled Workflow Row
struct ScheduledWorkflowRow: View {
    let workflow: WorkflowScheduler.ScheduledWorkflow
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workflow.name).font(.system(size: 12, weight: .medium))
                    Text(workflow.mode.rawValue.capitalized)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 3))
                        .foregroundStyle(.blue)
                }
                if let nextRun = workflow.nextRun {
                    Text("Next: \(nextRun.formatted(.relative(presentation: .named)))")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if let recurrence = workflow.recurrence, recurrence != .none {
                    Text(recurrence.rawValue)
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { workflow.isActive },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Schedule View
struct AddScheduleView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var prompt: String
    @Binding var mode: WorkflowMode
    @Binding var date: Date
    @Binding var recurrence: WorkflowScheduler.RecurrenceType
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Schedule Workflow").font(.headline)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Prompt", text: $prompt)
                .textFieldStyle(.roundedBorder)

            Picker("Mode", selection: $mode) {
                ForEach(WorkflowMode.allCases, id: \.self) { m in
                    Text(m.rawValue.capitalized).tag(m)
                }
            }

            DatePicker("Date & Time", selection: $date)

            Picker("Recurrence", selection: $recurrence) {
                ForEach(WorkflowScheduler.RecurrenceType.allCases, id: \.self) { r in
                    Text(r.rawValue).tag(r)
                }
            }

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Schedule") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || prompt.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}

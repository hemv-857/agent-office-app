// WorkflowScheduler.swift
import Foundation

class WorkflowScheduler: ObservableObject {
    static let shared = WorkflowScheduler()

    @Published var scheduledWorkflows: [ScheduledWorkflow] = []
    @Published var isSchedulerRunning = false

    struct ScheduledWorkflow: Identifiable, Codable {
        let id = UUID()
        let name: String
        let prompt: String
        let mode: WorkflowMode
        let agentRoles: [String]
        let scheduledDate: Date
        var isActive: Bool = true
        var recurrence: RecurrenceType?
        var lastRun: Date?
        var nextRun: Date?
    }

    enum RecurrenceType: String, Codable, CaseIterable {
        case none = "None"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }

    private var timer: Timer?

    private init() {
        loadScheduledWorkflows()
        startScheduler()
    }

    func scheduleWorkflow(name: String, prompt: String, mode: WorkflowMode, agentRoles: [String], date: Date, recurrence: RecurrenceType?) {
        let workflow = ScheduledWorkflow(
            name: name,
            prompt: prompt,
            mode: mode,
            agentRoles: agentRoles,
            scheduledDate: date,
            recurrence: recurrence,
            nextRun: date
        )

        scheduledWorkflows.append(workflow)
        saveScheduledWorkflows()
    }

    func cancelWorkflow(id: UUID) {
        scheduledWorkflows.removeAll { $0.id == id }
        saveScheduledWorkflows()
    }

    func toggleWorkflow(id: UUID) {
        if let index = scheduledWorkflows.firstIndex(where: { $0.id == id }) {
            scheduledWorkflows[index].isActive.toggle()
            saveScheduledWorkflows()
        }
    }

    func updateWorkflow(id: UUID, name: String?, prompt: String?, mode: WorkflowMode?, date: Date?, recurrence: RecurrenceType?) {
        if let index = scheduledWorkflows.firstIndex(where: { $0.id == id }) {
            if let name = name { scheduledWorkflows[index] = ScheduledWorkflow(
                name: name,
                prompt: scheduledWorkflows[index].prompt,
                mode: scheduledWorkflows[index].mode,
                agentRoles: scheduledWorkflows[index].agentRoles,
                scheduledDate: scheduledWorkflows[index].scheduledDate,
                isActive: scheduledWorkflows[index].isActive,
                recurrence: scheduledWorkflows[index].recurrence,
                lastRun: scheduledWorkflows[index].lastRun,
                nextRun: scheduledWorkflows[index].nextRun
            )}
            saveScheduledWorkflows()
        }
    }

    private func startScheduler() {
        isSchedulerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkScheduledWorkflows()
        }
    }

    private func checkScheduledWorkflows() {
        let now = Date()

        for workflow in scheduledWorkflows where workflow.isActive {
            if let nextRun = workflow.nextRun, nextRun <= now {
                executeScheduledWorkflow(workflow)
            }
        }
    }

    private func executeScheduledWorkflow(_ workflow: ScheduledWorkflow) {
        // Update last run and calculate next run
        if let index = scheduledWorkflows.firstIndex(where: { $0.id == workflow.id }) {
            scheduledWorkflows[index].lastRun = Date()

            if let recurrence = workflow.recurrence {
                scheduledWorkflows[index].nextRun = calculateNextRun(recurrence: recurrence)
            } else {
                scheduledWorkflows[index].isActive = false
            }
        }

        saveScheduledWorkflows()

        // Execute workflow through AppStore
        NotificationCenter.default.post(
            name: .executeScheduledWorkflow,
            object: nil,
            userInfo: [
                "prompt": workflow.prompt,
                "mode": workflow.mode.rawValue,
                "agentRoles": workflow.agentRoles
            ]
        )
    }

    private func calculateNextRun(recurrence: RecurrenceType) -> Date {
        let calendar = Calendar.current
        let now = Date()

        switch recurrence {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: now) ?? now
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: now) ?? now
        case .none:
            return now
        }
    }

    func getUpcomingWorkflows(limit: Int) -> [ScheduledWorkflow] {
        return scheduledWorkflows
            .filter { $0.isActive && ($0.nextRun ?? .distantFuture) > Date() }
            .sorted { ($0.nextRun ?? .distantFuture) < ($1.nextRun ?? .distantFuture) }
            .prefix(limit)
            .map { $0 }
    }

    func getOverdueWorkflows() -> [ScheduledWorkflow] {
        let now = Date()
        return scheduledWorkflows.filter { $0.isActive && ($0.nextRun ?? .distantFuture) < now }
    }

    private func saveScheduledWorkflows() {
        if let data = try? JSONEncoder().encode(scheduledWorkflows) {
            UserDefaults.standard.set(data, forKey: "scheduledWorkflows")
        }
    }

    private func loadScheduledWorkflows() {
        if let data = UserDefaults.standard.data(forKey: "scheduledWorkflows"),
           let workflows = try? JSONDecoder().decode([ScheduledWorkflow].self, from: data) {
            scheduledWorkflows = workflows
        }
    }
}

extension Notification.Name {
    static let executeScheduledWorkflow = Notification.Name("executeScheduledWorkflow")
}

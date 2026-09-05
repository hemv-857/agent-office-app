// AgentAvailabilityTracker.swift
import Foundation

class AgentAvailabilityTracker: ObservableObject {
    static let shared = AgentAvailabilityTracker()

    @Published var agentAvailability: [String: AgentAvailability] = [:]

    struct AgentAvailability: Codable {
        let agentId: String
        var isAvailable: Bool = true
        var currentTask: String?
        var taskStartTime: Date?
        var estimatedCompletion: Date?
        var queue: [QueuedTask] = []
        var maxConcurrentTasks: Int = 1
        var currentTaskCount: Int = 0
    }

    struct QueuedTask: Codable, Identifiable {
        let id = UUID()
        let prompt: String
        let priority: TaskPriority
        let addedAt: Date
    }

    enum TaskPriority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        case critical = 3
    }

    private init() {
        loadAvailability()
    }

    func setAgentBusy(agentId: String, task: String, estimatedDuration: TimeInterval) {
        var availability = agentAvailability[agentId] ?? AgentAvailability(agentId: agentId)

        availability.isAvailable = false
        availability.currentTask = task
        availability.taskStartTime = Date()
        availability.estimatedCompletion = Date().addingTimeInterval(estimatedDuration)
        availability.currentTaskCount += 1

        agentAvailability[agentId] = availability
        saveAvailability()
    }

    func setAgentAvailable(agentId: String) {
        var availability = agentAvailability[agentId] ?? AgentAvailability(agentId: agentId)

        availability.currentTask = nil
        availability.taskStartTime = nil
        availability.estimatedCompletion = nil
        availability.currentTaskCount = max(0, availability.currentTaskCount - 1)

        if availability.currentTaskCount == 0 {
            availability.isAvailable = true
        }

        agentAvailability[agentId] = availability
        saveAvailability()
    }

    func addToQueue(agentId: String, prompt: String, priority: TaskPriority) {
        var availability = agentAvailability[agentId] ?? AgentAvailability(agentId: agentId)

        let task = QueuedTask(prompt: prompt, priority: priority, addedAt: Date())
        availability.queue.append(task)

        // Sort by priority
        availability.queue.sort { $0.priority.rawValue > $1.priority.rawValue }

        agentAvailability[agentId] = availability
        saveAvailability()
    }

    func getNextTask(agentId: String) -> QueuedTask? {
        guard let availability = agentAvailability[agentId] else { return nil }
        return availability.queue.first
    }

    func removeNextTask(agentId: String) -> QueuedTask? {
        var availability = agentAvailability[agentId] ?? AgentAvailability(agentId: agentId)
        let task = availability.queue.popLast()
        agentAvailability[agentId] = availability
        saveAvailability()
        return task
    }

    func getAvailableAgents() -> [String] {
        return agentAvailability.filter { $0.value.isAvailable }.map { $0.key }
    }

    func getAgentWaitTime(agentId: String) -> TimeInterval {
        guard let availability = agentAvailability[agentId] else { return 0 }

        if availability.isAvailable { return 0 }

        // Calculate wait time based on queue
        let queueWait = Double(availability.queue.count) * 30.0 // Assume 30 seconds per task

        if let estimated = availability.estimatedCompletion {
            let remainingTime = estimated.timeIntervalSinceNow
            return max(0, remainingTime + queueWait)
        }

        return queueWait
    }

    func getQueuePosition(agentId: String, taskId: UUID) -> Int? {
        guard let availability = agentAvailability[agentId] else { return nil }
        return availability.queue.firstIndex { $0.id == taskId }
    }

    private func saveAvailability() {
        if let data = try? JSONEncoder().encode(agentAvailability) {
            UserDefaults.standard.set(data, forKey: "agentAvailability")
        }
    }

    private func loadAvailability() {
        if let data = UserDefaults.standard.data(forKey: "agentAvailability"),
           let availability = try? JSONDecoder().decode([String: AgentAvailability].self, from: data) {
            agentAvailability = availability
        }
    }
}

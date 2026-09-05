// AgentSkillTracker.swift
import Foundation

class AgentSkillTracker: ObservableObject {
    static let shared = AgentSkillTracker()

    @Published var agentSkills: [String: AgentSkills] = [:]

    struct AgentSkills: Codable {
        let agentId: String
        var completedTasks: Int = 0
        var totalTokensUsed: Int = 0
        var totalCost: Double = 0
        var avgResponseTime: Double = 0
        var successRate: Double = 1.0
        var specializations: [String] = []
        var lastActive: Date?
        var rating: Double = 0.0
        var taskHistory: [TaskRecord] = []
    }

    struct TaskRecord: Codable, Identifiable {
        let id = UUID()
        let timestamp: Date
        let taskType: String
        let tokensUsed: Int
        let cost: Double
        let duration: TimeInterval
        let success: Bool
    }

    private init() {
        loadSkills()
    }

    func recordTask(agentId: String, taskType: String, tokensUsed: Int, cost: Double, duration: TimeInterval, success: Bool) {
        var skills = agentSkills[agentId] ?? AgentSkills(agentId: agentId)

        skills.completedTasks += 1
        skills.totalTokensUsed += tokensUsed
        skills.totalCost += cost
        skills.lastActive = Date()

        // Update average response time
        let totalDuration = skills.avgResponseTime * Double(skills.completedTasks - 1) + duration
        skills.avgResponseTime = totalDuration / Double(skills.completedTasks)

        // Update success rate
        let totalTasks = skills.completedTasks
        let successCount = Double(totalTasks) * skills.successRate + (success ? 1.0 : 0.0)
        skills.successRate = successCount / Double(totalTasks)

        // Add task record
        let record = TaskRecord(
            timestamp: Date(),
            taskType: taskType,
            tokensUsed: tokensUsed,
            cost: cost,
            duration: duration,
            success: success
        )
        skills.taskHistory.append(record)

        // Keep only last 50 records
        if skills.taskHistory.count > 50 {
            skills.taskHistory = Array(skills.taskHistory.suffix(50))
        }

        // Update rating based on success rate and efficiency
        skills.rating = calculateRating(skills: skills)

        agentSkills[agentId] = skills
        saveSkills()
    }

    func getAgentStats(agentId: String) -> AgentSkills? {
        return agentSkills[agentId]
    }

    func getTopAgents(limit: Int) -> [(String, Double)] {
        return agentSkills.map { ($0.key, $0.value.rating) }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { ($0.0, $0.1) }
    }

    func getAgentEfficiency(agentId: String) -> Double {
        guard let skills = agentSkills[agentId] else { return 0 }
        guard skills.completedTasks > 0 else { return 0 }

        let tokensPerTask = Double(skills.totalTokensUsed) / Double(skills.completedTasks)
        let costPerTask = skills.totalCost / Double(skills.completedTasks)

        // Lower is better
        let efficiencyScore = 1.0 / (1.0 + tokensPerTask / 1000.0 + costPerTask * 100.0)
        return efficiencyScore * skills.successRate
    }

    private func calculateRating(skills: AgentSkills) -> Double {
        let successWeight = 0.4
        let efficiencyWeight = 0.3
        let recencyWeight = 0.3

        // Success rate component
        let successScore = skills.successRate

        // Efficiency component (inverse of tokens per task)
        let tokensPerTask = skills.totalTokensUsed / max(skills.completedTasks, 1)
        let efficiencyScore = 1.0 / (1.0 + Double(tokensPerTask) / 1000.0)

        // Recency component (days since last active)
        let daysSinceActive = skills.lastActive.map { Date().timeIntervalSince($0) / 86400.0 } ?? 30.0
        let recencyScore = 1.0 / (1.0 + daysSinceActive / 7.0)

        return (successScore * successWeight) +
               (efficiencyScore * efficiencyWeight) +
               (recencyScore * recencyWeight)
    }

    private func saveSkills() {
        if let data = try? JSONEncoder().encode(agentSkills) {
            UserDefaults.standard.set(data, forKey: "agentSkills")
        }
    }

    private func loadSkills() {
        if let data = UserDefaults.standard.data(forKey: "agentSkills"),
           let skills = try? JSONDecoder().decode([String: AgentSkills].self, from: data) {
            agentSkills = skills
        }
    }
}

// WorkflowAnalyticsService.swift
import Foundation

class WorkflowAnalyticsService: ObservableObject {
    static let shared = WorkflowAnalyticsService()

    @Published var analytics: WorkflowAnalytics = WorkflowAnalytics()

    struct WorkflowAnalytics: Codable {
        var totalWorkflows: Int = 0
        var totalTokens: Int = 0
        var totalCost: Double = 0
        var avgTokensPerWorkflow: Double = 0
        var avgCostPerWorkflow: Double = 0
        var successRate: Double = 1.0
        var mostUsedMode: String = ""
        var mostUsedAgent: String = ""
        var peakHour: Int = 0
        var dailyStats: [DailyStat] = []
        var modeStats: [ModeStat] = []
        var agentStats: [AgentStat] = []
    }

    struct DailyStat: Codable, Identifiable {
        let id = UUID()
        let date: Date
        var workflows: Int
        var tokens: Int
        var cost: Double
    }

    struct ModeStat: Codable, Identifiable {
        let id = UUID()
        let mode: String
        var count: Int
        var avgTokens: Double
        var avgCost: Double
        var successRate: Double
    }

    struct AgentStat: Codable, Identifiable {
        let id = UUID()
        let agentId: String
        var tasks: Int
        var tokens: Int
        var cost: Double
        var avgResponseTime: Double
    }

    private init() {
        loadAnalytics()
    }

    func recordWorkflow(mode: WorkflowMode, agents: [String], tokens: Int, cost: Double, success: Bool) {
        analytics.totalWorkflows += 1
        analytics.totalTokens += tokens
        analytics.totalCost += cost

        // Update averages
        analytics.avgTokensPerWorkflow = Double(analytics.totalTokens) / Double(analytics.totalWorkflows)
        analytics.avgCostPerWorkflow = analytics.totalCost / Double(analytics.totalWorkflows)

        // Update success rate
        let totalWorkflows = analytics.totalWorkflows
        let successCount = Double(totalWorkflows) * analytics.successRate + (success ? 1.0 : 0.0)
        analytics.successRate = successCount / Double(totalWorkflows)

        // Update mode stats
        updateModeStats(mode: mode.rawValue, tokens: tokens, cost: cost, success: success)

        // Update agent stats
        for agentId in agents {
            updateAgentStats(agentId: agentId, tokens: tokens / max(agents.count, 1), cost: cost / Double(max(agents.count, 1)))
        }

        // Update daily stats
        updateDailyStat(tokens: tokens, cost: cost)

        // Update most used mode and agent
        updateMostUsedStats()

        saveAnalytics()
    }

    private func updateModeStats(mode: String, tokens: Int, cost: Double, success: Bool) {
        if let index = analytics.modeStats.firstIndex(where: { $0.mode == mode }) {
            var stat = analytics.modeStats[index]
            stat.count += 1
            stat.avgTokens = (stat.avgTokens * Double(stat.count - 1) + Double(tokens)) / Double(stat.count)
            stat.avgCost = (stat.avgCost * Double(stat.count - 1) + cost) / Double(stat.count)
            let totalTasks = stat.count
            let successCount = Double(totalTasks) * stat.successRate + (success ? 1.0 : 0.0)
            stat.successRate = successCount / Double(totalTasks)
            analytics.modeStats[index] = stat
        } else {
            let stat = ModeStat(mode: mode, count: 1, avgTokens: Double(tokens), avgCost: cost, successRate: success ? 1.0 : 0.0)
            analytics.modeStats.append(stat)
        }
    }

    private func updateAgentStats(agentId: String, tokens: Int, cost: Double) {
        if let index = analytics.agentStats.firstIndex(where: { $0.agentId == agentId }) {
            var stat = analytics.agentStats[index]
            stat.tasks += 1
            stat.tokens += tokens
            stat.cost += cost
            analytics.agentStats[index] = stat
        } else {
            let stat = AgentStat(agentId: agentId, tasks: 1, tokens: tokens, cost: cost, avgResponseTime: 0)
            analytics.agentStats.append(stat)
        }
    }

    private func updateDailyStat(tokens: Int, cost: Double) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let index = analytics.dailyStats.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            analytics.dailyStats[index].workflows += 1
            analytics.dailyStats[index].tokens += tokens
            analytics.dailyStats[index].cost += cost
        } else {
            let stat = DailyStat(date: today, workflows: 1, tokens: tokens, cost: cost)
            analytics.dailyStats.append(stat)
        }

        // Keep only last 30 days
        if analytics.dailyStats.count > 30 {
            analytics.dailyStats = Array(analytics.dailyStats.suffix(30))
        }
    }

    private func updateMostUsedStats() {
        analytics.mostUsedMode = analytics.modeStats.max(by: { $0.count < $1.count })?.mode ?? ""
        analytics.mostUsedAgent = analytics.agentStats.max(by: { $0.tasks < $1.tasks })?.agentId ?? ""
    }

    func getTrend(days: Int) -> [DailyStat] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        return analytics.dailyStats.filter { $0.date >= startDate }
            .sorted { $0.date < $1.date }
    }

    func getAgentPerformance() -> [(String, Double)] {
        return analytics.agentStats.map { ($0.agentId, Double($0.tokens) / Double(max($0.tasks, 1))) }
            .sorted { $0.1 < $1.1 }
    }

    func getCostBreakdown() -> [(String, Double)] {
        return analytics.agentStats.map { ($0.agentId, $0.cost) }
            .sorted { $0.1 > $1.1 }
    }

    func exportAnalytics() -> Data? {
        return try? JSONEncoder().encode(analytics)
    }

    func importAnalytics(_ data: Data) {
        if let imported = try? JSONDecoder().decode(WorkflowAnalytics.self, from: data) {
            analytics = imported
            saveAnalytics()
        }
    }

    func resetAnalytics() {
        analytics = WorkflowAnalytics()
        saveAnalytics()
    }

    private func saveAnalytics() {
        if let data = try? JSONEncoder().encode(analytics) {
            UserDefaults.standard.set(data, forKey: "workflowAnalytics")
        }
    }

    private func loadAnalytics() {
        if let data = UserDefaults.standard.data(forKey: "workflowAnalytics"),
           let loaded = try? JSONDecoder().decode(WorkflowAnalytics.self, from: data) {
            analytics = loaded
        }
    }
}

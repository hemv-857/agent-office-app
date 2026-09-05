// WorkflowOptimizer.swift
import Foundation

class WorkflowOptimizer: ObservableObject {
    static let shared = WorkflowOptimizer()

    @Published var optimizationSuggestions: [OptimizationSuggestion] = []

    struct OptimizationSuggestion: Identifiable {
        let id = UUID()
        let type: SuggestionType
        let title: String
        let description: String
        let impact: ImpactLevel
        let agentIds: [String]
        let confidence: Double
    }

    enum SuggestionType: String, CaseIterable {
        case agentSwap = "Agent Swap"
        case workflowChange = "Workflow Change"
        case parallelOptimization = "Parallel Optimization"
        case promptOptimization = "Prompt Optimization"
        case costReduction = "Cost Reduction"
        case timeOptimization = "Time Optimization"
    }

    enum ImpactLevel: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    private init() {}

    func analyzeWorkflow(history: [WorkflowHistoryEntry]) {
        optimizationSuggestions = []

        // Analyze agent performance
        analyzeAgentPerformance(history: history)

        // Analyze workflow patterns
        analyzeWorkflowPatterns(history: history)

        // Analyze cost efficiency
        analyzeCostEfficiency(history: history)

        // Analyze time efficiency
        analyzeTimeEfficiency(history: history)
    }

    private func analyzeAgentPerformance(history: [WorkflowHistoryEntry]) {
        var agentStats: [String: (tasks: Int, tokens: Int, cost: Double)] = [:]

        for entry in history {
            for agent in entry.agents {
                var stats = agentStats[agent] ?? (tasks: 0, tokens: 0, cost: 0)
                stats.tasks += 1
                stats.tokens += entry.totalTokens / max(entry.agents.count, 1)
                stats.cost += entry.totalCost / Double(max(entry.agents.count, 1))
                agentStats[agent] = stats
            }
        }

        // Find underperforming agents
        let avgTokensPerTask = agentStats.values.map { Double($0.tokens) / Double($0.tasks) }.reduce(0, +) / Double(max(agentStats.count, 1))

        for (agentId, stats) in agentStats {
            let tokensPerTask = Double(stats.tokens) / Double(stats.tasks)
            if tokensPerTask > avgTokensPerTask * 1.5 {
                let suggestion = OptimizationSuggestion(
                    type: .agentSwap,
                    title: "Consider replacing \(agentId)",
                    description: "\(agentId) uses \(Int((tokensPerTask / avgTokensPerTask - 1) * 100))% more tokens than average",
                    impact: .medium,
                    agentIds: [agentId],
                    confidence: 0.7
                )
                optimizationSuggestions.append(suggestion)
            }
        }
    }

    private func analyzeWorkflowPatterns(history: [WorkflowHistoryEntry]) {
        // Find most common workflow modes
        var modeCount: [WorkflowMode: Int] = [:]
        for entry in history {
            modeCount[entry.mode, default: 0] += 1
        }

        // Suggest trying different modes
        if let mostUsed = modeCount.max(by: { $0.value < $1.value }),
           mostUsed.value > history.count / 2 {
            let suggestion = OptimizationSuggestion(
                type: .workflowChange,
                title: "Try a different workflow mode",
                description: "You've used \(mostUsed.key.rawValue) in \(mostUsed.value) of \(history.count) workflows",
                impact: .low,
                agentIds: [],
                confidence: 0.6
            )
            optimizationSuggestions.append(suggestion)
        }
    }

    private func analyzeCostEfficiency(history: [WorkflowHistoryEntry]) {
        guard history.count >= 3 else { return }

        // Compare recent vs older costs
        let recentCount = min(3, history.count)
        let recentCosts = Array(history.suffix(recentCount)).map { $0.totalCost / Double(max($0.agents.count, 1)) }
        let olderCosts = Array(history.prefix(max(1, history.count - recentCount))).map { $0.totalCost / Double(max($0.agents.count, 1)) }

        let recentAvg = recentCosts.reduce(0, +) / Double(recentCount)
        let olderAvg = olderCosts.isEmpty ? recentAvg : olderCosts.reduce(0, +) / Double(olderCosts.count)

        if recentAvg > olderAvg * 1.2 {
            let suggestion = OptimizationSuggestion(
                type: .costReduction,
                title: "Costs increasing",
                description: "Recent workflows cost \(Int((recentAvg / olderAvg - 1) * 100))% more than earlier ones",
                impact: .high,
                agentIds: [],
                confidence: 0.8
            )
            optimizationSuggestions.append(suggestion)
        }
    }

    private func analyzeTimeEfficiency(history: [WorkflowHistoryEntry]) {
        // This would need duration data from workflow history
        // Placeholder for future implementation
    }

    func suggestAgentPair(for taskType: String) -> [(String, String, Double)] {
        // Simple heuristic for agent pairing
        let pairs: [(String, String, Double)] = [
            ("architect", "developer", 0.9),
            ("developer", "qa", 0.85),
            ("pm", "designer", 0.8),
            ("researcher", "developer", 0.75),
            ("qa", "ops", 0.7)
        ]

        return pairs.filter { $0.0.contains(taskType.lowercased()) || $0.1.contains(taskType.lowercased()) }
    }
}

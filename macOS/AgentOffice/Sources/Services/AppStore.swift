// AppStore.swift
import Foundation
import SwiftUI
import Combine

@MainActor
final class AppStore: ObservableObject {
    // MARK: - Theme
    @AppStorage("theme") var theme: Theme = .dark

    // MARK: - Agent Catalog
    @Published var allAgents: [Agent] = []
    @Published var filteredAgents: [Agent] = []
    @Published var searchText = ""
    @Published var selectedDivision: AgentDivision? = nil

    // MARK: - Office State
    @Published var desks: [Desk] = [
        Desk(role: .pm), Desk(role: .ux), Desk(role: .dev), Desk(role: .qa),
        Desk(role: .be), Desk(role: .data), Desk(role: .ts), Desk(role: .support),
    ]

    // MARK: - Results
    @Published var results: [SessionResult] = []
    @Published var showResultsPanel = true
    @Published var selectedResults: Set<UUID> = []
    @Published var compareMode = false

    // MARK: - Prompt
    @Published var promptText = ""
    @Published var workflowMode: WorkflowMode = .parallel
    @Published var promptHistory: [String] = []

    // MARK: - UI State
    @Published var isRunning = false
    @Published var toast: Toast?
    @Published var showSettings = false
    @Published var showHelp = false
    @Published var showSidebar = true
    @Published var showCommandPalette = false
    @Published var showOnboarding = false
    @Published var showShortcuts = false
    @Published var showAgentDetail: Agent?
    @Published var showChat: ChatDestination?
    @Published var showCostTracker = false
    @Published var showLeaderboard = false
    @Published var showPipelineVisualizer = false
    @Published var showSessionNotes = false
    @Published var showActivityLog = false
    @Published var showCustomAgent = false
    @Published var showGroupSave = false
    @Published var showPresetSave = false
    @Published var showExport = false
    @Published var showProjectBuilder = false
    @Published var showAgentMemory = false
    @Published var showSessionReplay = false

    // MARK: - Provider
    @Published var selectedProvider: LLMProvider = .anthropic
    @Published var apiKey = ""
    @Published var selectedModel = "claude-sonnet-4-20250514"

    // MARK: - Groups & Presets
    @Published var groups: [AgentGroup] = []
    @Published var presets: [OfficePreset] = []

    // MARK: - Session Notes
    @Published var sessionNotes: [SessionNote] = []

    // MARK: - Activity Log
    @Published var activityLog: [ActivityEntry] = []
    @Published var showActivityBadge = false

    // MARK: - Cost History
    @Published var costHistory: [CostEntry] = []
    @Published var dailyBudget: Double = 10.0

    // MARK: - Agent Leaderboard
    @Published var leaderboard: [String: LeaderboardEntry] = [:]

    // MARK: - Chat
    @Published var chatMessages: [String: [ChatMessage]] = [:]
    @Published var chatInput = ""

    // MARK: - Pipeline
    @Published var pipelineSteps: [PipelineStep] = []
    @Published var approvalStep: PipelineStep?

    // MARK: - Agent Memory
    @Published var agentMemory: [AgentMemoryEntry] = []

    // MARK: - Context Window
    @Published var contextWindow = ContextWindow()

    // MARK: - Project Builder
    @Published var projectFiles: [ProjectFile] = []
    @Published var buildTasks: [BuildTask] = []
    @Published var buildLogs: [String] = []

    // MARK: - Onboarding
    @Published var onboardingStep = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false

    // MARK: - Computed
    var seatedAgents: [Agent] { desks.compactMap { $0.agent } }
    var seatedCount: Int { seatedAgents.count }
    var totalDesks: Int { desks.count }
    var seatedDisplay: String { "\(seatedCount)/\(totalDesks) seated" }
    var totalCost: Double { results.reduce(0) { $0 + $1.costUsd } }
    var totalTokens: Int { results.reduce(0) { $0 + $1.tokensUsed } }
    var todayCost: Double {
        let cal = Calendar.current
        return costHistory.filter { cal.isDateInToday($0.timestamp) }.reduce(0) { $0 + $1.cost }
    }

    // MARK: - Init
    init() {
        loadAgents()
        loadPersistedData()
        applyFilters()
        if !hasSeenOnboarding { showOnboarding = true }
    }

    // MARK: - Agent Loading
    func loadAgents() {
        let paths = [
            "../../../public/agents.json",
            "../../public/agents.json",
            "../agents.json",
            "agents.json"
        ]
        for relative in paths {
            let url = URL(fileURLWithPath: relative).standardized
            if let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([Agent].self, from: data) {
                allAgents = decoded
                return
            }
        }
    }

    // MARK: - Persistence
    func loadPersistedData() {
        if let data = UserDefaults.standard.data(forKey: "groups"),
           let decoded = try? JSONDecoder().decode([AgentGroup].self, from: data) {
            groups = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "presets"),
           let decoded = try? JSONDecoder().decode([OfficePreset].self, from: data) {
            presets = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "sessionNotes"),
           let decoded = try? JSONDecoder().decode([SessionNote].self, from: data) {
            sessionNotes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "costHistory"),
           let decoded = try? JSONDecoder().decode([CostEntry].self, from: data) {
            costHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "agentMemory"),
           let decoded = try? JSONDecoder().decode([AgentMemoryEntry].self, from: data) {
            agentMemory = decoded
        }
        apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        if let prov = UserDefaults.standard.string(forKey: "provider"),
           let p = LLMProvider(rawValue: prov) {
            selectedProvider = p
        }
    }

    func persist() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: "groups")
        }
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: "presets")
        }
        if let data = try? JSONEncoder().encode(sessionNotes) {
            UserDefaults.standard.set(data, forKey: "sessionNotes")
        }
        if let data = try? JSONEncoder().encode(costHistory) {
            UserDefaults.standard.set(data, forKey: "costHistory")
        }
        if let data = try? JSONEncoder().encode(agentMemory) {
            UserDefaults.standard.set(data, forKey: "agentMemory")
        }
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
        UserDefaults.standard.set(selectedProvider.rawValue, forKey: "provider")
    }

    // MARK: - Filtering
    func applyFilters() {
        var filtered = allAgents
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let division = selectedDivision {
            filtered = filtered.filter { $0.division == division.rawValue }
        }
        filteredAgents = filtered
    }

    // MARK: - Desk Operations
    func seatAgent(_ agent: Agent, at role: AgentRole) {
        if let idx = desks.firstIndex(where: { $0.role == role }) {
            desks[idx].agent = agent
            desks[idx].status = .idle
        }
        logActivity("Seated \(agent.name) at \(role.rawValue)")
    }

    func removeAgent(from role: AgentRole) {
        if let idx = desks.firstIndex(where: { $0.role == role }) {
            let name = desks[idx].agent?.name ?? "Agent"
            desks[idx].agent = nil
            desks[idx].status = .idle
            logActivity("Removed \(name) from \(role.rawValue)")
        }
    }

    func clearOffice() {
        for i in desks.indices {
            desks[i].agent = nil
            desks[i].status = .idle
        }
        logActivity("Cleared office")
    }

    // MARK: - Activity Log
    func logActivity(_ message: String, type: ActivityType = .info) {
        activityLog.insert(ActivityEntry(message: message, type: type, timestamp: Date()), at: 0)
        showActivityBadge = true
        if activityLog.count > 200 { activityLog = Array(activityLog.prefix(200)) }
    }

    // MARK: - Execution
    func runAll() {
        guard !isRunning else { return }
        let seated = desks.filter { $0.isOccupied }
        guard !seated.isEmpty else { showToast("No agents seated", type: .error); return }
        guard !promptText.isEmpty else { showToast("Enter a prompt", type: .error); return }

        isRunning = true
        promptHistory.insert(promptText, at: 0)
        if promptHistory.count > 50 { promptHistory = Array(promptHistory.prefix(50)) }

        switch workflowMode {
        case .parallel: runParallel(seated)
        case .pipeline: runPipeline(seated)
        case .synthesis: runSynthesis(seated)
        case .review: runReview(seated)
        case .debate: runDebate(seated)
        default: runParallel(seated)
        }
    }

    private func runParallel(_ seated: [Desk]) {
        results = seated.map { desk in
            SessionResult(agentId: desk.agent!.id, agentName: desk.agent!.name, status: .working, startTime: Date())
        }
        for i in desks.indices where desks[i].isOccupied { desks[i].status = .working }

        Task {
            let service = LLMService(provider: selectedProvider, apiKey: apiKey)
            await withTaskGroup(of: Void.self) { group in
                for desk in seated {
                    group.addTask { [self] in
                        await self.executeAgent(desk.agent!, service: service)
                    }
                }
            }
            finishRun()
        }
    }

    private func runPipeline(_ seated: [Desk]) {
        let ordered = seated.sorted { lhs, rhs in
            let order: [AgentRole: Int] = [.arch: 0, .dev: 1, .qa: 2, .ops: 3, .pm: 4]
            return (order[lhs.role] ?? 99) < (order[rhs.role] ?? 99)
        }
        pipelineSteps = ordered.map { PipelineStep(agentName: $0.agent!.name, agentRole: $0.role.rawValue) }
        results = ordered.map { SessionResult(agentId: $0.agent!.id, agentName: $0.agent!.name, status: .working, startTime: Date()) }
        isRunning = true

        Task {
            let service = LLMService(provider: selectedProvider, apiKey: apiKey)
            var context = promptText
            for (i, desk) in ordered.enumerated() {
                if let deskIdx = desks.firstIndex(where: { $0.agent?.id == desk.agent?.id }) {
                    desks[deskIdx].status = .working
                }
                if let stepIdx = pipelineSteps.firstIndex(where: { $0.agentName == desk.agent?.name }) {
                    pipelineSteps[stepIdx].status = .working
                }
                let response = try? await service.execute(systemPrompt: desk.agent!.systemPrompt, userMessage: context)
                let text = response?.text ?? "Error"
                if let rIdx = results.firstIndex(where: { $0.agentId == desk.agent?.id }) {
                    results[rIdx].response = text
                    results[rIdx].status = .done
                    results[rIdx].tokensUsed = response?.tokens ?? 0
                    results[rIdx].costUsd = response?.cost ?? 0
                }
                if let stepIdx = pipelineSteps.firstIndex(where: { $0.agentName == desk.agent?.name }) {
                    pipelineSteps[stepIdx].status = .done
                    pipelineSteps[stepIdx].output = text
                }
                if let deskIdx = desks.firstIndex(where: { $0.agent?.id == desk.agent?.id }) {
                    desks[deskIdx].status = .done
                }
                context = "Previous agent output:\n\(text)\n\nOriginal task: \(promptText)"
            }
            finishRun()
        }
    }

    private func runSynthesis(_ seated: [Desk]) {
        results = seated.map { SessionResult(agentId: $0.agent!.id, agentName: $0.agent!.name, status: .working, startTime: Date()) }
        for i in desks.indices where desks[i].isOccupied { desks[i].status = .working }

        Task {
            let service = LLMService(provider: selectedProvider, apiKey: apiKey)
            await withTaskGroup(of: Void.self) { group in
                for desk in seated {
                    group.addTask { [self] in
                        await self.executeAgent(desk.agent!, service: service)
                    }
                }
            }
            // Synthesize
            let allResponses = results.map { "**\($0.agentName)**: \($0.response)" }.joined(separator: "\n\n")
            let synthResult = SessionResult(agentId: "synthesis", agentName: "Synthesis", status: .working, startTime: Date())
            results.append(synthResult)
            let response = try? await service.execute(
                systemPrompt: "Synthesize these agent responses into a unified, comprehensive answer.",
                userMessage: "Task: \(promptText)\n\nResponses:\n\(allResponses)"
            )
            if let idx = results.firstIndex(where: { $0.agentId == "synthesis" }) {
                results[idx].response = response?.text ?? "Synthesis failed"
                results[idx].status = .done
            }
            finishRun()
        }
    }

    private func runReview(_ seated: [Desk]) {
        runParallel(seated)
        // Cross-review happens after parallel completes
    }

    private func runDebate(_ seated: [Desk]) {
        guard seated.count >= 2 else { runParallel(seated); return }
        results = seated.map { SessionResult(agentId: $0.agent!.id, agentName: $0.agent!.name, status: .working, startTime: Date()) }
        for i in desks.indices where desks[i].isOccupied { desks[i].status = .working }

        Task {
            let service = LLMService(provider: selectedProvider, apiKey: apiKey)
            // Round 1: Each states position
            var positions: [String: String] = [:]
            for desk in seated {
                let resp = try? await service.execute(systemPrompt: desk.agent!.systemPrompt, userMessage: "State your position on: \(promptText)")
                positions[desk.agent!.name] = resp?.text ?? ""
                if let idx = results.firstIndex(where: { $0.agentId == desk.agent?.id }) {
                    results[idx].response = resp?.text ?? ""
                    results[idx].status = .done
                }
            }
            // Round 2: Critique
            for desk in seated {
                let others = positions.filter { $0.key != desk.agent!.name }.map { "**\($0.key)**: \($0.value)" }.joined(separator: "\n\n")
                let resp = try? await service.execute(
                    systemPrompt: desk.agent!.systemPrompt,
                    userMessage: "Critique these positions and defend your own:\n\(others)"
                )
                if let idx = results.firstIndex(where: { $0.agentId == desk.agent?.id }) {
                    results[idx].response += "\n\n--- Critique ---\n\(resp?.text ?? "")"
                }
            }
            finishRun()
        }
    }

    private func executeAgent(_ agent: Agent, service: LLMService) async {
        if let idx = results.firstIndex(where: { $0.agentId == agent.id }) {
            let start = Date()
            do {
                let response = try await service.execute(systemPrompt: agent.systemPrompt, userMessage: promptText)
                results[idx].response = response.text
                results[idx].tokensUsed = response.tokens
                results[idx].costUsd = response.cost
                results[idx].elapsedMs = Date().timeIntervalSince(start) * 1000
                results[idx].status = .done
                if let deskIdx = desks.firstIndex(where: { $0.agent?.id == agent.id }) {
                    desks[deskIdx].status = .done
                }
                // Record cost
                let entry = CostEntry(agentName: agent.name, cost: response.cost, tokens: response.tokens, timestamp: Date())
                costHistory.append(entry)
                // Update leaderboard
                var lb = leaderboard[agent.id] ?? LeaderboardEntry(name: agent.name)
                lb.runs += 1
                lb.totalCost += response.cost
                lb.totalTokens += response.tokens
                leaderboard[agent.id] = lb
            } catch {
                results[idx].response = "Error: \(error.localizedDescription)"
                results[idx].status = .error
                if let deskIdx = desks.firstIndex(where: { $0.agent?.id == agent.id }) {
                    desks[deskIdx].status = .error
                }
            }
        }
    }

    private func finishRun() {
        isRunning = false
        for i in desks.indices where desks[i].status == .working {
            desks[i].status = .idle
        }
        persist()
        showToast("All agents completed", type: .success)
        logActivity("Run completed — \(results.count) agents", type: .success)
    }

    func cancelRun() {
        isRunning = false
        for i in desks.indices where desks[i].status == .working { desks[i].status = .idle }
        for i in results.indices where results[i].status == .working {
            results[i].status = .error
            results[i].response = "Cancelled"
        }
        showToast("Cancelled", type: .info)
    }

    // MARK: - Chat
    func sendChatMessage(to agentId: String) {
        guard !chatInput.isEmpty else { return }
        let msg = ChatMessage(role: .user, content: chatInput, timestamp: Date())
        chatMessages[agentId, default: []].append(msg)
        let userMsg = chatInput
        chatInput = ""

        Task {
            guard let agent = allAgents.first(where: { $0.id == agentId }) else { return }
            let service = LLMService(provider: selectedProvider, apiKey: apiKey)
            let history = (chatMessages[agentId] ?? []).map { "\($0.role == .user ? "User" : "Assistant"): \($0.content)" }.joined(separator: "\n")
            let response = try? await service.execute(
                systemPrompt: agent.systemPrompt,
                userMessage: "\(history)\nUser: \(userMsg)"
            )
            let reply = ChatMessage(role: .assistant, content: response?.text ?? "Error", timestamp: Date())
            chatMessages[agentId, default: []].append(reply)
        }
    }

    // MARK: - Groups & Presets
    func saveGroup(_ name: String) {
        let ids = desks.compactMap { $0.agent?.id }
        groups.append(AgentGroup(name: name, agentIds: ids))
        persist()
        showToast("Group saved", type: .success)
    }

    func savePreset(_ name: String) {
        var seating: [String: String] = [:]
        for desk in desks {
            if let agent = desk.agent {
                seating[desk.role.rawValue] = agent.id
            }
        }
        presets.append(OfficePreset(name: name, seating: seating))
        persist()
        showToast("Preset saved", type: .success)
    }

    func loadPreset(_ preset: OfficePreset) {
        clearOffice()
        for (roleStr, agentId) in preset.seating {
            if let role = AgentRole(rawValue: roleStr),
               let agent = allAgents.first(where: { $0.id == agentId }) {
                seatAgent(agent, at: role)
            }
        }
    }

    // MARK: - Session Notes
    func addNote(_ text: String, tags: [String] = []) {
        sessionNotes.append(SessionNote(text: text, tags: tags, timestamp: Date()))
        persist()
    }

    func deleteNote(_ note: SessionNote) {
        sessionNotes.removeAll { $0.id == note.id }
        persist()
    }

    // MARK: - Export
    func exportResultsAsMarkdown() -> String {
        results.map { r in
            "# \(r.agentName)\n\nStatus: \(r.status.rawValue)\nTokens: \(r.tokensUsed)\nCost: $\(String(format: "%.4f", r.costUsd))\nTime: \(r.elapsedMs > 0 ? String(format: "%.1fs", r.elapsedMs / 1000) : "N/A")\n\n---\n\n\(r.response)"
        }.joined(separator: "\n\n")
    }

    func exportResultsAsJSON() -> String {
        let data = results.map { ["agent": $0.agentName, "response": $0.response, "status": $0.status.rawValue, "cost": $0.costUsd, "tokens": $0.tokensUsed] as [String: Any] }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
              let json = String(data: jsonData, encoding: .utf8) else { return "[]" }
        return json
    }

    // MARK: - Agent Memory
    func addMemory(_ pattern: String, context: String, agentId: String) {
        agentMemory.append(AgentMemoryEntry(agentId: agentId, pattern: pattern, context: context, confidence: 0.8, timestamp: Date()))
        persist()
    }

    // MARK: - Toast
    func showToast(_ message: String, type: ToastType = .info) {
        toast = Toast(message: message, type: type)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.toast = nil }
    }
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Codable {
    var name: String = ""
    var runs: Int = 0
    var totalCost: Double = 0
    var totalTokens: Int = 0
    var avgCost: Double { runs > 0 ? totalCost / Double(runs) : 0 }
}

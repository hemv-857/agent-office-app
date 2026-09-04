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
        Desk(role: .pm),
        Desk(role: .ux),
        Desk(role: .dev),
        Desk(role: .qa),
        Desk(role: .be),
        Desk(role: .data),
        Desk(role: .ts),
        Desk(role: .support),
    ]

    // MARK: - Results
    @Published var results: [SessionResult] = []
    @Published var showResultsPanel = true

    // MARK: - Prompt
    @Published var promptText = ""
    @Published var workflowMode: WorkflowMode = .parallel

    // MARK: - UI State
    @Published var isRunning = false
    @Published var toast: Toast?
    @Published var showSettings = false
    @Published var showHelp = false
    @Published var showSidebar = true

    // MARK: - Provider
    @Published var selectedProvider: LLMProvider = .anthropic
    @Published var apiKey = ""
    @Published var selectedModel = "claude-sonnet-4-20250514"

    // MARK: - Computed
    var seatedAgents: [Agent] {
        desks.compactMap { $0.agent }
    }

    var seatedCount: Int { seatedAgents.count }
    var totalDesks: Int { desks.count }

    var seatedDisplay: String {
        "\(seatedCount)/\(totalDesks) seated"
    }

    // MARK: - Init
    init() {
        loadAgents()
        applyFilters()
    }

    // MARK: - Agent Loading
    func loadAgents() {
        // Try Bundle first, then fall back to file path
        if let url = Bundle.main.url(forResource: "agents", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Agent].self, from: data) {
            allAgents = decoded
            return
        }
        // Fallback: load from known path
        let paths = [
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
        print("Failed to load agents.json")
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
    }

    func removeAgent(from role: AgentRole) {
        if let idx = desks.firstIndex(where: { $0.role == role }) {
            desks[idx].agent = nil
            desks[idx].status = .idle
        }
    }

    func clearOffice() {
        for i in desks.indices {
            desks[i].agent = nil
            desks[i].status = .idle
        }
    }

    // MARK: - Execution
    func runAll() {
        guard !isRunning else { return }
        let seated = desks.filter { $0.isOccupied }
        guard !seated.isEmpty else {
            showToast("No agents seated", type: .error)
            return
        }

        isRunning = true
        results = seated.map { desk in
            SessionResult(
                agentId: desk.agent!.id,
                agentName: desk.agent!.name,
                status: .working,
                startTime: Date()
            )
        }

        for i in desks.indices where desks[i].isOccupied {
            desks[i].status = .working
        }

        // Execute via service
        Task {
            let service = LLMService(provider: selectedProvider, apiKey: apiKey)
            for desk in seated {
                guard let agent = desk.agent else { continue }
                if let idx = results.firstIndex(where: { $0.agentId == agent.id }) {
                    let start = Date()
                    do {
                        let response = try await service.execute(
                            systemPrompt: agent.systemPrompt,
                            userMessage: promptText
                        )
                        results[idx].response = response.text
                        results[idx].tokensUsed = response.tokens
                        results[idx].costUsd = response.cost
                        results[idx].elapsedMs = Date().timeIntervalSince(start) * 1000
                        results[idx].status = .done
                        if let deskIdx = desks.firstIndex(where: { $0.agent?.id == agent.id }) {
                            desks[deskIdx].status = .done
                        }
                    } catch {
                        results[idx].response = "Error: \(error.localizedDescription)"
                        results[idx].status = .error
                        if let deskIdx = desks.firstIndex(where: { $0.agent?.id == agent.id }) {
                            desks[deskIdx].status = .error
                        }
                    }
                }
            }
            isRunning = false
            showToast("All agents completed", type: .success)
        }
    }

    func cancelRun() {
        isRunning = false
        for i in desks.indices where desks[i].status == .working {
            desks[i].status = .idle
        }
        for i in results.indices where results[i].status == .working {
            results[i].status = .error
            results[i].response = "Cancelled"
        }
        showToast("Cancelled", type: .info)
    }

    // MARK: - Toast
    func showToast(_ message: String, type: ToastType = .info) {
        toast = Toast(message: message, type: type)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.toast = nil
        }
    }
}

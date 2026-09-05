// WorkflowChainBuilder.swift
import Foundation

class WorkflowChainBuilder: ObservableObject {
    static let shared = WorkflowChainBuilder()

    @Published var chains: [WorkflowChain] = []
    @Published var activeChain: WorkflowChain?

    struct WorkflowChain: Identifiable, Codable {
        let id = UUID()
        var name: String
        var steps: [ChainStep]
        var currentStepIndex: Int = 0
        var isActive: Bool = false
        var createdAt: Date
        var lastModified: Date
    }

    struct ChainStep: Identifiable, Codable {
        let id = UUID()
        var name: String
        var prompt: String
        var mode: WorkflowMode
        var agentRoles: [String]
        var condition: StepCondition?
        var status: StepStatus
        var output: String?
    }

    struct StepCondition: Codable {
        let type: ConditionType
        let value: String
    }

    enum ConditionType: String, Codable, CaseIterable {
        case outputContains = "Output Contains"
        case outputNotContains = "Output Not Contains"
        case successOnly = "On Success"
        case failureOnly = "On Failure"
        case always = "Always"
    }

    enum StepStatus: String, Codable, CaseIterable {
        case pending = "Pending"
        case running = "Running"
        case completed = "Completed"
        case failed = "Failed"
        case skipped = "Skipped"
    }

    private init() {
        loadChains()
    }

    func createChain(name: String, steps: [(String, String, WorkflowMode, [String])]) -> WorkflowChain {
        let chainSteps = steps.map { step in
            ChainStep(
                name: step.0,
                prompt: step.1,
                mode: step.2,
                agentRoles: step.3,
                status: .pending
            )
        }

        let chain = WorkflowChain(
            name: name,
            steps: chainSteps,
            createdAt: Date(),
            lastModified: Date()
        )

        chains.append(chain)
        saveChains()
        return chain
    }

    func addStep(to chainId: UUID, name: String, prompt: String, mode: WorkflowMode, agentRoles: [String]) {
        if let index = chains.firstIndex(where: { $0.id == chainId }) {
            let step = ChainStep(
                name: name,
                prompt: prompt,
                mode: mode,
                agentRoles: agentRoles,
                status: .pending
            )
            chains[index].steps.append(step)
            chains[index].lastModified = Date()
            saveChains()
        }
    }

    func removeStep(from chainId: UUID, stepId: UUID) {
        if let chainIndex = chains.firstIndex(where: { $0.id == chainId }) {
            chains[chainIndex].steps.removeAll { $0.id == stepId }
            chains[chainIndex].lastModified = Date()
            saveChains()
        }
    }

    func startChain(_ chainId: UUID) {
        if let index = chains.firstIndex(where: { $0.id == chainId }) {
            chains[index].isActive = true
            chains[index].currentStepIndex = 0
            activeChain = chains[index]
            saveChains()
        }
    }

    func executeNextStep() {
        guard var chain = activeChain else { return }
        guard chain.currentStepIndex < chain.steps.count else {
            completeChain()
            return
        }

        var step = chain.steps[chain.currentStepIndex]
        step.status = .running
        chain.steps[chain.currentStepIndex] = step

        // Execute through notification
        NotificationCenter.default.post(
            name: .executeChainStep,
            object: nil,
            userInfo: [
                "chainId": chain.id,
                "stepId": step.id,
                "prompt": step.prompt,
                "mode": step.mode.rawValue,
                "agentRoles": step.agentRoles
            ]
        )

        activeChain = chain
        saveChains()
    }

    func completeStep(stepId: UUID, output: String, success: Bool) {
        guard var chain = activeChain else { return }

        if let stepIndex = chain.steps.firstIndex(where: { $0.id == stepId }) {
            chain.steps[stepIndex].status = success ? .completed : .failed
            chain.steps[stepIndex].output = output
            chain.currentStepIndex += 1

            // Check if we should continue
            if success || shouldContinueOnFailure(chain: chain, stepIndex: stepIndex) {
                executeNextStep()
            } else {
                chain.isActive = false
            }

            activeChain = chain
            saveChains()
        }
    }

    private func shouldContinueOnFailure(chain: WorkflowChain, stepIndex: Int) -> Bool {
        guard stepIndex < chain.steps.count else { return false }
        guard let condition = chain.steps[stepIndex].condition else { return false }

        switch condition.type {
        case .failureOnly, .always:
            return true
        default:
            return false
        }
    }

    private func completeChain() {
        guard var chain = activeChain else { return }
        chain.isActive = false
        activeChain = nil

        if let index = chains.firstIndex(where: { $0.id == chain.id }) {
            chains[index].isActive = false
        }

        saveChains()

        NotificationCenter.default.post(name: .chainCompleted, object: nil, userInfo: ["chainId": chain.id])
    }

    func deleteChain(_ chainId: UUID) {
        chains.removeAll { $0.id == chainId }
        if activeChain?.id == chainId {
            activeChain = nil
        }
        saveChains()
    }

    func duplicateChain(_ chainId: UUID) -> WorkflowChain? {
        guard let chain = chains.first(where: { $0.id == chainId }) else { return nil }

        let newSteps = chain.steps.map { step -> ChainStep in
            ChainStep(
                name: step.name,
                prompt: step.prompt,
                mode: step.mode,
                agentRoles: step.agentRoles,
                condition: step.condition,
                status: .pending,
                output: nil
            )
        }

        let newChain = WorkflowChain(
            name: "\(chain.name) (Copy)",
            steps: newSteps,
            currentStepIndex: 0,
            isActive: false,
            createdAt: Date(),
            lastModified: Date()
        )

        chains.append(newChain)
        saveChains()
        return newChain
    }

    func getChainProgress(_ chainId: UUID) -> (completed: Int, total: Int, percentage: Double) {
        guard let chain = chains.first(where: { $0.id == chainId }) else {
            return (0, 0, 0)
        }

        let completed = chain.steps.filter { $0.status == .completed }.count
        let total = chain.steps.count
        let percentage = total > 0 ? Double(completed) / Double(total) : 0

        return (completed, total, percentage)
    }

    private func saveChains() {
        if let data = try? JSONEncoder().encode(chains) {
            UserDefaults.standard.set(data, forKey: "workflowChains")
        }
    }

    private func loadChains() {
        if let data = UserDefaults.standard.data(forKey: "workflowChains"),
           let loadedChains = try? JSONDecoder().decode([WorkflowChain].self, from: data) {
            chains = loadedChains
        }
    }
}

extension Notification.Name {
    static let executeChainStep = Notification.Name("executeChainStep")
    static let chainCompleted = Notification.Name("chainCompleted")
}

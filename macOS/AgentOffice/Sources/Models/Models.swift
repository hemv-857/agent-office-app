// Models.swift
import Foundation

// MARK: - Theme
enum Theme: String, CaseIterable, Codable {
    case dark, light, system
}

// MARK: - Agent Division
enum AgentDivision: String, CaseIterable, Codable, Hashable {
    case architect = "Architect"
    case builder = "Builder"
    case pm = "PM"
    case researcher = "Researcher"
    case qa = "QA"
    case support = "Support"
    case custom = "Custom"
}

// MARK: - Agent Role (desk position)
enum AgentRole: String, CaseIterable, Codable, Hashable {
    case pm, ux, dev, qa, be, data, ts, support
    case arch, res, designer, ops
}

// MARK: - Agent
struct Agent: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let division: String
    let officeRole: String
    let systemPrompt: String
    var emoji: String

    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(name.prefix(2))
    }
}

// MARK: - Agent Status
enum AgentStatus: String, Codable {
    case idle, working, done, error, blocked
}

// MARK: - Desk
struct Desk: Identifiable {
    let id = UUID()
    let role: AgentRole
    var agent: Agent?
    var status: AgentStatus = .idle

    var isOccupied: Bool { agent != nil }
}

// MARK: - Session Result
struct SessionResult: Identifiable {
    let id = UUID()
    let agentId: String
    let agentName: String
    var response: String = ""
    var status: AgentStatus = .idle
    var tokensUsed: Int = 0
    var costUsd: Double = 0
    var elapsedMs: Double = 0
    var startTime: Date?
}

// MARK: - Workflow Mode
enum WorkflowMode: String, CaseIterable, Codable {
    case parallel, pipeline, synthesis, review, debate
    case qualityGate = "quality-gate"
    case pipelineApproval = "pipeline-approval"
    case conditional, collab, builder

    var label: String {
        switch self {
        case .parallel: return "Parallel"
        case .pipeline: return "Pipeline"
        case .synthesis: return "Synthesis"
        case .review: return "Review"
        case .debate: return "Debate"
        case .qualityGate: return "Quality Gate"
        case .pipelineApproval: return "Pipeline + Approval"
        case .conditional: return "Conditional"
        case .collab: return "Collaborate"
        case .builder: return "Builder"
        }
    }
}

// MARK: - Provider
enum LLMProvider: String, CaseIterable, Codable {
    case anthropic, openai, ollama

    var displayName: String {
        switch self {
        case .anthropic: return "Anthropic"
        case .openai: return "OpenAI"
        case .ollama: return "Ollama"
        }
    }
}

// MARK: - Provider Model
struct ProviderModel: Identifiable, Hashable {
    let id: String
    let name: String
    let provider: LLMProvider
}

// MARK: - Toast
struct Toast: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
    var timestamp = Date()
}

enum ToastType {
    case success, error, info
}

// MARK: - Activity Entry
struct ActivityEntry: Identifiable {
    let id = UUID()
    let message: String
    let type: ActivityType
    let timestamp: Date
}

enum ActivityType {
    case success, error, info, warning
}

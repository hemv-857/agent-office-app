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
    var color: String = "#6366f1"
    var domain: String = ""
    var isCustom: Bool = false

    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(name.prefix(2))
    }
}

// MARK: - Agent Status
enum AgentStatus: String, Codable, CaseIterable {
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
    var isBookmarked = false
    var rating: RatingType?
}

enum RatingType: String, Codable { case up, down }

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

// MARK: - Toast
struct Toast: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
}

enum ToastType { case success, error, info }

// MARK: - Activity Entry
struct ActivityEntry: Identifiable {
    let id = UUID()
    let message: String
    let type: ActivityType
    let timestamp: Date
}

enum ActivityType: String { case success, error, info, warning }

// MARK: - Group
struct AgentGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var agentIds: [String]
}

// MARK: - Preset
struct OfficePreset: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var seating: [String: String] // role -> agentId
}

// MARK: - Session Note
struct SessionNote: Identifiable, Codable {
    var id = UUID()
    var text: String
    var tags: [String]
    var timestamp: Date
}

// MARK: - Cost Entry
struct CostEntry: Identifiable, Codable {
    var id = UUID()
    var agentName: String
    var cost: Double
    var tokens: Int
    var timestamp: Date
}

// MARK: - Chat Message
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatRole
    let content: String
    let timestamp: Date

    enum ChatRole { case user, assistant }
}

// MARK: - Workflow Template
struct WorkflowTemplate: Identifiable {
    let id: String
    let label: String
    let icon: String
    let prompt: String
    let agentRoles: [String]
    let workflowMode: WorkflowMode
    let description: String
}

// MARK: - Pipeline Step
struct PipelineStep: Identifiable {
    let id = UUID()
    let agentName: String
    let agentRole: String
    var status: AgentStatus = .idle
    var output: String = ""
}

// MARK: - Git Branch
struct GitBranch: Identifiable {
    let id = UUID()
    let name: String
    let isCurrent: Bool
}

// MARK: - Context Window
struct ContextWindow {
    var maxTokens: Int = 200_000
    var usedTokens: Int = 0
    var utilization: Double {
        maxTokens > 0 ? Double(usedTokens) / Double(maxTokens) : 0
    }
}

// MARK: - Project Builder
struct ProjectFile: Identifiable {
    let id = UUID()
    let path: String
    let content: String
}

struct BuildTask: Identifiable {
    let id = UUID()
    let label: String
    var status: AgentStatus = .idle
}

// MARK: - Agent Memory
struct AgentMemoryEntry: Identifiable, Codable {
    var id = UUID()
    var agentId: String
    var pattern: String
    var context: String
    var confidence: Double
    var timestamp: Date
}

// MARK: - Chat Destination
struct ChatDestination: Identifiable {
    let id = UUID()
    let agentId: String
    let agentName: String
}

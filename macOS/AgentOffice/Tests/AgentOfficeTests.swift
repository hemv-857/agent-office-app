// AgentOfficeTests.swift
import XCTest
@testable import AgentOffice

final class AgentOfficeTests: XCTestCase {

    // MARK: - Agent Model Tests
    func testAgentInitialization() {
        let agent = Agent(
            id: "test-agent",
            name: "Test Agent",
            description: "A test agent",
            division: "Builder",
            officeRole: "dev",
            systemPrompt: "You are a test agent",
            emoji: "🧪"
        )

        XCTAssertEqual(agent.id, "test-agent")
        XCTAssertEqual(agent.name, "Test Agent")
        XCTAssertEqual(agent.initials, "TA")
    }

    func testAgentInitials() {
        let agent = Agent(
            id: "test",
            name: "John Doe",
            description: "Test",
            division: "Builder",
            officeRole: "dev",
            systemPrompt: "Test",
            emoji: "👤"
        )

        XCTAssertEqual(agent.initials, "JD")
    }

    // MARK: - Desk Model Tests
    func testDeskInitialization() {
        let desk = Desk(role: .dev)

        XCTAssertEqual(desk.role, .dev)
        XCTAssertFalse(desk.isOccupied)
        XCTAssertNil(desk.agent)
        XCTAssertEqual(desk.status, .idle)
    }

    func testDeskSeatAgent() {
        var desk = Desk(role: .dev)
        let agent = Agent(
            id: "test",
            name: "Test",
            description: "Test",
            division: "Builder",
            officeRole: "dev",
            systemPrompt: "Test",
            emoji: "👤"
        )

        desk.agent = agent
        desk.isOccupied = true

        XCTAssertTrue(desk.isOccupied)
        XCTAssertEqual(desk.agent?.id, "test")
    }

    // MARK: - Workflow Mode Tests
    func testWorkflowModeRawValues() {
        XCTAssertEqual(WorkflowMode.parallel.rawValue, "parallel")
        XCTAssertEqual(WorkflowMode.pipeline.rawValue, "pipeline")
        XCTAssertEqual(WorkflowMode.synthesis.rawValue, "synthesis")
        XCTAssertEqual(WorkflowMode.review.rawValue, "review")
        XCTAssertEqual(WorkflowMode.debate.rawValue, "debate")
    }

    // MARK: - Context Window Tests
    func testContextWindowUtilization() {
        var contextWindow = AppStore.ContextWindow()
        contextWindow.maxTokens = 100000
        contextWindow.usedTokens = 50000

        XCTAssertEqual(contextWindow.utilization, 0.5)
    }

    func testContextWindowIsNearLimit() {
        var contextWindow = AppStore.ContextWindow()
        contextWindow.maxTokens = 100000
        contextWindow.usedTokens = 90000

        XCTAssertTrue(contextWindow.isNearLimit)
    }

    // MARK: - LLM Provider Tests
    func testLLMProviderDisplayNames() {
        XCTAssertEqual(LLMProvider.anthropic.displayName, "Anthropic Claude")
        XCTAssertEqual(LLMProvider.openai.displayName, "OpenAI GPT-4o")
        XCTAssertEqual(LLMProvider.ollama.displayName, "Ollama (Local)")
    }

    // MARK: - Cost Entry Tests
    func testCostEntryInitialization() {
        let entry = CostEntry(
            agentId: "test-agent",
            agentName: "Test Agent",
            tokensUsed: 1000,
            costUsd: 0.01,
            model: "claude-3-opus"
        )

        XCTAssertEqual(entry.agentId, "test-agent")
        XCTAssertEqual(entry.tokensUsed, 1000)
        XCTAssertEqual(entry.costUsd, 0.01)
    }

    // MARK: - Session Note Tests
    func testSessionNoteInitialization() {
        let note = SessionNote(
            content: "Test note",
            tags: ["test", "bug"]
        )

        XCTAssertEqual(note.content, "Test note")
        XCTAssertEqual(note.tags.count, 2)
        XCTAssertTrue(note.tags.contains("test"))
    }

    // MARK: - Agent Group Tests
    func testAgentGroupInitialization() {
        let group = AgentGroup(
            name: "Test Group",
            agentIds: ["agent1", "agent2"]
        )

        XCTAssertEqual(group.name, "Test Group")
        XCTAssertEqual(group.agentIds.count, 2)
    }

    // MARK: - Office Preset Tests
    func testOfficePresetInitialization() {
        let preset = OfficePreset(
            name: "Test Preset",
            deskRoles: [.dev: "agent1", .qa: "agent2"]
        )

        XCTAssertEqual(preset.name, "Test Preset")
        XCTAssertEqual(preset.deskRoles.count, 2)
    }

    // MARK: - Workflow Template Tests
    func testWorkflowTemplateInitialization() {
        let template = WorkflowTemplate(
            id: "test-template",
            label: "Test Template",
            icon: "test",
            prompt: "Test prompt",
            agentRoles: ["dev", "qa"],
            workflowMode: .parallel,
            description: "A test template"
        )

        XCTAssertEqual(template.id, "test-template")
        XCTAssertEqual(template.agentRoles.count, 2)
    }
}

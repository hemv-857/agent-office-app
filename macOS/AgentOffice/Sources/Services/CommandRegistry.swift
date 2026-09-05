// CommandRegistry.swift
import Foundation

class CommandRegistry: ObservableObject {
    static let shared = CommandRegistry()

    @Published var commands: [CustomCommand] = []

    struct CustomCommand: Identifiable, Codable {
        let id: String
        let name: String
        let description: String
        let trigger: String
        let action: CommandAction
        let category: CommandCategory
        var isActive: Bool
    }

    enum CommandAction: Codable {
        case runWorkflow(mode: WorkflowMode, prompt: String)
        case seatAgent(agentId: String)
        case removeFromDesk(role: String)
        case exportData(format: String)
        case openView(view: String)
        case custom(script: String)
    }

    enum CommandCategory: String, Codable, CaseIterable {
        case workflow = "Workflow"
        case agent = "Agent"
        case data = "Data"
        case view = "View"
        case custom = "Custom"
    }

    private init() {
        loadCommands()
        registerDefaultCommands()
    }

    func registerCommand(_ command: CustomCommand) {
        if !commands.contains(where: { $0.id == command.id }) {
            commands.append(command)
            saveCommands()
        }
    }

    func unregisterCommand(id: String) {
        commands.removeAll { $0.id == id }
        saveCommands()
    }

    func executeCommand(id: String) {
        guard let command = commands.first(where: { $0.id == id && $0.isActive }) else { return }

        switch command.action {
        case .runWorkflow(let mode, let prompt):
            NotificationCenter.default.post(
                name: .executeCommand,
                object: nil,
                userInfo: ["type": "workflow", "mode": mode.rawValue, "prompt": prompt]
            )
        case .seatAgent(let agentId):
            NotificationCenter.default.post(
                name: .executeCommand,
                object: nil,
                userInfo: ["type": "seatAgent", "agentId": agentId]
            )
        case .removeFromDesk(let role):
            NotificationCenter.default.post(
                name: .executeCommand,
                object: nil,
                userInfo: ["type": "removeFromDesk", "role": role]
            )
        case .exportData(let format):
            NotificationCenter.default.post(
                name: .executeCommand,
                object: nil,
                userInfo: ["type": "export", "format": format]
            )
        case .openView(let view):
            NotificationCenter.default.post(
                name: .executeCommand,
                object: nil,
                userInfo: ["type": "openView", "view": view]
            )
        case .custom(let script):
            NotificationCenter.default.post(
                name: .executeCommand,
                object: nil,
                userInfo: ["type": "custom", "script": script]
            )
        }
    }

    func searchCommands(query: String) -> [CustomCommand] {
        guard !query.isEmpty else { return commands.filter { $0.isActive } }

        return commands.filter { command in
            command.isActive && (
                command.name.localizedCaseInsensitiveContains(query) ||
                command.description.localizedCaseInsensitiveContains(query) ||
                command.trigger.localizedCaseInsensitiveContains(query)
            )
        }
    }

    func getCommandsByCategory(_ category: CommandCategory) -> [CustomCommand] {
        return commands.filter { $0.category == category && $0.isActive }
    }

    func toggleCommand(id: String) {
        if let index = commands.firstIndex(where: { $0.id == id }) {
            commands[index].isActive.toggle()
            saveCommands()
        }
    }

    private func registerDefaultCommands() {
        let defaults = [
            CustomCommand(id: "run-parallel", name: "Run Parallel", description: "Run all agents in parallel", trigger: "/parallel", action: .runWorkflow(mode: .parallel, prompt: ""), category: .workflow, isActive: true),
            CustomCommand(id: "run-pipeline", name: "Run Pipeline", description: "Run agents in pipeline", trigger: "/pipeline", action: .runWorkflow(mode: .pipeline, prompt: ""), category: .workflow, isActive: true),
            CustomCommand(id: "clear-office", name: "Clear Office", description: "Remove all agents from desks", trigger: "/clear", action: .removeFromDesk(role: "all"), category: .agent, isActive: true),
            CustomCommand(id: "export-json", name: "Export JSON", description: "Export data as JSON", trigger: "/export json", action: .exportData(format: "json"), category: .data, isActive: true),
            CustomCommand(id: "export-markdown", name: "Export Markdown", description: "Export data as Markdown", trigger: "/export md", action: .exportData(format: "markdown"), category: .data, isActive: true),
        ]

        for command in defaults {
            if !commands.contains(where: { $0.id == command.id }) {
                commands.append(command)
            }
        }
        saveCommands()
    }

    private func saveCommands() {
        if let data = try? JSONEncoder().encode(commands) {
            UserDefaults.standard.set(data, forKey: "customCommands")
        }
    }

    private func loadCommands() {
        if let data = UserDefaults.standard.data(forKey: "customCommands"),
           let loaded = try? JSONDecoder().decode([CustomCommand].self, from: data) {
            commands = loaded
        }
    }
}

extension Notification.Name {
    static let executeCommand = Notification.Name("executeCommand")
}

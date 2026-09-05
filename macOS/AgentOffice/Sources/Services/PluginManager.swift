// PluginManager.swift
import Foundation

class PluginManager: ObservableObject {
    static let shared = PluginManager()

    @Published var plugins: [Plugin] = []
    @Published var enabledPlugins: Set<String> = []

    struct Plugin: Identifiable, Codable {
        let id: String
        let name: String
        let description: String
        let version: String
        let author: String
        var isEnabled: Bool
        var hooks: [PluginHook]
        var settings: [String: String]
    }

    struct PluginHook: Codable {
        let name: String
        let trigger: HookTrigger
        let action: String
    }

    enum HookTrigger: String, Codable, CaseIterable {
        case onWorkflowStart = "workflow.start"
        case onWorkflowEnd = "workflow.end"
        case onAgentResponse = "agent.response"
        case onPromptSubmit = "prompt.submit"
        case onExport = "data.export"
        case onImport = "data.import"
    }

    private init() {
        loadPlugins()
    }

    func registerPlugin(_ plugin: Plugin) {
        if !plugins.contains(where: { $0.id == plugin.id }) {
            plugins.append(plugin)
            savePlugins()
        }
    }

    func unregisterPlugin(id: String) {
        plugins.removeAll { $0.id == id }
        enabledPlugins.remove(id)
        savePlugins()
    }

    func enablePlugin(id: String) {
        if let index = plugins.firstIndex(where: { $0.id == id }) {
            plugins[index].isEnabled = true
            enabledPlugins.insert(id)
            savePlugins()
        }
    }

    func disablePlugin(id: String) {
        if let index = plugins.firstIndex(where: { $0.id == id }) {
            plugins[index].isEnabled = false
            enabledPlugins.remove(id)
            savePlugins()
        }
    }

    func getActivePlugins() -> [Plugin] {
        return plugins.filter { $0.isEnabled }
    }

    func getPluginsForTrigger(_ trigger: HookTrigger) -> [Plugin] {
        return plugins.filter { plugin in
            plugin.isEnabled && plugin.hooks.contains { $0.trigger == trigger }
        }
    }

    func executeHook(trigger: HookTrigger, context: [String: Any]) {
        let activePlugins = getPluginsForTrigger(trigger)

        for plugin in activePlugins {
            for hook in plugin.hooks where hook.trigger == trigger {
                NotificationCenter.default.post(
                    name: Notification.Name("plugin.\(hook.action)"),
                    object: nil,
                    userInfo: ["plugin": plugin, "context": context]
                )
            }
        }
    }

    func updatePluginSettings(id: String, settings: [String: String]) {
        if let index = plugins.firstIndex(where: { $0.id == id }) {
            plugins[index].settings = settings
            savePlugins()
        }
    }

    func getInstalledPlugins() -> [Plugin] {
        return plugins
    }

    private func savePlugins() {
        if let data = try? JSONEncoder().encode(plugins) {
            UserDefaults.standard.set(data, forKey: "installedPlugins")
        }
        UserDefaults.standard.set(Array(enabledPlugins), forKey: "enabledPlugins")
    }

    private func loadPlugins() {
        if let data = UserDefaults.standard.data(forKey: "installedPlugins"),
           let loaded = try? JSONDecoder().decode([Plugin].self, from: data) {
            plugins = loaded
        }
        enabledPlugins = Set(UserDefaults.standard.stringArray(forKey: "enabledPlugins") ?? [])
    }
}

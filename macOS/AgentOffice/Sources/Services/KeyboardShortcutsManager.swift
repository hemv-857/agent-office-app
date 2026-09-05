// KeyboardShortcutsManager.swift
import SwiftUI
import AppKit

class KeyboardShortcutsManager: ObservableObject {
    static let shared = KeyboardShortcutsManager()

    @Published var shortcuts: [KeyboardShortcut] = []
    @Published var customShortcuts: [String: KeyboardShortcut] = [:]

    struct KeyboardShortcut: Identifiable, Codable {
        let id: String
        let name: String
        let description: String
        var key: String
        var modifiers: [String]
        let action: ShortcutAction
        var isEnabled: Bool = true

        var displayString: String {
            var result = ""
            for mod in modifiers {
                switch mod {
                case "command": result += "⌘"
                case "shift": result += "⇧"
                case "control": result += "⌃"
                case "option": result += "⌥"
                default: break
                }
            }
            result += key.uppercased()
            return result
        }
    }

    enum ShortcutAction: String, Codable, CaseIterable {
        case commandPalette = "command_palette"
        case settings = "settings"
        case help = "help"
        case export = "export"
        case clearPrompt = "clear_prompt"
        case promptHistoryUp = "prompt_history_up"
        case promptHistoryDown = "prompt_history_down"
        case selectDesk1 = "select_desk_1"
        case selectDesk2 = "select_desk_2"
        case selectDesk3 = "select_desk_3"
        case selectDesk4 = "select_desk_4"
        case selectDesk5 = "select_desk_5"
        case selectDesk6 = "select_desk_6"
        case selectDesk7 = "select_desk_7"
        case selectDesk8 = "select_desk_8"
        case runWorkflow = "run_workflow"
        case cancelRun = "cancel_run"
        case toggleSidebar = "toggle_sidebar"
        case toggleResults = "toggle_results"
        case newAgent = "new_agent"
        case saveGroup = "save_group"
        case savePreset = "save_preset"
        case quickActions = "quick_actions"
    }

    private init() {
        loadShortcuts()
        loadCustomShortcuts()
    }

    func registerShortcut(_ shortcut: KeyboardShortcut) {
        if !shortcuts.contains(where: { $0.id == shortcut.id }) {
            shortcuts.append(shortcut)
            saveShortcuts()
        }
    }

    func unregisterShortcut(id: String) {
        shortcuts.removeAll { $0.id == id }
        saveShortcuts()
    }

    func updateShortcut(id: String, key: String, modifiers: [String]) {
        if let index = shortcuts.firstIndex(where: { $0.id == id }) {
            shortcuts[index] = KeyboardShortcut(
                id: id,
                name: shortcuts[index].name,
                description: shortcuts[index].description,
                key: key,
                modifiers: modifiers,
                action: shortcuts[index].action,
                isEnabled: shortcuts[index].isEnabled
            )
            saveShortcuts()
        }
    }

    func updateShortcut(_ shortcut: KeyboardShortcut) {
        if let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
            shortcuts[index] = shortcut
            saveShortcuts()
        }
    }

    func defaultShortcuts() -> [KeyboardShortcut] {
        return [
            KeyboardShortcut(id: "cmd-k", name: "Command Palette", description: "Open command palette", key: "k", modifiers: ["command"], action: .commandPalette),
            KeyboardShortcut(id: "cmd-comma", name: "Settings", description: "Open settings", key: ",", modifiers: ["command"], action: .settings),
            KeyboardShortcut(id: "cmd-question", name: "Help", description: "Show help", key: "?", modifiers: ["command"], action: .help),
            KeyboardShortcut(id: "cmd-e", name: "Export", description: "Export results", key: "e", modifiers: ["command"], action: .export),
            KeyboardShortcut(id: "cmd-l", name: "Clear Prompt", description: "Clear prompt text", key: "l", modifiers: ["command"], action: .clearPrompt),
            KeyboardShortcut(id: "up-arrow", name: "Prompt History Up", description: "Go to previous prompt", key: "up", modifiers: [], action: .promptHistoryUp),
            KeyboardShortcut(id: "down-arrow", name: "Prompt History Down", description: "Go to next prompt", key: "down", modifiers: [], action: .promptHistoryDown),
            KeyboardShortcut(id: "cmd-1", name: "Select Desk 1", description: "Select desk 1", key: "1", modifiers: ["command"], action: .selectDesk1),
            KeyboardShortcut(id: "cmd-2", name: "Select Desk 2", description: "Select desk 2", key: "2", modifiers: ["command"], action: .selectDesk2),
            KeyboardShortcut(id: "cmd-3", name: "Select Desk 3", description: "Select desk 3", key: "3", modifiers: ["command"], action: .selectDesk3),
            KeyboardShortcut(id: "cmd-4", name: "Select Desk 4", description: "Select desk 4", key: "4", modifiers: ["command"], action: .selectDesk4),
            KeyboardShortcut(id: "cmd-5", name: "Select Desk 5", description: "Select desk 5", key: "5", modifiers: ["command"], action: .selectDesk5),
            KeyboardShortcut(id: "cmd-6", name: "Select Desk 6", description: "Select desk 6", key: "6", modifiers: ["command"], action: .selectDesk6),
            KeyboardShortcut(id: "cmd-7", name: "Select Desk 7", description: "Select desk 7", key: "7", modifiers: ["command"], action: .selectDesk7),
            KeyboardShortcut(id: "cmd-8", name: "Select Desk 8", description: "Select desk 8", key: "8", modifiers: ["command"], action: .selectDesk8),
            KeyboardShortcut(id: "cmd-return", name: "Run Workflow", description: "Run workflow", key: "return", modifiers: ["command"], action: .runWorkflow),
            KeyboardShortcut(id: "cmd-backspace", name: "Cancel Run", description: "Cancel current run", key: "delete", modifiers: ["command"], action: .cancelRun),
            KeyboardShortcut(id: "cmd-s", name: "Save Group", description: "Save current group", key: "s", modifiers: ["command", "shift"], action: .saveGroup),
            KeyboardShortcut(id: "cmd-p", name: "Save Preset", description: "Save current preset", key: "p", modifiers: ["command", "shift"], action: .savePreset),
        ]
    }

    func toggleShortcut(id: String) {
        if let index = shortcuts.firstIndex(where: { $0.id == id }) {
            shortcuts[index].isEnabled.toggle()
            saveShortcuts()
        }
    }

    func getShortcutForAction(_ action: ShortcutAction) -> KeyboardShortcut? {
        return shortcuts.first { $0.action == action && $0.isEnabled }
    }

    func handleKeyPress(key: String, modifiers: NSEvent.ModifierFlags) -> Bool {
        for shortcut in shortcuts where shortcut.isEnabled {
            if shortcut.key == key && modifiersMatch(shortcut.modifiers, modifiers) {
                executeAction(shortcut.action)
                return true
            }
        }
        return false
    }

    private func modifiersMatch(_ shortcutModifiers: [String], _ eventModifiers: NSEvent.ModifierFlags) -> Bool {
        let modifierMap: [String: NSEvent.ModifierFlags] = [
            "command": .command,
            "shift": .shift,
            "control": .control,
            "option": .option
        ]

        for modifier in shortcutModifiers {
            guard let flag = modifierMap[modifier] else { continue }
            if !eventModifiers.contains(flag) { return false }
        }
        return true
    }

    private func executeAction(_ action: ShortcutAction) {
        NotificationCenter.default.post(
            name: .executeShortcut,
            object: nil,
            userInfo: ["action": action.rawValue]
        )
    }

    func getShortcutDisplayString(_ shortcut: KeyboardShortcut) -> String {
        var display = ""
        for modifier in shortcut.modifiers {
            switch modifier {
            case "command": display += "⌘"
            case "shift": display += "⇧"
            case "control": display += "⌃"
            case "option": display += "⌥"
            default: break
            }
        }
        display += shortcut.key.uppercased()
        return display
    }

    private func loadShortcuts() {
        if shortcuts.isEmpty {
            shortcuts = [
                KeyboardShortcut(id: "cmd-k", name: "Command Palette", description: "Open command palette", key: "k", modifiers: ["command"], action: .commandPalette),
                KeyboardShortcut(id: "cmd-comma", name: "Settings", description: "Open settings", key: ",", modifiers: ["command"], action: .settings),
                KeyboardShortcut(id: "cmd-question", name: "Help", description: "Show help", key: "?", modifiers: ["command"], action: .help),
                KeyboardShortcut(id: "cmd-e", name: "Export", description: "Export results", key: "e", modifiers: ["command"], action: .export),
                KeyboardShortcut(id: "cmd-l", name: "Clear Prompt", description: "Clear prompt text", key: "l", modifiers: ["command"], action: .clearPrompt),
                KeyboardShortcut(id: "up-arrow", name: "Prompt History Up", description: "Go to previous prompt", key: "up", modifiers: [], action: .promptHistoryUp),
                KeyboardShortcut(id: "down-arrow", name: "Prompt History Down", description: "Go to next prompt", key: "down", modifiers: [], action: .promptHistoryDown),
                KeyboardShortcut(id: "cmd-1", name: "Select Desk 1", description: "Select desk 1", key: "1", modifiers: ["command"], action: .selectDesk1),
                KeyboardShortcut(id: "cmd-2", name: "Select Desk 2", description: "Select desk 2", key: "2", modifiers: ["command"], action: .selectDesk2),
                KeyboardShortcut(id: "cmd-3", name: "Select Desk 3", description: "Select desk 3", key: "3", modifiers: ["command"], action: .selectDesk3),
                KeyboardShortcut(id: "cmd-4", name: "Select Desk 4", description: "Select desk 4", key: "4", modifiers: ["command"], action: .selectDesk4),
                KeyboardShortcut(id: "cmd-5", name: "Select Desk 5", description: "Select desk 5", key: "5", modifiers: ["command"], action: .selectDesk5),
                KeyboardShortcut(id: "cmd-6", name: "Select Desk 6", description: "Select desk 6", key: "6", modifiers: ["command"], action: .selectDesk6),
                KeyboardShortcut(id: "cmd-7", name: "Select Desk 7", description: "Select desk 7", key: "7", modifiers: ["command"], action: .selectDesk7),
                KeyboardShortcut(id: "cmd-8", name: "Select Desk 8", description: "Select desk 8", key: "8", modifiers: ["command"], action: .selectDesk8),
                KeyboardShortcut(id: "cmd-return", name: "Run Workflow", description: "Run workflow", key: "return", modifiers: ["command"], action: .runWorkflow),
                KeyboardShortcut(id: "cmd-backspace", name: "Cancel Run", description: "Cancel current run", key: "delete", modifiers: ["command"], action: .cancelRun),
                KeyboardShortcut(id: "cmd-s", name: "Save Group", description: "Save current group", key: "s", modifiers: ["command", "shift"], action: .saveGroup),
                KeyboardShortcut(id: "cmd-p", name: "Save Preset", description: "Save current preset", key: "p", modifiers: ["command", "shift"], action: .savePreset),
            ]
        }
    }

    private func loadCustomShortcuts() {
        if let data = UserDefaults.standard.data(forKey: "customShortcuts"),
           let loaded = try? JSONDecoder().decode([String: KeyboardShortcut].self, from: data) {
            customShortcuts = loaded
        }
    }

    func saveShortcuts() {
        if let data = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(data, forKey: "keyboardShortcuts")
        }
    }

    private func saveCustomShortcuts() {
        if let data = try? JSONEncoder().encode(customShortcuts) {
            UserDefaults.standard.set(data, forKey: "customShortcuts")
        }
    }
}

extension Notification.Name {
    static let executeShortcut = Notification.Name("executeShortcut")
}

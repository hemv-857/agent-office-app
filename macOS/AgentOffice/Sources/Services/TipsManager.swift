// TipsManager.swift
import Foundation

class TipsManager: ObservableObject {
    static let shared = TipsManager()

    @Published var currentTip: Tip?
    @Published var showTips = true
    @Published var dismissedTips: Set<String> = []

    struct Tip: Identifiable, Codable {
        let id: String
        let title: String
        let message: String
        let category: TipCategory
        let priority: Int
        var isShown: Bool = false
    }

    enum TipCategory: String, Codable, CaseIterable {
        case gettingStarted = "Getting Started"
        case workflow = "Workflow"
        case agent = "Agent"
        case shortcut = "Shortcut"
        case advanced = "Advanced"
    }

    private var tips: [Tip] = []
    private var currentTipIndex = 0

    private init() {
        loadTips()
        loadDismissedTips()
    }

    func getNextTip() -> Tip? {
        let availableTips = tips.filter { !dismissedTips.contains($0.id) && !$0.isShown }
        guard let tip = availableTips.first else { return nil }

        currentTip = tip
        if let index = tips.firstIndex(where: { $0.id == tip.id }) {
            tips[index].isShown = true
        }
        saveTips()
        return tip
    }

    func dismissTip(_ tipId: String) {
        dismissedTips.insert(tipId)
        saveDismissedTips()
        currentTip = nil
    }

    func dismissAllTips() {
        for tip in tips {
            dismissedTips.insert(tip.id)
        }
        saveDismissedTips()
        currentTip = nil
    }

    func shouldShowTip(_ tipId: String) -> Bool {
        return showTips && !dismissedTips.contains(tipId)
    }

    func getTipsByCategory(_ category: TipCategory) -> [Tip] {
        return tips.filter { $0.category == category }
    }

    func resetTips() {
        dismissedTips.removeAll()
        for i in tips.indices {
            tips[i].isShown = false
        }
        saveTips()
        saveDismissedTips()
    }

    private func loadTips() {
        tips = [
            Tip(id: "tip-1", title: "Getting Started", message: "Drag agents from the sidebar to seat them at desks. Use ⌘1-8 to quickly select desks.", category: .gettingStarted, priority: 1),
            Tip(id: "tip-2", title: "Workflow Modes", message: "Try different workflow modes: Parallel runs all agents at once, Pipeline chains their outputs.", category: .workflow, priority: 2),
            Tip(id: "tip-3", title: "Quick Commands", message: "Press ⌘K to open the command palette for quick access to all features.", category: .shortcut, priority: 3),
            Tip(id: "tip-4", title: "Agent Favorites", message: "Star your favorite agents to quickly find them in the sidebar.", category: .agent, priority: 4),
            Tip(id: "tip-5", title: "Export Data", message: "Press ⌘E to export your results, notes, and chat history.", category: .shortcut, priority: 5),
            Tip(id: "tip-6", title: "Template Preview", message: "Click 'Preview' on workflow templates to see details before applying.", category: .workflow, priority: 6),
            Tip(id: "tip-7", title: "Voice Input", message: "Click the microphone icon to use speech-to-text for your prompts.", category: .advanced, priority: 7),
            Tip(id: "tip-8", title: "Compare Mode", message: "Enable compare mode to see side-by-side agent responses.", category: .workflow, priority: 8),
            Tip(id: "tip-9", title: "Keyboard Shortcuts", message: "Press ? to see all available keyboard shortcuts.", category: .shortcut, priority: 9),
            Tip(id: "tip-10", title: "Context Window", message: "Monitor your context window usage in the status bar to avoid hitting limits.", category: .advanced, priority: 10),
        ]
    }

    private func saveTips() {
        if let data = try? JSONEncoder().encode(tips) {
            UserDefaults.standard.set(data, forKey: "tips")
        }
    }

    private func loadDismissedTips() {
        dismissedTips = Set(UserDefaults.standard.stringArray(forKey: "dismissedTips") ?? [])
    }

    private func saveDismissedTips() {
        UserDefaults.standard.set(Array(dismissedTips), forKey: "dismissedTips")
    }
}

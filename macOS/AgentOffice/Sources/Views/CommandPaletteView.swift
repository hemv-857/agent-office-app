// CommandPaletteView.swift
import SwiftUI

struct CommandPaletteView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var query = ""
    @FocusState private var isFocused: Bool

    struct Command: Identifiable {
        let id = UUID()
        let label: String
        let shortcut: String?
        let icon: String
        let action: () -> Void
    }

    var commands: [Command] {
        [
            // Core
            Command(label: "Run All Agents", shortcut: "⌘↵", icon: "play.fill") { store.runAll(); dismiss() },
            Command(label: "Stop", shortcut: "⌘.", icon: "stop.fill") { store.cancelRun(); dismiss() },
            Command(label: "Clear Office", shortcut: nil, icon: "trash") { store.clearOffice(); dismiss() },
            Command(label: "Toggle Sidebar", shortcut: "⌘S", icon: "sidebar.left") { store.showSidebar.toggle(); dismiss() },
            Command(label: "Toggle Results", shortcut: nil, icon: "sidebar.right") { store.showResultsPanel.toggle(); dismiss() },

            // Views
            Command(label: "Settings", shortcut: "⌘,", icon: "gearshape") { store.showSettings = true; dismiss() },
            Command(label: "Help", shortcut: "?", icon: "questionmark.circle") { store.showHelp = true; dismiss() },
            Command(label: "Cost Tracker", shortcut: nil, icon: "dollarsign.circle") { store.showCostTracker = true; dismiss() },
            Command(label: "Leaderboard", shortcut: nil, icon: "chart.bar") { store.showLeaderboard = true; dismiss() },
            Command(label: "Session Notes", shortcut: nil, icon: "note.text") { store.showSessionNotes = true; dismiss() },
            Command(label: "Activity Log", shortcut: nil, icon: "list.bullet") { store.showActivityLog = true; dismiss() },
            Command(label: "Pipeline Visualizer", shortcut: nil, icon: "arrow.triangle.branch") { store.showPipelineVisualizer = true; dismiss() },
            Command(label: "Agent Memory", shortcut: nil, icon: "brain") { store.showAgentMemory = true; dismiss() },

            // New features
            Command(label: "Analytics Dashboard", shortcut: nil, icon: "chart.line.uptrend.xyaxis") { store.showAnalytics = true; dismiss() },
            Command(label: "Batch Run", shortcut: nil, icon: "square.stack") { store.showBatchRun = true; dismiss() },
            Command(label: "Compare Agents", shortcut: nil, icon: "arrow.left.arrow.right") { store.showComparison = true; dismiss() },
            Command(label: "Conversation History", shortcut: nil, icon: "bubble.left.and.bubble.right") { store.showConversationHistory = true; dismiss() },
            Command(label: "Prompt Templates", shortcut: nil, icon: "doc.text") { store.showPromptTemplates = true; dismiss() },
            Command(label: "Task Queue", shortcut: nil, icon: "list.number") { store.showTaskQueue = true; dismiss() },
            Command(label: "Workflow Chains", shortcut: nil, icon: "link") { store.showChains = true; dismiss() },
            Command(label: "Plugins", shortcut: nil, icon: "puzzlepiece") { store.showPlugins = true; dismiss() },
            Command(label: "Custom Commands", shortcut: nil, icon: "command") { store.showCommands = true; dismiss() },

            // Data
            Command(label: "Export Results", shortcut: "⌘E", icon: "square.and.arrow.up") { store.showExport = true; dismiss() },
            Command(label: "Storage", shortcut: nil, icon: "internaldrive") { store.showStorage = true; dismiss() },

            // Agent management
            Command(label: "Add Custom Agent", shortcut: nil, icon: "person.badge.plus") { store.showCustomAgent = true; dismiss() },
            Command(label: "Save Group", shortcut: nil, icon: "folder.badge.plus") { store.showGroupSave = true; dismiss() },
            Command(label: "Save Preset", shortcut: nil, icon: "bookmark.badge.plus") { store.showPresetSave = true; dismiss() },

            // New views
            Command(label: "Bulk Actions", shortcut: nil, icon: "checkmark.square") { store.showBulkActions = true; dismiss() },
            Command(label: "Agent Scheduler", shortcut: nil, icon: "calendar") { store.showAgentScheduler = true; dismiss() },
            Command(label: "Prompt Library", shortcut: nil, icon: "text.book.closed") { store.showPromptLibrary = true; dismiss() },
            Command(label: "Template Designer", shortcut: nil, icon: "plus.square.on.square") { store.showTemplateDesigner = true; dismiss() },
            Command(label: "Workspace Layout", shortcut: nil, icon: "rectangle.grid.2x2") { store.showWorkspaceLayout = true; dismiss() },
            Command(label: "Analytics Dashboard", shortcut: nil, icon: "chart.pie") { store.showAnalyticsDashboard = true; dismiss() },
            Command(label: "Quick Switch", shortcut: nil, icon: "arrow.triangle.2.circlepath") { store.showWorkspaceQuickSwitch = true; dismiss() },
            Command(label: "Agent Status", shortcut: nil, icon: "person.circle") { store.showAgentStatus = true; dismiss() },
            Command(label: "Agent Progress", shortcut: nil, icon: "chart.bar.fill") { store.showAgentProgress = true; dismiss() },
            Command(label: "System Diagnostics", shortcut: nil, icon: "stethoscope") { store.showSystemDiagnostics = true; dismiss() },
            Command(label: "Execution Queue", shortcut: nil, icon: "list.number") { store.showExecutionQueue = true; dismiss() },
            Command(label: "Workspace Dashboard", shortcut: nil, icon: "square.grid.3x3") { store.showWorkspaceDashboard = true; dismiss() },
            Command(label: "Performance Report", shortcut: nil, icon: "doc.text.magnifyingglass") { store.showPerformanceReport = true; dismiss() },
        ]
    }

    var filtered: [Command] {
        query.isEmpty ? commands : commands.filter { $0.label.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Type a command...", text: $query)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                Button(action: { dismiss() }) {
                    Text("esc").font(.system(size: 10)).padding(.horizontal, 4).padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
            .padding(12)

            Divider()

            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filtered) { cmd in
                        HStack {
                            Image(systemName: cmd.icon).frame(width: 20).foregroundStyle(.secondary)
                            Text(cmd.label)
                            Spacer()
                            if let s = cmd.shortcut {
                                Text(s).font(.system(size: 10)).foregroundStyle(.secondary)
                                    .padding(.horizontal, 4).padding(.vertical, 2)
                                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture { cmd.action() }
                    }
                }
            }
        }
        .frame(width: 480, height: 400)
        .onAppear { isFocused = true }
    }
}

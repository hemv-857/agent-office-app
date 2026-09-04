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
            Command(label: "Run All Agents", shortcut: "⌘↵", icon: "play.fill") { store.runAll(); dismiss() },
            Command(label: "Stop", shortcut: "⌘.", icon: "stop.fill") { store.cancelRun(); dismiss() },
            Command(label: "Clear Office", shortcut: nil, icon: "trash") { store.clearOffice(); dismiss() },
            Command(label: "Toggle Sidebar", shortcut: "⌘S", icon: "sidebar.left") { store.showSidebar.toggle(); dismiss() },
            Command(label: "Toggle Results", shortcut: nil, icon: "sidebar.right") { store.showResultsPanel.toggle(); dismiss() },
            Command(label: "Settings", shortcut: "⌘,", icon: "gearshape") { store.showSettings = true; dismiss() },
            Command(label: "Help", shortcut: "?", icon: "questionmark.circle") { store.showHelp = true; dismiss() },
            Command(label: "Cost Tracker", shortcut: nil, icon: "dollarsign.circle") { store.showCostTracker = true; dismiss() },
            Command(label: "Leaderboard", shortcut: nil, icon: "chart.bar") { store.showLeaderboard = true; dismiss() },
            Command(label: "Session Notes", shortcut: nil, icon: "note.text") { store.showSessionNotes = true; dismiss() },
            Command(label: "Activity Log", shortcut: nil, icon: "list.bullet") { store.showActivityLog = true; dismiss() },
            Command(label: "Pipeline Visualizer", shortcut: nil, icon: "arrow.triangle.branch") { store.showPipelineVisualizer = true; dismiss() },
            Command(label: "Agent Memory", shortcut: nil, icon: "brain") { store.showAgentMemory = true; dismiss() },
            Command(label: "Export Results", shortcut: "⌘E", icon: "square.and.arrow.up") { store.showExport = true; dismiss() },
            Command(label: "Add Custom Agent", shortcut: nil, icon: "person.badge.plus") { store.showCustomAgent = true; dismiss() },
            Command(label: "Save Group", shortcut: nil, icon: "folder.badge.plus") { store.showGroupSave = true; dismiss() },
            Command(label: "Save Preset", shortcut: nil, icon: "bookmark.badge.plus") { store.showPresetSave = true; dismiss() },
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

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HSplitView {
            if store.showSidebar {
                SidebarView()
                    .frame(minWidth: 260, idealWidth: 280, maxWidth: 320)
            }

            VStack(spacing: 0) {
                HeaderView()
                OfficeGridView()
                PromptBarView()
                StatusBarView()
            }

            if store.showResultsPanel {
                ResultsPanelView()
                    .frame(minWidth: 360, idealWidth: 400, maxWidth: 500)
            }
        }
        .overlay(alignment: .top) {
            if let toast = store.toast {
                ToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.toast?.id)
        // Modal sheets
        .sheet(isPresented: $store.showOnboarding) { OnboardingView() }
        .sheet(isPresented: $store.showSettings) { SettingsView() }
        .sheet(isPresented: $store.showHelp) { HelpView() }
        .sheet(isPresented: $store.showCommandPalette) { CommandPaletteView() }
        .sheet(isPresented: $store.showCostTracker) { CostTrackerView() }
        .sheet(isPresented: $store.showLeaderboard) { LeaderboardView() }
        .sheet(isPresented: $store.showPipelineVisualizer) { PipelineVisualizerView() }
        .sheet(isPresented: $store.showSessionNotes) { SessionNotesView() }
        .sheet(isPresented: $store.showActivityLog) { ActivityLogView() }
        .sheet(isPresented: $store.showCustomAgent) { CustomAgentView() }
        .sheet(isPresented: $store.showExport) { ExportView() }
        .sheet(isPresented: $store.showAgentMemory) { AgentMemoryView() }
        .sheet(isPresented: $store.showProjectBuilder) { ProjectBuilderView() }
        .sheet(isPresented: $store.showSessionReplay) { SessionReplayView() }
        .sheet(item: $store.showAgentDetail) { agent in AgentDetailView(agent: agent) }
        .sheet(item: $store.showChat) { dest in ChatView(agentId: dest.agentId, agentName: dest.agentName) }
        .sheet(isPresented: $store.showGroupSave) {
            GroupSaveView()
        }
        .sheet(isPresented: $store.showPresetSave) {
            PresetSaveView()
        }
        // Keyboard shortcuts
        .background(
            KeyboardShortcutsView()
        )
    }
}

// MARK: - Keyboard Shortcuts
struct KeyboardShortcutsView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "k" {
                    NotificationCenter.default.post(name: .commandPalette, object: nil)
                    return nil
                }
                if event.charactersIgnoringModifiers == "?" && !event.modifierFlags.contains(.command) {
                    NotificationCenter.default.post(name: .showHelp, object: nil)
                    return nil
                }
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "e" {
                    NotificationCenter.default.post(name: .showExport, object: nil)
                    return nil
                }
                return event
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Group Save View
struct GroupSaveView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Save Agent Group").font(.headline)
            TextField("Group name...", text: $name).textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") { store.saveGroup(name); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}

// MARK: - Preset Save View
struct PresetSaveView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Save Office Preset").font(.headline)
            TextField("Preset name...", text: $name).textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") { store.savePreset(name); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let commandPalette = Notification.Name("commandPalette")
    static let showHelp = Notification.Name("showHelp")
    static let showExport = Notification.Name("showExport")
}

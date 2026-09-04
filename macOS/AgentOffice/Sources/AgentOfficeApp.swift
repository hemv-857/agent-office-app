// AgentOfficeApp.swift
import SwiftUI

@main
struct AgentOfficeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 600)
                .preferredColorScheme(store.theme == .dark ? .dark : store.theme == .light ? .light : nil)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1440, height: 900)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Command Palette") { store.showCommandPalette = true }
                    .keyboardShortcut("k", modifiers: .command)
                Button("Settings") { store.showSettings = true }
                    .keyboardShortcut(",", modifiers: .command)
                Divider()
                Button("Save Group") { store.showGroupSave = true }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
                Button("Save Preset") { store.showPresetSave = true }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .help) {
                Button("Help") { store.showHelp = true }
                    .keyboardShortcut("?", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Button("Toggle Sidebar") { store.showSidebar.toggle() }
                    .keyboardShortcut("s", modifiers: [.command, .control])
                Button("Toggle Results") { store.showResultsPanel.toggle() }
                    .keyboardShortcut("r", modifiers: [.command, .control])
            }
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    weak var store: AppStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set app name
        UserDefaults.standard.set(true, forKey: "NSQuitAlwaysKeepsWindows")
        setupMenuBar()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "person.3.fill", accessibilityDescription: "Agent Office")
            button.image?.isTemplate = true
        }

        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Agent Office", action: nil, keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())

        // Quick actions
        menu?.addItem(NSMenuItem(title: "Command Palette", action: #selector(showCommandPalette), keyEquivalent: "k"))
        menu?.addItem(NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: ","))
        menu?.addItem(NSMenuItem.separator())

        // Status info
        let statusItem = NSMenuItem(title: "Ready", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu?.addItem(statusItem)

        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Quit Agent Office", action: #selector(quitApp), keyEquivalent: "q"))

        self.statusItem?.menu = menu
    }

    @objc func showCommandPalette() {
        NotificationCenter.default.post(name: .showCommandPalette, object: nil)
    }

    @objc func showSettings() {
        NotificationCenter.default.post(name: .showSettings, object: nil)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showCommandPalette = Notification.Name("showCommandPalette")
    static let showSettings = Notification.Name("showSettings")
}

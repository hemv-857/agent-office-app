// WorkflowAgentKeyboardShortcutsEditorView.swift
import SwiftUI

struct WorkflowAgentKeyboardShortcutsEditorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let shortcuts: [(String, String)] = [
        ("⌘K", "Command Palette"),
        ("⌘1-8", "Quick Actions"),
        ("⌘↑/↓", "Navigate Agents"),
        ("⌘L", "Clear Chat"),
        ("⌘E", "Export"),
        ("?", "Help"),
        ("⌘⇧S", "Save Session"),
        ("⌘⇧P", "Toggle Presets"),
        ("⌘⌃S", "Settings"),
        ("⌘⌃R", "Run Workflow"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Keyboard Shortcuts").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(shortcuts.indices, id: \.self) { i in
                        KeyboardShortcutDisplayRow(
                            shortcut: shortcuts[i].0,
                            action: shortcuts[i].1
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 440)
    }
}

// MARK: - Shortcut Row
struct KeyboardShortcutDisplayRow: View {
    let shortcut: String
    let action: String

    var body: some View {
        HStack(spacing: 12) {
            Text(shortcut)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .frame(width: 60, alignment: .leading)
            Text(action)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

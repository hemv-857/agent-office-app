// WorkflowAgentAgentShortcutsCustomizeView.swift
import SwiftUI

struct WorkflowAgentAgentShortcutsCustomizeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var shortcuts: [(String, String, String, Bool)] = [
        ("New Session", "⌘N", "Create new agent session", true),
        ("Command Palette", "⌘⇧P", "Open command palette", true),
        ("Focus Chat", "⌘L", "Focus chat input", true),
        ("Next Agent", "⌘→", "Select next agent", true),
        ("Previous Agent", "⌘←", "Select previous agent", true),
        ("Toggle Sidebar", "⌘⌥S", "Show/hide sidebar", true),
        ("Quick Actions", "⌘⌥A", "Open quick actions", false),
        ("Export Session", "⌘E", "Export current session", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Customize Shortcuts").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(shortcuts.indices, id: \.self) { i in
                        ShortcutCustomizeRow(
                            action: shortcuts[i].0,
                            currentKey: shortcuts[i].1,
                            description: shortcuts[i].2,
                            isEnabled: shortcuts[i].3,
                            onToggle: { shortcuts[i].3.toggle() },
                            onChange: { newKey in
                                shortcuts[i].1 = newKey
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Reset to Defaults") {
                    shortcuts = [
                        ("New Session", "⌘N", "Create new agent session", true),
                        ("Command Palette", "⌘⇧P", "Open command palette", true),
                        ("Focus Chat", "⌘L", "Focus chat input", true),
                        ("Next Agent", "⌘→", "Select next agent", true),
                        ("Previous Agent", "⌘←", "Select previous agent", true),
                        ("Toggle Sidebar", "⌘⌥S", "Show/hide sidebar", true),
                        ("Quick Actions", "⌘⌥A", "Open quick actions", false),
                        ("Export Session", "⌘E", "Export current session", false),
                    ]
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 480)
    }
}

// MARK: - Shortcut Customize Row
struct ShortcutCustomizeRow: View {
    let action: String
    let currentKey: String
    let description: String
    let isEnabled: Bool
    let onToggle: () -> Void
    let onChange: (String) -> Void

    @State private var isRecording = false

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text(action)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { isRecording.toggle() }) {
                Text(isRecording ? "Press keys..." : currentKey)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(minWidth: 80)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isRecording ? .blue.opacity(0.2) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(isRecording ? .blue : .primary)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}
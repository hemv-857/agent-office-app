// WorkflowKeyboardShortcutsHelpView.swift
import SwiftUI

struct WorkflowKeyboardShortcutsHelpView: View {
    @Environment(\.dismiss) var dismiss

    private let shortcuts: [(String, String)] = [
        ("⌘K", "Command palette"),
        ("⌘1-8", "Quick actions"),
        ("⌘↑/↓", "Navigate results"),
        ("⌘L", "Clear prompt"),
        ("⌘E", "Export results"),
        ("?", "Show shortcuts"),
        ("⌘⇧S", "Save session"),
        ("⌘⇧P", "Save preset"),
        ("⌘⌃S", "Save group"),
        ("⌘⌃R", "Run workflow"),
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
                VStack(spacing: 6) {
                    ForEach(shortcuts, id: \.0) { shortcut in
                        HStack {
                            Text(shortcut.0)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .frame(width: 60, alignment: .leading)
                            Text(shortcut.1)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 350, height: 400)
    }
}

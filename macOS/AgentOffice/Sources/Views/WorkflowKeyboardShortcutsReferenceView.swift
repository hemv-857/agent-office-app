// WorkflowKeyboardShortcutsReferenceView.swift
import SwiftUI

struct WorkflowKeyboardShortcutsReferenceView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, [(String, String)])] = [
        ("General", [
            ("⌘K", "Open command palette"),
            ("⌘,", "Open settings"),
            ("⌘Q", "Quit app"),
            ("ESC", "Close modal"),
        ]),
        ("Workflow", [
            ("⌘⇧R", "Run workflow"),
            ("⌘⇧C", "Cancel workflow"),
            ("⌘⇧S", "Save session"),
            ("⌘⇧P", "Save preset"),
        ]),
        ("Navigation", [
            ("⌘↑", "Previous result"),
            ("⌘↓", "Next result"),
            ("⌘L", "Clear prompt"),
            ("⌘E", "Export results"),
        ]),
        ("Agents", [
            ("⌘1-8", "Select agent 1-8"),
            ("⌘⇧A", "Select all agents"),
            ("⌘⇧D", "Deselect all agents"),
            ("?", "Show shortcuts"),
        ]),
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
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(sections, id: \.0) { section in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(section.0)
                                .font(.system(size: 12, weight: .semibold))
                            ForEach(section.1, id: \.0) { shortcut in
                                HStack {
                                    Text(shortcut.0)
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .frame(width: 50, alignment: .leading)
                                    Text(shortcut.1)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            }
                        }
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
        .frame(width: 400, height: 450)
    }
}

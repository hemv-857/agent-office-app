// KeyboardShortcutsHelpView.swift
import SwiftUI

struct KeyboardShortcutsHelpView: View {
    @Environment(\.dismiss) var dismiss

    let shortcuts: [(key: String, description: String, section: String)] = [
        ("⌘K", "Command Palette", "General"),
        ("⌘↵", "Run All Agents", "General"),
        ("⌘.", "Stop", "General"),
        ("⌘,", "Settings", "General"),
        ("⌘E", "Export Results", "General"),
        ("⌘L", "Clear Prompt", "General"),
        ("?", "Show Help", "General"),
        ("⌘S", "Toggle Sidebar", "Navigation"),
        ("⌘1-8", "Select Desk", "Navigation"),
        ("⌘↑/↓", "Navigate Prompt History", "Navigation"),
        ("ESC", "Close Modal", "Navigation"),
        ("Drag", "Seat Agent", "Agent Actions"),
        ("Click", "View Details", "Agent Actions"),
        ("Double-click", "Seat at Role", "Agent Actions"),
    ]

    var sections: [String] {
        Array(Set(shortcuts.map { $0.section })).sorted()
    }

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
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sections, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.blue)

                            ForEach(shortcuts.filter { $0.section == section }, id: \.key) { shortcut in
                                HStack {
                                    Text(shortcut.key)
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
                                        .frame(minWidth: 60, alignment: .center)

                                    Text(shortcut.description)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 380, height: 420)
    }
}

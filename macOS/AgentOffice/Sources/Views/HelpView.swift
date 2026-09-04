// HelpView.swift
import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss

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
                    shortcutSection("General", [
                        ("⌘K", "Command Palette"),
                        ("⌘↵", "Run All Agents"),
                        ("⌘.", "Stop"),
                        ("⌘,", "Settings"),
                        ("?", "Show Help"),
                        ("⌘E", "Export"),
                    ])
                    shortcutSection("Navigation", [
                        ("⌘S", "Toggle Sidebar"),
                        ("⌘1-8", "Select Desk"),
                        ("ESC", "Close Modal"),
                    ])
                    shortcutSection("Agent Actions", [
                        ("Drag", "Seat Agent"),
                        ("Click", "View Details"),
                        ("Double-click", "Seat at Role"),
                    ])
                }
                .padding()
            }
        }
        .frame(width: 400, height: 450)
    }

    func shortcutSection(_ title: String, _ items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 13, weight: .semibold))
            ForEach(items, id: \.1) { key, desc in
                HStack {
                    Text(key).font(.system(size: 11, design: .monospaced))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                    Text(desc).font(.system(size: 12))
                }
            }
        }
    }
}

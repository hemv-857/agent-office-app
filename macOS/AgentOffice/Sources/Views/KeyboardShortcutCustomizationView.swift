// KeyboardShortcutCustomizationView.swift
import SwiftUI

struct KeyboardShortcutCustomizationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @StateObject private var shortcutsManager = KeyboardShortcutsManager.shared
    @State private var editingShortcut: KeyboardShortcutsManager.KeyboardShortcut?

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

            // Shortcuts list
            List {
                ForEach(shortcutsManager.shortcuts) { shortcut in
                    ShortcutRow(shortcut: shortcut) {
                        editingShortcut = shortcut
                    }
                }
            }

            Divider()

            HStack {
                Button("Reset to Defaults") {
                    shortcutsManager.shortcuts = shortcutsManager.defaultShortcuts()
                    shortcutsManager.saveShortcuts()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .sheet(item: $editingShortcut) { shortcut in
            EditShortcutView(shortcut: shortcut) { updated in
                shortcutsManager.updateShortcut(updated)
                editingShortcut = nil
            }
        }
    }
}

// MARK: - Shortcut Row
struct ShortcutRow: View {
    let shortcut: KeyboardShortcutsManager.KeyboardShortcut
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.name)
                    .font(.system(size: 12, weight: .medium))
                Text(shortcut.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onEdit) {
                Text(shortcut.displayString)
                    .font(.system(size: 10, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)

            Toggle("", isOn: Binding(
                get: { shortcut.isEnabled },
                set: { _ in KeyboardShortcutsManager.shared.toggleShortcut(id: shortcut.id) }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Edit Shortcut View
struct EditShortcutView: View {
    @Environment(\.dismiss) var dismiss
    let shortcut: KeyboardShortcutsManager.KeyboardShortcut
    let onSave: (KeyboardShortcutsManager.KeyboardShortcut) -> Void

    @State private var key: String
    @State private var modifiers: [String]

    init(shortcut: KeyboardShortcutsManager.KeyboardShortcut, onSave: @escaping (KeyboardShortcutsManager.KeyboardShortcut) -> Void) {
        self.shortcut = shortcut
        self.onSave = onSave
        _key = State(initialValue: shortcut.key)
        _modifiers = State(initialValue: shortcut.modifiers)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Shortcut").font(.headline)
            Text(shortcut.action.rawValue).foregroundStyle(.secondary)

            HStack {
                Text("Key:").font(.system(size: 11))
                TextField("Key", text: $key)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }

            HStack {
                Text("Modifiers:").font(.system(size: 11))
                ForEach(["command", "shift", "control", "option"], id: \.self) { mod in
                    Toggle(mod.capitalized, isOn: Binding(
                        get: { modifiers.contains(mod) },
                        set: { contains in
                            if contains {
                                modifiers.append(mod)
                            } else {
                                modifiers.removeAll { $0 == mod }
                            }
                        }
                    ))
                    .toggleStyle(.checkbox)
                    .font(.system(size: 10))
                }
            }

            HStack {
                Text("Preview:").font(.system(size: 11))
                Text(displayString)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            }

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") {
                    var updated = shortcut
                    updated.key = key
                    updated.modifiers = modifiers
                    onSave(updated)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 400)
    }

    var displayString: String {
        let parts = modifiers.map { $0.capitalized } + [key.uppercased()]
        return parts.joined(separator: " + ")
    }
}

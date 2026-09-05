// PluginConfigView.swift
import SwiftUI

struct PluginConfigView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var plugins: [PluginManager.Plugin] = []
    @State private var showingInstallPlugin = false
    @State private var newPluginName = ""
    @State private var newPluginDescription = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Plugins").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Plugin list
            if plugins.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "puzzlepiece").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No plugins installed").foregroundStyle(.secondary)
                    Text("Install plugins to extend functionality")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(plugins) { plugin in
                        PluginRow(plugin: plugin) {
                            togglePlugin(plugin)
                        } onDelete: {
                            deletePlugin(plugin)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Install Plugin") { showingInstallPlugin = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingInstallPlugin) {
            InstallPluginView(
                name: $newPluginName,
                description: $newPluginDescription,
                onSave: installPlugin
            )
        }
        .onAppear {
            plugins = PluginManager.shared.plugins
        }
    }

    func installPlugin() {
        let plugin = PluginManager.Plugin(
            id: UUID().uuidString,
            name: newPluginName,
            description: newPluginDescription,
            version: "1.0.0",
            author: "User",
            isEnabled: true,
            hooks: [],
            settings: [:]
        )
        PluginManager.shared.registerPlugin(plugin)
        plugins = PluginManager.shared.plugins
        newPluginName = ""
        newPluginDescription = ""
        showingInstallPlugin = false
    }

    func togglePlugin(_ plugin: PluginManager.Plugin) {
        if plugin.isEnabled {
            PluginManager.shared.disablePlugin(id: plugin.id)
        } else {
            PluginManager.shared.enablePlugin(id: plugin.id)
        }
        plugins = PluginManager.shared.plugins
    }

    func deletePlugin(_ plugin: PluginManager.Plugin) {
        PluginManager.shared.unregisterPlugin(id: plugin.id)
        plugins = PluginManager.shared.plugins
    }
}

// MARK: - Plugin Row
struct PluginRow: View {
    let plugin: PluginManager.Plugin
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(plugin.name).font(.system(size: 12, weight: .medium))
                    Text(plugin.version)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
                }
                Text(plugin.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("by \(plugin.author)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { plugin.isEnabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Install Plugin View
struct InstallPluginView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var description: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Install Plugin").font(.headline)

            TextField("Plugin Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Install") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}

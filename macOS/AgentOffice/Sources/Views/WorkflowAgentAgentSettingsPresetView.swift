// WorkflowAgentAgentSettingsPresetView.swift
import SwiftUI

struct WorkflowAgentAgentSettingsPresetView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let presets: [(String, String, String)] = [
        ("Default", "Balanced settings for all agents", "temperature: 0.7, maxTokens: 4096"),
        ("Creative", "Higher temperature for brainstorming", "temperature: 1.2, maxTokens: 8192"),
        ("Precise", "Lower temperature for accuracy", "temperature: 0.3, maxTokens: 2048"),
        ("Fast", "Minimal tokens for quick responses", "temperature: 0.5, maxTokens: 1024"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Presets").font(.headline)
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
                    ForEach(presets.indices, id: \.self) { i in
                        SettingsPresetRow(
                            name: presets[i].0,
                            description: presets[i].1,
                            settings: presets[i].2
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Create Preset") {
                    store.showToast("Preset created", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 400)
    }
}

// MARK: - Settings Preset Row
struct SettingsPresetRow: View {
    let name: String
    let description: String
    let settings: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(settings)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

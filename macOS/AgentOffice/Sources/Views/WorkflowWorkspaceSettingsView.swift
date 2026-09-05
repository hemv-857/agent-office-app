// WorkflowWorkspaceSettingsView.swift
import SwiftUI

struct WorkflowWorkspaceSettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var workspaceName = "Default Office"
    @State private var autoSave = true
    @State private var autoBackup = true
    @State private var showAnimations = true
    @State private var compactMode = false
    @State private var soundEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workspace Settings").font(.headline)
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
                    // General
                    GroupBox("General") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Workspace name", text: $workspaceName)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(8)
                    }

                    // Behavior
                    GroupBox("Behavior") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Auto-save sessions", isOn: $autoSave)
                            Toggle("Auto-backup daily", isOn: $autoBackup)
                            Toggle("Enable animations", isOn: $showAnimations)
                            Toggle("Compact mode", isOn: $compactMode)
                            Toggle("Sound notifications", isOn: $soundEnabled)
                        }
                        .padding(8)
                    }

                    // Defaults
                    GroupBox("Defaults") {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Default mode", selection: $store.workflowMode) {
                                ForEach(WorkflowMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue.capitalized).tag(mode)
                                }
                            }
                            HStack {
                                Text("Max concurrent agents:")
                                TextField("8", text: .constant("8"))
                                    .frame(width: 50)
                            }
                        }
                        .padding(8)
                    }

                    // Reset
                    GroupBox("Reset") {
                        HStack {
                            Button("Reset to Defaults") {
                                workspaceName = "Default Office"
                                autoSave = true
                                autoBackup = true
                                showAnimations = true
                                compactMode = false
                                soundEnabled = true
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Save") {
                    store.showToast("Workspace settings saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

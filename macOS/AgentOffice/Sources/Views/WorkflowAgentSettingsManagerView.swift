// WorkflowAgentSettingsManagerView.swift
import SwiftUI

struct WorkflowAgentSettingsManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = "general"

    private let tabs = ["general", "models", "agents", "workflows", "data"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings Manager").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Tab picker
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab.capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedTab == tab ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedTab == tab ? .white : .primary)
                            .onTapGesture { selectedTab = tab }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if selectedTab == "general" {
                        GroupBox("General Settings") {
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Dark mode", isOn: .constant(true))
                                Toggle("Reduce animations", isOn: .constant(false))
                                Toggle("Show tooltips", isOn: .constant(true))
                                Toggle("Auto-save sessions", isOn: .constant(true))
                            }
                            .padding(8)
                        }
                    } else if selectedTab == "models" {
                        GroupBox("Model Settings") {
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Streaming responses", isOn: .constant(true))
                                Toggle("Cache responses", isOn: .constant(true))
                                Toggle("Auto-select model", isOn: .constant(false))
                            }
                            .padding(8)
                        }
                    } else if selectedTab == "agents" {
                        GroupBox("Agent Settings") {
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Auto-assign tasks", isOn: .constant(true))
                                Toggle("Enable collaboration", isOn: .constant(true))
                                Toggle("Log all interactions", isOn: .constant(false))
                            }
                            .padding(8)
                        }
                    } else if selectedTab == "workflows" {
                        GroupBox("Workflow Settings") {
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Auto-optimize", isOn: .constant(false))
                                Toggle("Parallel execution", isOn: .constant(true))
                                Toggle("Error recovery", isOn: .constant(true))
                            }
                            .padding(8)
                        }
                    } else if selectedTab == "data" {
                        GroupBox("Data Settings") {
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Export analytics", isOn: .constant(false))
                                Toggle("Backup sessions", isOn: .constant(true))
                                Toggle("Anonymize data", isOn: .constant(false))
                            }
                            .padding(8)
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Save") {
                    store.showToast("Settings saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 480, height: 520)
    }
}

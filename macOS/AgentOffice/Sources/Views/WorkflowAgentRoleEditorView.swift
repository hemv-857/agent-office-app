// WorkflowAgentRoleEditorView.swift
import SwiftUI

struct WorkflowAgentRoleEditorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedRole = "Architect"
    @State private var temperature = 0.7
    @State private var maxTokens = 4096
    @State private var systemPrompt = "You are an expert architect. Review designs and provide feedback on scalability, maintainability, and best practices."

    private let roles = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Role Editor").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            HStack(spacing: 16) {
                // Role selector
                VStack(alignment: .leading, spacing: 6) {
                    Text("Select Role").font(.system(size: 11, weight: .semibold))
                    List(roles, id: \.self, selection: $selectedRole) { role in
                        Text(role).font(.system(size: 11))
                    }
                    .listStyle(.plain)
                    .frame(width: 120, height: 200)
                }

                // Role config
                VStack(alignment: .leading, spacing: 10) {
                    GroupBox("Model Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Temperature:")
                                Slider(value: $temperature, in: 0...2, step: 0.1)
                                Text(String(format: "%.1f", temperature))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 30)
                            }
                            HStack {
                                Text("Max Tokens:")
                                Slider(value: Binding(get: { Double(maxTokens) }, set: { maxTokens = Int($0) }), in: 256...8192, step: 256)
                                Text("\(maxTokens)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                        }
                        .padding(8)
                    }

                    GroupBox("System Prompt") {
                        TextEditor(text: $systemPrompt)
                            .font(.system(size: 10))
                            .frame(height: 100)
                            .padding(4)
                    }
                }
            }
            .padding()

            Divider()

            HStack {
                Button("Reset to Default") {
                    temperature = 0.7
                    maxTokens = 4096
                    systemPrompt = "You are an expert \(selectedRole.lowercased())."
                    store.showToast("Reset to defaults", type: .info)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Save") {
                    store.showToast("Role \(selectedRole) updated", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 560, height: 480)
    }
}

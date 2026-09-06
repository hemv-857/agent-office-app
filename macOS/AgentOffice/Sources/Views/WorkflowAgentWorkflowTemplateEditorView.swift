// WorkflowAgentWorkflowTemplateEditorView.swift
import SwiftUI

struct WorkflowAgentWorkflowTemplateEditorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var templateName = "Custom Workflow"
    @State private var selectedMode = "parallel"
    @State private var agentCount = 3
    @State private var autoStart = true

    private let modes = ["parallel", "pipeline", "review", "debate", "synthesis", "quality-gate"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Template Editor").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox("Basic Info") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Name:")
                                TextField("Template name", text: $templateName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            HStack {
                                Text("Mode:")
                                Picker("", selection: $selectedMode) {
                                    ForEach(modes, id: \.self) { Text($0.capitalized) }
                                }
                                .labelsHidden()
                            }
                            HStack {
                                Text("Agents:")
                                Stepper("\(agentCount)", value: $agentCount, in: 2...8)
                            }
                            Toggle("Auto-start on creation", isOn: $autoStart)
                        }
                        .padding(8)
                    }

                    GroupBox("Description") {
                        TextEditor(text: .constant("A custom workflow template for repeated tasks."))
                            .font(.system(size: 10))
                            .frame(height: 60)
                            .padding(4)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Reset") {
                    templateName = "Custom Workflow"
                    selectedMode = "parallel"
                    agentCount = 3
                    autoStart = true
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Save Template") {
                    store.showToast("Template saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}

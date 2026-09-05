// WorkflowTemplateDesignerView.swift
import SwiftUI

struct WorkflowTemplateDesignerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var selectedMode: WorkflowMode = .parallel
    @State private var selectedRoles: Set<String> = ["architect", "builder"]
    @State private var promptTemplate = ""

    private let availableRoles = ["architect", "builder", "reviewer", "tester", "planner", "designer", "devops", "security"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Template Designer").font(.headline)
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
                    GroupBox("Template Info") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Template name", text: $templateName)
                                .textFieldStyle(.roundedBorder)
                            TextField("Description", text: $templateDescription)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(8)
                    }

                    GroupBox("Workflow Mode") {
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(WorkflowMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue.capitalized).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(4)
                    }

                    GroupBox("Required Roles") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                            ForEach(availableRoles, id: \.self) { role in
                                Toggle(isOn: Binding(
                                    get: { selectedRoles.contains(role) },
                                    set: { if $0 { selectedRoles.insert(role) } else { selectedRoles.remove(role) } }
                                )) {
                                    Text(role.capitalized)
                                        .font(.system(size: 10))
                                }
                                .toggleStyle(.checkbox)
                            }
                        }
                        .padding(4)
                    }

                    GroupBox("Prompt Template") {
                        TextEditor(text: $promptTemplate)
                            .font(.system(size: 11, design: .monospaced))
                            .frame(height: 100)
                            .scrollContentBackground(.visible)
                            .padding(4)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                let valid = !templateName.isEmpty && !selectedRoles.isEmpty
                Text("\(selectedRoles.count) roles selected")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Save Template") {
                    let template = WorkflowTemplate(
                        id: templateName.lowercased().replacingOccurrences(of: " ", with: "-"),
                        label: templateName,
                        icon: "doc.text",
                        prompt: promptTemplate,
                        agentRoles: selectedRoles.sorted(),
                        workflowMode: selectedMode,
                        description: templateDescription
                    )
                    store.showToast("Template '\(templateName)' saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!valid)
            }
            .padding()
        }
        .frame(width: 560, height: 560)
    }
}

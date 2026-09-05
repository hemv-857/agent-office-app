// WorkflowTemplateEditorView.swift
import SwiftUI

struct WorkflowTemplateEditorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var templates: [WorkflowTemplate] = WorkflowTemplates.all
    @State private var selectedTemplate: WorkflowTemplate?
    @State private var showingNewTemplate = false
    @State private var newTemplateName = ""
    @State private var newTemplatePrompt = ""
    @State private var newTemplateMode: WorkflowMode = .parallel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Edit Templates").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            List {
                ForEach(templates) { template in
                    TemplateEditRow(template: template) {
                        selectedTemplate = template
                    } onDelete: {
                        templates.removeAll { $0.id == template.id }
                    }
                }
            }

            Divider()

            HStack {
                Button("Add Template") { showingNewTemplate = true }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .sheet(isPresented: $showingNewTemplate) {
            NewTemplateSheet(
                name: $newTemplateName,
                prompt: $newTemplatePrompt,
                mode: $newTemplateMode,
                onSave: {
                    let template = WorkflowTemplate(
                        id: UUID().uuidString,
                        label: newTemplateName,
                        icon: "doc.text",
                        prompt: newTemplatePrompt,
                        agentRoles: [],
                        workflowMode: newTemplateMode,
                        description: "Custom template"
                    )
                    templates.append(template)
                    newTemplateName = ""
                    newTemplatePrompt = ""
                    showingNewTemplate = false
                }
            )
        }
    }
}

// MARK: - Template Edit Row
struct TemplateEditRow: View {
    let template: WorkflowTemplate
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(template.icon).font(.system(size: 16))
            VStack(alignment: .leading) {
                Text(template.label).font(.system(size: 12, weight: .medium))
                Text(template.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(template.workflowMode.rawValue.capitalized)
                .font(.system(size: 9))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
        }
    }
}

// MARK: - New Template Sheet
struct NewTemplateSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var prompt: String
    @Binding var mode: WorkflowMode
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("New Template").font(.headline)
            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            TextEditor(text: $prompt)
                .font(.system(size: 11))
                .frame(height: 80)
                .scrollContentBackground(.visible)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            Picker("Mode", selection: $mode) {
                ForEach(WorkflowMode.allCases, id: \.self) { m in
                    Text(m.rawValue.capitalized).tag(m)
                }
            }
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Create") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}

// PromptTemplatesView.swift
import SwiftUI

struct PromptTemplatesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var templates: [SavedPromptTemplate] = []
    @State private var showingAddTemplate = false
    @State private var newTemplateName = ""
    @State private var newTemplatePrompt = ""
    @State private var newTemplateCategory = "General"
    @State private var searchText = ""

    private var filteredTemplates: [SavedPromptTemplate] {
        if searchText.isEmpty { return templates }
        return templates.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.prompt.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var categories: [String] {
        Array(Set(templates.map(\.category))).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Templates").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search templates...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Template list
            if filteredTemplates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No templates saved").foregroundStyle(.secondary)
                    Text("Save prompts as templates for reuse")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredTemplates) { template in
                        TemplateRow(template: template) {
                            useTemplate(template)
                        } onDelete: {
                            deleteTemplate(template)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Add Template") { showingAddTemplate = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .sheet(isPresented: $showingAddTemplate) {
            AddTemplateView(
                name: $newTemplateName,
                prompt: $newTemplatePrompt,
                category: $newTemplateCategory,
                onSave: addTemplate
            )
        }
        .onAppear {
            loadTemplates()
        }
    }

    func addTemplate() {
        let template = SavedPromptTemplate(
            id: UUID().uuidString,
            name: newTemplateName,
            prompt: newTemplatePrompt,
            category: newTemplateCategory,
            createdAt: Date()
        )
        templates.append(template)
        saveTemplates()
        newTemplateName = ""
        newTemplatePrompt = ""
        showingAddTemplate = false
    }

    func useTemplate(_ template: SavedPromptTemplate) {
        store.promptText = template.prompt
        dismiss()
    }

    func deleteTemplate(_ template: SavedPromptTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }

    func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: "promptTemplates")
        }
    }

    func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: "promptTemplates"),
           let loaded = try? JSONDecoder().decode([SavedPromptTemplate].self, from: data) {
            templates = loaded
        }
    }
}

// MARK: - Template Row
struct TemplateRow: View {
    let template: SavedPromptTemplate
    let onUse: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(template.name).font(.system(size: 12, weight: .medium))
                    Text(template.category)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
                }
                Text(template.prompt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onUse) {
                    Image(systemName: "arrow.up.circle")
                }
                .buttonStyle(.bordered)
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

// MARK: - Add Template View
struct AddTemplateView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var prompt: String
    @Binding var category: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Save Template").font(.headline)

            TextField("Template Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $prompt)
                .font(.system(size: 12))
                .frame(height: 120)
                .scrollContentBackground(.visible)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

            TextField("Category", text: $category)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || prompt.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}

// MARK: - Model
struct SavedPromptTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let prompt: String
    let category: String
    let createdAt: Date
}

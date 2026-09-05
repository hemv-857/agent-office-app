// WorkflowTemplateCategoriesView.swift
import SwiftUI

struct WorkflowTemplateCategoriesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""

    private let categories: [(String, String, String)] = [
        ("All", "square.grid.2x2", "All templates"),
        ("Analysis", "chart.bar", "Data and research analysis"),
        ("Writing", "pencil", "Content creation and editing"),
        ("Development", "hammer", "Code and technical tasks"),
        ("Design", "paintbrush", "UI/UX and visual design"),
        ("Planning", "calendar", "Project planning and strategy"),
        ("Review", "checkmark.shield", "Quality and review workflows"),
        ("Research", "magnifyingglass", "Research and exploration"),
    ]

    private var filteredTemplates: [WorkflowTemplate] {
        let templates = WorkflowTemplates.all
        if let category = selectedCategory, category != "All" {
            return templates.filter { $0.label.localizedCaseInsensitiveContains(category) }
        }
        if searchText.isEmpty { return templates }
        return templates.filter {
            $0.label.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Templates").font(.headline)
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

            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.0) { cat in
                        CategoryPill(
                            title: cat.0,
                            icon: cat.1,
                            isSelected: selectedCategory == cat.0 || (selectedCategory == nil && cat.0 == "All")
                        ) {
                            selectedCategory = cat.0 == "All" ? nil : cat.0
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            Divider()

            // Templates
            if filteredTemplates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No templates found").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(filteredTemplates) { template in
                            TemplateCardCompact(template: template) {
                                store.promptText = template.prompt
                                store.workflowMode = template.workflowMode
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }

            Divider()

            HStack {
                Text("\(filteredTemplates.count) templates")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10))
                Text(title).font(.system(size: 11))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Template Card
struct TemplateCardCompact: View {
    let template: WorkflowTemplate
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(template.icon).font(.system(size: 16))
                Text(template.label)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
            }

            Text(template.description)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(template.workflowMode.rawValue.capitalized)
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)

                Text("\(template.agentRoles.count) agents")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Use") { onApply() }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

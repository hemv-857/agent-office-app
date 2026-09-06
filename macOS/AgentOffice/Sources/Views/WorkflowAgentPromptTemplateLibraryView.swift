// WorkflowAgentPromptTemplateLibraryView.swift
import SwiftUI

struct WorkflowAgentPromptTemplateLibraryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory = "all"
    @State private var searchText = ""

    private let categories = ["all", "code", "review", "testing", "planning", "security", "design"]

    private let templates: [(String, String, String, String)] = [
        ("Code Review Checklist", "code", "Review the following code for: security, performance, readability, and test coverage.", "reviewer"),
        ("Bug Report", "testing", "Analyze this bug report and provide: root cause, impact assessment, and fix suggestion.", "tester"),
        ("API Design", "design", "Design a REST API for the following feature with proper endpoints, methods, and response schemas.", "architect"),
        ("Test Plan", "testing", "Create a comprehensive test plan for the following feature covering unit, integration, and E2E tests.", "tester"),
        ("Security Audit", "security", "Perform a security audit of the following code focusing on OWASP Top 10 vulnerabilities.", "security"),
        ("Sprint Planning", "planning", "Analyze the backlog and propose a sprint plan with priorities and time estimates.", "planner"),
        ("Code Refactor", "code", "Identify refactoring opportunities in the following code and propose improvements.", "builder"),
        ("Documentation", "code", "Generate comprehensive documentation for the following code including API docs and usage examples.", "builder"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Templates").font(.headline)
                Spacer()
                Text("\(templates.count) templates")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search templates...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal)

            // Category filter
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat.capitalized)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedCategory == cat ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedCategory == cat ? .white : .primary)
                            .onTapGesture { selectedCategory = cat }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Templates
            List {
                ForEach(templates.filter { (selectedCategory == "all" || $0.1 == selectedCategory) && (searchText.isEmpty || $0.0.localizedCaseInsensitiveContains(searchText)) }, id: \.0) { template in
                    PromptTemplateItem(
                        name: template.0,
                        category: template.1,
                        prompt: template.2,
                        agent: template.3
                    )
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                Button("Create Template") {
                    store.showToast("Template created", type: .success)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Prompt Template Item
struct PromptTemplateItem: View {
    let name: String
    let category: String
    let prompt: String
    let agent: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text(category)
                    .font(.system(size: 8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
                Text(agent)
                    .font(.system(size: 8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.1), in: Capsule())
                    .foregroundStyle(Color.accentColor)
            }
            Text(prompt)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

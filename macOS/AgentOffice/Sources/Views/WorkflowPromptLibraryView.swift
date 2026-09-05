// WorkflowPromptLibraryView.swift
import SwiftUI

struct WorkflowPromptLibraryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var selectedCategory = "all"

    private let categories = ["all", "code", "design", "writing", "analysis", "planning"]

    private let prompts: [(String, String, String, String)] = [
        ("Code Review", "Analyze this code for bugs, performance issues, and style violations", "code", "Engineer"),
        ("Architecture", "Design a scalable architecture for this feature", "design", "Architect"),
        ("Documentation", "Write comprehensive documentation for this module", "writing", "Technical Writer"),
        ("Data Analysis", "Analyze this dataset and provide insights", "analysis", "Data Scientist"),
        ("Project Plan", "Create a detailed project plan with milestones", "planning", "Planner"),
        ("Refactor", "Identify and suggest refactoring opportunities", "code", "Senior Engineer"),
        ("Testing", "Write comprehensive test cases for this function", "code", "QA Engineer"),
        ("Security Audit", "Perform a security audit of this endpoint", "code", "Security Engineer"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Library").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search and filter
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search prompts...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

            ScrollView(.horizontal) {
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
            .padding(.vertical, 8)

            Divider()

            // Prompt list
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredPrompts, id: \.0) { prompt in
                        PromptRow(
                            title: prompt.0,
                            description: prompt.1,
                            category: prompt.2,
                            role: prompt.3
                        )
                        .onTapGesture {
                            store.promptText = prompt.1
                            dismiss()
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(filteredPrompts.count) prompts")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 520)
    }

    private var filteredPrompts: [(String, String, String, String)] {
        prompts.filter { prompt in
            (selectedCategory == "all" || prompt.2 == selectedCategory) &&
            (searchText.isEmpty || prompt.0.localizedCaseInsensitiveContains(searchText) || prompt.1.localizedCaseInsensitiveContains(searchText))
        }
    }
}

// MARK: - Prompt Row
struct PromptRow: View {
    let title: String
    let description: String
    let category: String
    let role: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text(role)
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
            }
            Text(description)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(category.capitalized)
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

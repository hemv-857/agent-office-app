// WorkflowPromptTemplatesLibraryView.swift
import SwiftUI

struct WorkflowPromptTemplatesLibraryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private let templates: [(String, String, String)] = [
        ("Code Review", "Review this code for issues", "magnifyingglass"),
        ("Bug Report", "Describe the bug and steps to reproduce", "ant.fill"),
        ("Feature Request", "Describe the new feature", "plus.circle"),
        ("Documentation", "Write documentation for", "doc.text"),
        ("Test Cases", "Generate test cases for", "checkmark.shield"),
        ("Refactor", "Refactor this code for better", "arrow.triangle.branch"),
    ]

    private var filtered: [(String, String, String)] {
        searchText.isEmpty ? templates : templates.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
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

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search templates...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(filtered, id: \.0) { template in
                        PromptTemplateRow(
                            name: template.0,
                            prompt: template.1,
                            icon: template.2,
                            onUse: {
                                store.promptText = template.1
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(filtered.count) templates")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 450)
    }
}

// MARK: - Prompt Template Row
struct PromptTemplateRow: View {
    let name: String
    let prompt: String
    let icon: String
    let onUse: () -> Void

    var body: some View {
        Button(action: onUse) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 11, weight: .medium))
                    Text(prompt)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "arrow.right.circle")
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

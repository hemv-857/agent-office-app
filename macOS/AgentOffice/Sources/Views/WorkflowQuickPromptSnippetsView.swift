// WorkflowQuickPromptSnippetsView.swift
import SwiftUI

struct WorkflowQuickPromptSnippetsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var selectedCategory = "all"
    @State private var customSnippets: [(String, String, String, String)] = []

    private let categories = ["all", "code", "writing", "analysis", "planning", "custom"]

    private let builtInSnippets: [(String, String, String, String)] = [
        ("Code Review", "Review this code for bugs, performance, and style issues", "code", "review"),
        ("Refactor", "Refactor this code to improve readability and maintainability", "code", "refactor"),
        ("Test", "Write comprehensive tests for this code", "code", "test"),
        ("Document", "Write documentation for this code", "writing", "docs"),
        ("Explain", "Explain how this code works step by step", "writing", "explain"),
        ("Optimize", "Optimize this code for better performance", "code", "optimize"),
        ("Debug", "Help me debug this issue", "code", "debug"),
        ("Architecture", "Design an architecture for this feature", "planning", "arch"),
        ("API Design", "Design an API for this use case", "planning", "api"),
        ("Data Model", "Design a data model for this domain", "planning", "model"),
        ("Analyze Data", "Analyze this dataset and provide insights", "analysis", "data"),
        ("Summarize", "Summarize this content concisely", "writing", "sum"),
        ("Translate", "Translate this to English", "writing", "translate"),
        ("Compare", "Compare and contrast these two approaches", "analysis", "compare"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Snippets").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Search + add
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search snippets...", text: $searchText).textFieldStyle(.plain)
                }
                .padding(7)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

                Button(action: { addCustomSnippet() }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .help("Add custom snippet")
            }

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

            // Snippets
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredSnippets, id: \.0) { snippet in
                        SnippetRow(
                            title: snippet.0,
                            prompt: snippet.1,
                            category: snippet.2,
                            shortcut: snippet.3
                        )
                        .onTapGesture {
                            store.promptText = snippet.1
                            dismiss()
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Text("\(filteredSnippets.count) snippets")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }

    private var filteredSnippets: [(String, String, String, String)] {
        var all = builtInSnippets + customSnippets.map { ($0.0, $0.1, $0.2, "custom") as (String, String, String, String) }

        if !searchText.isEmpty {
            all = all.filter {
                $0.0.localizedCaseInsensitiveContains(searchText) ||
                $0.1.localizedCaseInsensitiveContains(searchText)
            }
        }

        if selectedCategory != "all" {
            all = all.filter { $0.2 == selectedCategory }
        }

        return all
    }

    private func addCustomSnippet() {
        customSnippets.append(("New Snippet", "Enter prompt text...", "custom", "custom"))
    }
}

// MARK: - Snippet Row
struct SnippetRow: View {
    let title: String
    let prompt: String
    let category: String
    let shortcut: String

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(shortcut)
                        .font(.system(size: 9, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
                Text(prompt)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Image(systemName: "arrow.right.circle")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

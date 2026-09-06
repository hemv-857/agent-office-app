// WorkflowAgentPromptTemplateLibraryView.swift
import SwiftUI

struct WorkflowAgentPromptTemplateLibraryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory = "All"
    @State private var searchText = ""

    private let categories = ["All", "Code", "Review", "Debug", "Docs", "Test"]

    private let templates: [(String, String, String, String)] = [
        ("Code", "Implement Feature", "Implement a new feature with proper error handling, tests, and documentation. Follow the existing code patterns in the project.", "feature"),
        ("Code", "Refactor Module", "Refactor the specified module to improve readability, maintainability, and performance. Ensure all existing tests pass.", "refactor"),
        ("Review", "Code Review", "Review the provided code for bugs, security issues, performance problems, and adherence to coding standards.", "review"),
        ("Review", "Security Audit", "Perform a security audit on the codebase. Check for vulnerabilities, insecure patterns, and compliance issues.", "security"),
        ("Debug", "Debug Error", "Analyze the error message and stack trace. Identify the root cause and provide a fix with explanation.", "debug"),
        ("Debug", "Performance Issue", "Investigate the performance bottleneck. Profile the code and suggest optimizations.", "perf"),
        ("Docs", "Generate Documentation", "Create comprehensive documentation for the API/module including examples, parameters, and return values.", "docs"),
        ("Docs", "Update README", "Update the project README with new features, setup instructions, and usage examples.", "readme"),
        ("Test", "Write Unit Tests", "Write comprehensive unit tests for the specified functionality. Cover edge cases and error paths.", "unit-test"),
        ("Test", "Integration Tests", "Create integration tests for the API endpoints. Test happy path, error cases, and boundary conditions.", "integration"),
    ]

    private var filtered: [(String, String, String, String)] {
        var result = templates
        if selectedCategory != "All" {
            result = result.filter { $0.0 == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.1.localizedCaseInsensitiveContains(searchText) || $0.2.localizedCaseInsensitiveContains(searchText) }
        }
        return result
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
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search templates...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal)

            // Category pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(selectedCategory == cat ? .blue : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedCategory == cat ? .white : .primary)
                            .onTapGesture { selectedCategory = cat }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filtered.indices, id: \.self) { i in
                        TemplateLibraryRow(
                            category: filtered[i].0,
                            name: filtered[i].1,
                            description: filtered[i].2,
                            onUse: {
                                store.promptText = filtered[i].2
                                store.showToast("Template applied: \(filtered[i].1)", type: .success)
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }
}

// MARK: - Template Library Row
struct TemplateLibraryRow: View {
    let category: String
    let name: String
    let description: String
    let onUse: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.text")
                .foregroundStyle(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(name)
                        .font(.system(size: 11, weight: .semibold))
                    Text(category)
                        .font(.system(size: 8))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.blue.opacity(0.2), in: Capsule())
                        .foregroundStyle(.blue)
                }
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Button("Use", action: onUse)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
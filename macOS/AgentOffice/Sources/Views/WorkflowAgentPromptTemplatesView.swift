// WorkflowAgentPromptTemplatesView.swift
import SwiftUI

struct WorkflowAgentPromptTemplatesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory = "All"

    private let categories = ["All", "Code Review", "Bug Fix", "Feature", "Documentation"]

    private let templates: [(String, String, String)] = [
        ("Code Review", "Review this PR for bugs and improvements", "review-pr"),
        ("Bug Fix", "Debug this error and provide a fix", "debug-error"),
        ("Feature", "Implement this feature with tests", "implement-feature"),
        ("Documentation", "Generate API documentation for this module", "generate-docs"),
        ("Code Review", "Check security vulnerabilities in this code", "security-check"),
        ("Feature", "Refactor this module for better performance", "optimize-perf"),
    ]

    private var filtered: [(String, String, String)] {
        selectedCategory == "All" ? templates : templates.filter { $0.0 == selectedCategory }
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
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(filtered[i].0)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Text(filtered[i].1)
                                    .font(.system(size: 11))
                            }
                            Spacer()
                            Button("Use") {
                                store.promptText = filtered[i].1
                                store.showToast("Template applied", type: .success)
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
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
        .frame(width: 480, height: 440)
    }
}

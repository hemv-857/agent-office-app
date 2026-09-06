// WorkflowAgentPromptDesignerView.swift
import SwiftUI

struct WorkflowAgentPromptDesignerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var sections: [(String, String)] = [
        ("Role", "You are an expert software architect..."),
        ("Context", "The project is a macOS SwiftUI app..."),
        ("Task", "Design a new feature for..."),
        ("Constraints", "Follow existing patterns, use SwiftUI..."),
        ("Output", "Return a structured design document..."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Designer").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Section editor
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(sections.indices, id: \.self) { i in
                        PromptSectionRow(
                            title: sections[i].0,
                            content: sections[i].1,
                            onUpdate: { newContent in
                                sections[i].1 = newContent
                            },
                            onDelete: {
                                if sections.count > 1 {
                                    sections.remove(at: i)
                                }
                            }
                        )
                    }
                }
                .padding()
            }

            Divider()

            // Add section
            HStack {
                Button("Add Section") {
                    sections.append(("New Section", ""))
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .padding()

            Divider()

            // Preview
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                ScrollView {
                    Text(sections.map { "## \($0.0)\n\($0.1)" }.joined(separator: "\n\n"))
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .frame(height: 120)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal)

            Divider()

            HStack {
                Button("Save as Template") {
                    store.showToast("Template saved", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Use Now") {
                    store.promptText = sections.map { "## \($0.0)\n\($0.1)" }.joined(separator: "\n\n")
                    store.showToast("Prompt applied", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

// MARK: - Prompt Section Row
struct PromptSectionRow: View {
    let title: String
    let content: String
    let onUpdate: (String) -> Void
    let onDelete: () -> Void

    @State private var editContent: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 80, alignment: .leading)
                TextField("Content", text: $editContent)
                    .textFieldStyle(.plain)
                    .onAppear { editContent = content }
                    .onChange(of: editContent) { onUpdate($0) }
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
    }
}
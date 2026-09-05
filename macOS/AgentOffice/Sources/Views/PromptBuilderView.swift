// PromptBuilderView.swift
import SwiftUI

struct PromptBuilderView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var sections: [PromptSection] = [
        PromptSection(id: UUID(), type: .role, content: "", isRequired: true),
    ]
    @State private var presetName = ""

    struct PromptSection: Identifiable {
        let id: UUID
        var type: SectionType
        var content: String
        var isRequired: Bool

        enum SectionType: String, CaseIterable {
            case role = "Role"
            case context = "Context"
            case task = "Task"
            case constraints = "Constraints"
            case format = "Output Format"
            case example = "Example"
            case custom = "Custom"

            var icon: String {
                switch self {
                case .role: return "person.text.rectangle"
                case .context: return "doc.text"
                case .task: return "checkmark.circle"
                case .constraints: return "exclamationmark.triangle"
                case .format: return "list.bullet"
                case .example: return "text.quote"
                case .custom: return "pencil"
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Builder").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach($sections) { $section in
                        SectionEditor(section: $section) {
                            removeSection(section)
                        }
                    }

                    Button(action: { addSection() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Section")
                        }
                        .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                }
                .padding()
            }

            Divider()

            // Preview
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview").font(.system(size: 11, weight: .semibold))
                ScrollView {
                    Text(buildPrompt())
                        .font(.system(size: 11, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 80)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            HStack {
                Button("Use Prompt") {
                    store.promptText = buildPrompt()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Copy") {
                    ClipboardHistoryManager.shared.copyToClipboard(buildPrompt())
                    store.showToast("Copied to clipboard", type: .success)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 550, height: 600)
    }

    func addSection() {
        sections.append(PromptSection(id: UUID(), type: .custom, content: "", isRequired: false))
    }

    func removeSection(_ section: PromptSection) {
        sections.removeAll { $0.id == section.id }
    }

    func buildPrompt() -> String {
        sections
            .filter { !$0.content.isEmpty }
            .map { "**\($0.type.rawValue):** \($0.content)" }
            .joined(separator: "\n\n")
    }
}

// MARK: - Section Editor
struct SectionEditor: View {
    @Binding var section: PromptBuilderView.PromptSection
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: section.type.icon)
                    .foregroundStyle(Color.accentColor)
                    .font(.system(size: 12))

                Picker("", selection: $section.type) {
                    ForEach(PromptBuilderView.PromptSection.SectionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)

                Spacer()

                if !section.isRequired {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            TextEditor(text: $section.content)
                .font(.system(size: 11))
                .frame(height: 60)
                .scrollContentBackground(.visible)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}

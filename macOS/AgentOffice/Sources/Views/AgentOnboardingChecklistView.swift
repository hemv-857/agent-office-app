// AgentOnboardingChecklistView.swift
import SwiftUI

struct AgentOnboardingChecklistView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @AppStorage("onboardingCompleted") private var completed = false

    @State private var checkedItems: Set<UUID> = []

    private let items: [(String, String, String)] = [
        ("API Key configured", "key", "Set up your LLM provider API key"),
        ("Provider selected", "cpu", "Choose Anthropic, OpenAI, or Ollama"),
        ("First agent seated", "person.fill", "Drag an agent to a desk"),
        ("Prompt sent", "text.alignleft", "Send your first prompt to agents"),
        ("Results viewed", "doc.text", "Review agent responses"),
        ("Cost tracker checked", "dollarsign.circle", "Monitor your API costs"),
        ("Keyboard shortcuts learned", "command", "Press ? to see shortcuts"),
        ("Settings explored", "gearshape", "Customize your experience"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Getting Started").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Progress
            let progress = Double(checkedItems.count) / Double(items.count)
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .tint(.accentColor)
                Text("\(checkedItems.count)/\(items.count) completed")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()

            // Checklist
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        ChecklistRow(
                            title: item.0,
                            icon: item.1,
                            description: item.2,
                            isChecked: checkedItems.contains(UUID(uuidString: "\(index)-\(item.0)") ?? UUID())
                        ) {
                            let id = UUID(uuidString: "\(index)-\(item.0)") ?? UUID()
                            if checkedItems.contains(id) {
                                checkedItems.remove(id)
                            } else {
                                checkedItems.insert(id)
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                if progress >= 1.0 && !completed {
                    Button("Complete Setup") {
                        completed = true
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 480)
    }
}

// MARK: - Checklist Row
struct ChecklistRow: View {
    let title: String
    let icon: String
    let description: String
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isChecked ? .green : .secondary)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: isChecked ? .regular : .medium))
                        .strikethrough(isChecked)
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isChecked ? Color.green.opacity(0.05) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

// PromptHistoryDropdown.swift
import SwiftUI

struct PromptHistoryDropdown: View {
    @Binding var isVisible: Bool
    @Binding var selectedPrompt: String
    let history: [String]
    let onSelect: (String) -> Void

    var body: some View {
        if isVisible && !history.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(history.prefix(10).enumerated()), id: \.offset) { index, prompt in
                    Button(action: {
                        selectedPrompt = prompt
                        onSelect(prompt)
                        isVisible = false
                    }) {
                        HStack {
                            Text(prompt)
                                .font(.system(size: 11))
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(index + 1)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < min(history.count, 10) - 1 {
                        Divider().padding(.horizontal, 8)
                    }
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }
}

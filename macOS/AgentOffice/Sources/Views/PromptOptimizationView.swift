// PromptOptimizationView.swift
import SwiftUI

struct PromptOptimizationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var originalPrompt = ""
    @State private var optimizedPrompt = ""
    @State private var suggestions: [String] = []
    @State private var isOptimizing = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prompt Optimizer").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                // Original prompt
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Original Prompt").font(.system(size: 11, weight: .semibold))
                        Spacer()
                        Text("\(originalPrompt.count) chars")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    TextEditor(text: $originalPrompt)
                        .font(.system(size: 11))
                        .frame(height: 100)
                        .scrollContentBackground(.visible)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }

                Button(action: { optimizePrompt() }) {
                    HStack {
                        if isOptimizing {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isOptimizing ? "Optimizing..." : "Optimize Prompt")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(originalPrompt.isEmpty || isOptimizing)

                // Optimized prompt
                if !optimizedPrompt.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Optimized Prompt").font(.system(size: 11, weight: .semibold))
                            Spacer()
                            Text("\(optimizedPrompt.count) chars")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                            let improvement = ((Double(optimizedPrompt.count) - Double(originalPrompt.count)) / Double(originalPrompt.count) * 100)
                            Text(String(format: "%+.0f%%", improvement))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(improvement > 0 ? .green : .red)
                        }
                        TextEditor(text: $optimizedPrompt)
                            .font(.system(size: 11))
                            .frame(height: 100)
                            .scrollContentBackground(.visible)
                            .background(.green.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
                    }
                }

                // Suggestions
                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Suggestions").font(.system(size: 11, weight: .semibold))
                        ForEach(suggestions, id: \.self) { suggestion in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.yellow)
                                Text(suggestion)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()

            Divider()

            HStack {
                Button("Use Original") {
                    store.promptText = originalPrompt
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Use Optimized") {
                    store.promptText = optimizedPrompt
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(optimizedPrompt.isEmpty)

                Spacer()

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 550, height: 550)
    }

    func optimizePrompt() {
        isOptimizing = true
        // Simulate optimization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            optimizedPrompt = "Please provide a comprehensive and detailed response to the following: \(originalPrompt)\n\nPlease structure your response with clear sections, use specific examples where relevant, and ensure your answer is actionable and well-organized."
            suggestions = [
                "Added structure instructions for clearer responses",
                "Included request for examples to improve quality",
                "Added actionable requirement for practical output",
                "Length increased for better context",
            ]
            isOptimizing = false
        }
    }
}

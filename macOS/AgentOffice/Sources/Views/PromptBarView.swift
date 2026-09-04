// PromptBarView.swift
import SwiftUI

struct PromptBarView: View {
    @EnvironmentObject var store: AppStore
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 10) {
                // Workflow mode picker
                Picker("", selection: $store.workflowMode) {
                    ForEach(WorkflowMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 140)

                // Text input
                TextField("Enter your prompt...", text: $store.promptText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onSubmit { store.runAll() }

                // Run button
                Button(action: store.runAll) {
                    Image(systemName: store.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(store.isRunning ? .red : .green, in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
                .disabled(store.promptText.isEmpty && !store.isRunning)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .background(.background)
    }
}

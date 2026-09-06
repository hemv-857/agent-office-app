// WorkflowAgentAgentSettingsView.swift
import SwiftUI

struct WorkflowAgentAgentSettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedAgent = "Architect"
    @State private var temperature = 0.7
    @State private var maxTokens = 4096
    @State private var systemPrompt = ""

    private let agents = ["Architect", "Builder", "Reviewer", "Tester", "Planner", "Security"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Settings").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Agent picker
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(agents, id: \.self) { agent in
                        Text(agent)
                            .font(.system(size: 10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedAgent == agent ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: Capsule())
                            .foregroundStyle(selectedAgent == agent ? .white : .primary)
                            .onTapGesture { selectedAgent = agent }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Settings
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox("Model Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Temperature:")
                                Slider(value: $temperature, in: 0...2, step: 0.1)
                                Text(String(format: "%.1f", temperature))
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 30)
                            }
                            HStack {
                                Text("Max Tokens:")
                                Slider(value: Binding(get: { Double(maxTokens) }, set: { maxTokens = Int($0) }), in: 256...8192, step: 256)
                                Text("\(maxTokens)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(width: 40)
                            }
                        }
                        .padding(8)
                    }

                    GroupBox("System Prompt") {
                        TextEditor(text: $systemPrompt)
                            .font(.system(size: 10))
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                    }

                    GroupBox("Behavior") {
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle("Enable streaming", isOn: .constant(true))
                            Toggle("Cache responses", isOn: .constant(true))
                            Toggle("Log all interactions", isOn: .constant(false))
                            Toggle("Auto-retry on failure", isOn: .constant(true))
                        }
                        .padding(8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Save") {
                    store.showToast("Settings saved", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 520, height: 560)
    }
}

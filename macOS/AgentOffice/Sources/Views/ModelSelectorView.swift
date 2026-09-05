// ModelSelectorView.swift
import SwiftUI

struct ModelSelectorView: View {
    @Binding var selectedModel: String
    let provider: LLMProvider

    private var availableModels: [String] {
        switch provider {
        case .anthropic:
            return ["claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-opus-20240229"]
        case .openai:
            return ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo"]
        case .ollama:
            return ["llama3.1", "llama3", "mistral", "codellama", "phi3", "gemma2"]
        }
    }

    var body: some View {
        Picker("Model", selection: $selectedModel) {
            ForEach(availableModels, id: \.self) { model in
                Text(model).tag(model)
            }
        }
        .pickerStyle(.menu)
    }
}

// MARK: - Per-Agent Model Config
struct AgentModelConfigView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var agentModels: [String: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Agent Models").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(store.allAgents) { agent in
                        HStack {
                            Text("\(agent.emoji) \(agent.name)")
                                .font(.system(size: 12))
                                .frame(width: 150, alignment: .leading)

                            ModelSelectorView(
                                selectedModel: Binding(
                                    get: { agentModels[agent.id] ?? defaultModel },
                                    set: { agentModels[agent.id] = $0 }
                                ),
                                provider: store.selectedProvider
                            )

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.vertical)
            }

            Divider()

            HStack {
                Spacer()
                Button("Apply to All") {
                    for agent in store.allAgents {
                        agentModels[agent.id] = defaultModel
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Done") {
                    saveConfigs()
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .onAppear {
            loadConfigs()
        }
    }

    var defaultModel: String {
        switch store.selectedProvider {
        case .anthropic: return "claude-3-5-sonnet-20241022"
        case .openai: return "gpt-4o"
        case .ollama: return "llama3.1"
        }
    }

    func saveConfigs() {
        if let data = try? JSONEncoder().encode(agentModels) {
            UserDefaults.standard.set(data, forKey: "agentModelConfigs")
        }
    }

    func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: "agentModelConfigs"),
           let loaded = try? JSONDecoder().decode([String: String].self, from: data) {
            agentModels = loaded
        }
    }
}

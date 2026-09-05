// BatchRunView.swift
import SwiftUI

struct BatchRunView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var prompt = ""
    @State private var selectedAgentIds: Set<String> = []
    @State private var isRunning = false
    @State private var results: [(String, String)] = []
    @State private var selectedMode: WorkflowMode = .parallel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Batch Run").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                // Prompt
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prompt").font(.system(size: 11, weight: .semibold))
                    TextEditor(text: $prompt)
                        .font(.system(size: 12))
                        .frame(height: 80)
                        .scrollContentBackground(.visible)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.quaternary, lineWidth: 1)
                        )
                }

                // Mode
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mode").font(.system(size: 11, weight: .semibold))
                    Picker("", selection: $selectedMode) {
                        ForEach(WorkflowMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Agent selection
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Agents").font(.system(size: 11, weight: .semibold))
                        Spacer()
                        Button(selectedAgentIds.count == store.allAgents.count ? "Deselect All" : "Select All") {
                            if selectedAgentIds.count == store.allAgents.count {
                                selectedAgentIds.removeAll()
                            } else {
                                selectedAgentIds = Set(store.allAgents.map(\.id))
                            }
                        }
                        .font(.caption)
                    }
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                            ForEach(store.allAgents) { agent in
                                AgentChip(
                                    agent: agent,
                                    isSelected: selectedAgentIds.contains(agent.id),
                                    onTap: {
                                        if selectedAgentIds.contains(agent.id) {
                                            selectedAgentIds.remove(agent.id)
                                        } else {
                                            selectedAgentIds.insert(agent.id)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }

                // Results
                if !results.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Results (\(results.count))").font(.system(size: 11, weight: .semibold))
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(results, id: \.0) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.0)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.blue)
                                        Text(item.1)
                                            .font(.system(size: 10))
                                            .lineLimit(3)
                                    }
                                    .padding(6)
                                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                }
            }
            .padding()

            Divider()

            // Actions
            HStack {
                Text("\(selectedAgentIds.count) agents selected")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button(isRunning ? "Running..." : "Run Batch") {
                    runBatch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(prompt.isEmpty || selectedAgentIds.isEmpty || isRunning)

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 550, height: 550)
    }

    func runBatch() {
        isRunning = true
        results = []

        Task {
            let agents = store.allAgents.filter { selectedAgentIds.contains($0.id) }

            for agent in agents {
                do {
                    let service = LLMService(provider: store.selectedProvider, apiKey: store.apiKey)
                    let response = try await service.execute(systemPrompt: agent.systemPrompt, userMessage: prompt)
                    results.append((agent.name, response.text))
                } catch {
                    results.append((agent.name, "Error: \(error.localizedDescription)"))
                }
            }

            isRunning = false
        }
    }
}

// MARK: - Agent Chip
struct AgentChip: View {
    let agent: Agent
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(agent.emoji).font(.system(size: 12))
                Text(agent.name)
                    .font(.system(size: 10))
                    .lineLimit(1)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

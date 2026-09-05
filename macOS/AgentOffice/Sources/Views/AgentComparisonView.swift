// AgentComparisonView.swift
import SwiftUI

struct AgentComparisonView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var prompt = ""
    @State private var selectedAgent1: Agent?
    @State private var selectedAgent2: Agent?
    @State private var response1 = ""
    @State private var response2 = ""
    @State private var isRunning = false
    @State private var showAgentPicker1 = false
    @State private var showAgentPicker2 = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Compare Agents").font(.headline)
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
                    Text("Shared Prompt").font(.system(size: 11, weight: .semibold))
                    TextEditor(text: $prompt)
                        .font(.system(size: 12))
                        .frame(height: 60)
                        .scrollContentBackground(.visible)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }

                // Agent selectors
                HStack(spacing: 16) {
                    AgentSelector(
                        label: "Agent 1",
                        agent: selectedAgent1,
                        onTap: { showAgentPicker1 = true }
                    )
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundStyle(.secondary)
                    AgentSelector(
                        label: "Agent 2",
                        agent: selectedAgent2,
                        onTap: { showAgentPicker2 = true }
                    )
                }

                // Side-by-side results
                HStack(spacing: 12) {
                    ResponseColumn(
                        title: selectedAgent1?.name ?? "Agent 1",
                        emoji: selectedAgent1?.emoji ?? "?",
                        response: response1,
                        color: .blue
                    )
                    ResponseColumn(
                        title: selectedAgent2?.name ?? "Agent 2",
                        emoji: selectedAgent2?.emoji ?? "?",
                        response: response2,
                        color: .green
                    )
                }
            }
            .padding()

            Divider()

            // Actions
            HStack {
                Button(isRunning ? "Running..." : "Compare") {
                    runComparison()
                }
                .buttonStyle(.borderedProminent)
                .disabled(prompt.isEmpty || selectedAgent1 == nil || selectedAgent2 == nil || isRunning)

                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 700, height: 550)
        .sheet(isPresented: $showAgentPicker1) {
            AgentPickerSheet(selectedAgent: $selectedAgent1, title: "Select Agent 1")
        }
        .sheet(isPresented: $showAgentPicker2) {
            AgentPickerSheet(selectedAgent: $selectedAgent2, title: "Select Agent 2")
        }
    }

    func runComparison() {
        guard let agent1 = selectedAgent1, let agent2 = selectedAgent2 else { return }
        isRunning = true
        response1 = ""
        response2 = ""

        Task {
            let service = LLMService(provider: store.selectedProvider, apiKey: store.apiKey)
            async let r1 = service.execute(systemPrompt: agent1.systemPrompt, userMessage: prompt)
            async let r2 = service.execute(systemPrompt: agent2.systemPrompt, userMessage: prompt)
            do {
                let res1 = try await r1
                let res2 = try await r2
                response1 = res1.text
                response2 = res2.text
            } catch {
                response1 = "Error: \(error.localizedDescription)"
                response2 = "Error: \(error.localizedDescription)"
            }
            isRunning = false
        }
    }
}

// MARK: - Agent Selector
struct AgentSelector: View {
    let label: String
    let agent: Agent?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let agent {
                    Text(agent.emoji).font(.system(size: 24))
                    Text(agent.name).font(.system(size: 11, weight: .medium))
                } else {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    Text(label).font(.system(size: 11)).foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 60)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Response Column
struct ResponseColumn: View {
    let title: String
    let emoji: String
    let response: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(emoji)
                Text(title).font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
            }
            ScrollView {
                Text(response.isEmpty ? "No response yet..." : response)
                    .font(.system(size: 11))
                    .foregroundStyle(response.isEmpty ? .tertiary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Agent Picker Sheet
struct AgentPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAgent: Agent?
    let title: String
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(store.allAgents) { agent in
                        Button(action: {
                            selectedAgent = agent
                            dismiss()
                        }) {
                            VStack(spacing: 4) {
                                Text(agent.emoji).font(.system(size: 20))
                                Text(agent.name).font(.system(size: 10))
                                    .lineLimit(1)
                            }
                            .frame(width: 80, height: 60)
                            .background(selectedAgent?.id == agent.id ? Color.accentColor.opacity(0.15) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .frame(width: 450, height: 400)
    }
}

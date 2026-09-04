// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var step = 0
    @State private var setupProvider: LLMProvider = .anthropic
    @State private var setupApiKey = ""
    @State private var setupBudget = 10.0

    let steps: [(title: String, subtitle: String, icon: String)] = [
        ("Welcome to Agent Office", "Your AI agent command center", "building.2"),
        ("Drag Agents to Desks", "Drag from the sidebar to seat agents at desks", "hand.draw"),
        ("Write a Prompt", "Type your task in the command bar at the bottom", "command"),
        ("Choose a Workflow", "Select parallel, pipeline, synthesis, or debate mode", "arrow.triangle.branch"),
        ("Run All Agents", "Press Run or hit ⌘↵ to execute", "play.fill"),
        ("Configure Provider", "Set up your LLM provider and API key", "key"),
        ("Set Budget", "Configure your daily cost budget", "dollarsign.circle"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Step content
            VStack(spacing: 12) {
                Image(systemName: steps[step].icon)
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                Text(steps[step].title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(steps[step].subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Setup UI for provider step
                if step == 5 {
                    setupProviderView
                }
                if step == 6 {
                    setupBudgetView
                }
            }
            .frame(maxWidth: 350)

            Spacer()

            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i == step ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: i == step ? 8 : 6, height: i == step ? 8 : 6)
                }
            }

            // Navigation
            HStack {
                if step > 0 {
                    Button("Back") { withAnimation { step -= 1 } }
                        .buttonStyle(.bordered)
                }
                Spacer()
                if step < steps.count - 1 {
                    Button("Next") {
                        withAnimation { step += 1 }
                        if step == steps.count - 1 {
                            store.selectedProvider = setupProvider
                            store.apiKey = setupApiKey
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        store.selectedProvider = setupProvider
                        store.apiKey = setupApiKey
                        store.dailyBudget = setupBudget
                        store.hasSeenOnboarding = true
                        store.persist()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 480)
    }

    var setupProviderView: some View {
        VStack(spacing: 12) {
            Picker("Provider", selection: $setupProvider) {
                ForEach(LLMProvider.allCases, id: \.self) { p in
                    Text(p.displayName).tag(p)
                }
            }
            .pickerStyle(.segmented)

            if setupProvider != .ollama {
                SecureField("API Key", text: $setupApiKey)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text("Ollama runs locally on localhost:11434")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }

    var setupBudgetView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Daily budget: $")
                TextField("10.00", value: $setupBudget, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            Text("You'll be warned when approaching this limit")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

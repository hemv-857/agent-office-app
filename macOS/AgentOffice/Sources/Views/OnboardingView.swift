// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var step = 0

    let steps: [(title: String, subtitle: String, icon: String)] = [
        ("Welcome to Agent Office", "Your AI agent command center", "building.2"),
        ("Drag Agents to Desks", "Drag from the sidebar to seat agents at desks", "hand.draw"),
        ("Write a Prompt", "Type your task in the command bar at the bottom", "command"),
        ("Choose a Workflow", "Select parallel, pipeline, synthesis, or debate mode", "arrow.triangle.branch"),
        ("Run All Agents", "Press Run or hit ⌘↵ to execute", "play.fill"),
        ("Track Costs", "Monitor token usage and costs in real time", "dollarsign.circle"),
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
                    Button("Next") { withAnimation { step += 1 } }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
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
        .frame(width: 500, height: 420)
    }
}

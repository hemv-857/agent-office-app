// WorkflowOnboardingView.swift
import SwiftUI

struct WorkflowOnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var step = 0

    private let steps: [(String, String, String)] = [
        ("Welcome to Agent Office", "Orchestrate AI agents in a virtual office", "person.3.fill"),
        ("Select Agents", "Choose agents for your task from the sidebar", "sidebar.left"),
        ("Choose Workflow Mode", "Pick the best mode for your task", "arrow.triangle.branch"),
        ("Enter Your Prompt", "Type your task in the prompt field", "text.cursor"),
        ("Run & Collaborate", "Click Run and watch agents work together", "play.fill"),
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

            // Step content
            VStack(spacing: 16) {
                Image(systemName: steps[step].2)
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)

                Text(steps[step].0)
                    .font(.title3)

                Text(steps[step].1)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Progress
                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == step ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)

            Spacer()

            Divider()

            HStack {
                if step > 0 {
                    Button("Back") { step -= 1 }
                        .buttonStyle(.bordered)
                }
                Spacer()
                if step < steps.count - 1 {
                    Button("Next") { step += 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 450, height: 400)
    }
}

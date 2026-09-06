// WorkflowAgentOnboardingWizardView.swift
import SwiftUI

struct WorkflowAgentOnboardingWizardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var currentStep = 0

    private let steps: [(String, String, String)] = [
        ("Welcome", "Getting Started", "Welcome to Agent Office! Let's set up your first workflow in 5 easy steps."),
        ("Choose Provider", "Configure API", "Select your LLM provider and enter your API key to get started."),
        ("Select Model", "Pick a Model", "Choose a model based on your needs. Claude 3.5 Sonnet is recommended for most tasks."),
        ("Set Budget", "Cost Control", "Set a daily budget to keep costs under control. Alerts trigger at 80% by default."),
        ("First Workflow", "Go!", "You're all set! Try a Parallel workflow to see multiple agents work together."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Onboarding Wizard").font(.headline)
                Spacer()
                Text("Step \(currentStep + 1) of \(steps.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Progress
            HStack(spacing: 4) {
                ForEach(0..<steps.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= currentStep ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Step content
            VStack(spacing: 16) {
                Image(systemName: ["sparkles", "key.fill", "cpu", "dollarsign.circle", "checkmark.circle.fill"][currentStep])
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)

                Text(steps[currentStep].0)
                    .font(.system(size: 20, weight: .bold))

                Text(steps[currentStep].1)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(steps[currentStep].2)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation { currentStep -= 1 }
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
                if currentStep < steps.count - 1 {
                    Button("Next") {
                        withAnimation { currentStep += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        store.showToast("Welcome! Try a workflow.", type: .success)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 480, height: 440)
    }
}
